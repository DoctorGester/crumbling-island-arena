require('ecs/heroes/tiny')

function WrapComponent(c)
    local meta = {
        __add = function(filter1, filter2)
            for k, v in pairs(filter2) do
                filter1[k] = v
            end

            return filter1
        end
    }

    setmetatable(c, meta)

    return c
end

function HealthComponent()
    return WrapComponent({
        customHealth = false,
        healthBarEnabled = false,
        SetCustomHealth = function(self, health)
            self.customHealth = true
            self.health = health
        end,
        EnableHealthBar = function(self)
            self.healthBarEnabled = true

            self:GetUnit():SetMaxHealth(self.health)
            self:GetUnit():SetBaseMaxHealth(self.health)
        end
    })
end

function PlayerCircleComponent(radius, thick, a)
    return WrapComponent({
        Activate = function(self)
            local path = thick and "particles/aoe_marker_filled.vpcf" or "particles/aoe_marker_filled_thin.vpcf"
            local color = GameRules.GameMode.TeamColors[self.owner.team]

            self.playerCircleParticle = FX(path, PATTACH_ABSORIGIN, self, {
                cp0 = self:GetPos(),
                cp1 = Vector(radius, 1, 1),
                cp2 = Vector(color[1], color[2], color[3]),
                cp3 = Vector(a, 0, 0)
            })
        end
    })
end

function ModelCheckerComponent()
    return WrapComponent({
        HasModelChanged = function(self)
            for _, modifier in pairs(self:AllModifiers()) do
                if modifier.DeclareFunctions then
                    local funcs = modifier:DeclareFunctions()

                    if vlua.find(funcs, MODIFIER_PROPERTY_MODEL_CHANGE) ~= nil then
                        if modifier.GetModifierModelChange then
                            if modifier:GetModifierModelChange() then
                                return true
                            end
                        end
                    end
                end
            end

            return false
        end
    })
end

function WearableComponent()
    return WrapComponent({
        wearables = {},
        wearableParticles = {},
        mappedParticles = {},
        wearableSlots = {},
        slotVisualParameters = {},
        hideQueue = nil,
        LoadItem = function(self, id)
            return self:LoadItems(id)[1]
        end,
        GetWearableBySlot = function(self, slot)
            return self.wearableSlots[slot]
        end,
        LoadItems = function(self, ...)
            local items = self:FindDefaultItems()
            local ignored = {}
            local styles = {}

            for _, arg in pairs({ ... }) do
                if type(arg) == "number" then
                    local item = GameItems.items[tostring(arg)]

                    if item then
                        items[item.item_slot or "weapon"] = item
                        item.id = arg
                    end
                end

                if type(arg) == "string" then
                    if arg:ends(".vmdl") then
                        local split = arg:split(":")

                        items[split[1]] = {
                            model_player = split[2]
                        }
                    else
                        local set = self:FindSetItems(arg)

                        for slot, item in pairs(set) do
                            items[slot] = item
                        end
                    end
                end

                if type(arg) == "table" then
                    if type(arg.style) == "number" and type(arg.id) == "number" then
                        styles[arg.id] = arg.style
                    elseif type(arg.ignore) == "number" then
                        ignored[arg.ignore] = true
                    else
                        for slot, item in pairs(arg) do
                            items[slot] = item
                        end
                    end
                end
            end

            local sessionWearables = {}

            for slot, item in pairs(items) do
                if not item.id or not ignored[item.id] then
                    self.slotVisualParameters[slot] = { self:GetUnit(), item.visuals or {}, styles[item.id], slot }

                    if item.model_player then
                        local wearable = self:AttachWearable(item.model_player)
                        self.slotVisualParameters[slot][1] = wearable

                        table.insert(sessionWearables, wearable)
                        self.wearableSlots[slot] = wearable
                    end

                    self:AttachVisuals(unpack(self.slotVisualParameters[slot]))
                end
            end

            return sessionWearables
        end,
        RecreateSlotVisuals = function(self, slot)
            self:AttachVisuals(unpack(self.slotVisualParameters[slot]))
        end,
        DestroySlotVisuals = function(self, slot)
            for _, particle in pairs(self.wearableParticles[slot] or {}) do
                DFX(particle)
            end

            self.wearableParticles[slot] = nil
        end,
        AttachVisuals = function(self, wearable, visuals, style, slot)
            local attachTypes = {
                customorigin = PATTACH_CUSTOMORIGIN,
                point_follow = PATTACH_POINT_FOLLOW,
                absorigin_follow = PATTACH_ABSORIGIN_FOLLOW
            }

            local particleCreateQueue = {}

            for name, visual in pairs(visuals) do
                if string.find(name, "asset_modifier") and (style == nil or visual.style == style) then
                    local t = visual.type

                    if t == "particle_create" then
                        for _, system in pairs(GameItems.attribute_controlled_attached_particles) do
                            if system.system == visual.modifier then
                                particleCreateQueue[visual] = system
                            end
                        end
                    elseif t == "additional_wearable" then
                        self:AttachWearable(visual.asset)
                    elseif t == "particle" then
                        self.mappedParticles[visual.asset] = visual.modifier
                    elseif t == "activity" then
                        CustomNetTables:SetTableValue("wearables", "activity_" .. tostring(wearable:GetEntityIndex()), { activity = visual.modifier })
                        self:AddNewModifier(wearable, nil, "modifier_wearable_visuals_activity", {})
                    else
                        print("Unknown modifier type", t, "with mod", visual.modifier)
                    end
                end
            end

            for visual, system in pairs(particleCreateQueue) do
                local target = wearable

                if system.attach_entity == "parent" then
                    target = self:GetUnit()
                end

                local mainAt = attachTypes[system.attach_type] or PATTACH_POINT_FOLLOW
                local particle = ParticleManager:CreateParticle(self:GetMappedParticle(system.system), mainAt, target)
                print("Attaching", self:GetMappedParticle(system.system), mainAt, target)

                for _, cp in pairs(system.control_points or {}) do
                    local at = attachTypes[cp.attach_type]

                    if at == nil then
                        print("Unknown attachment type", cp.attach_type)
                        at = PATTACH_ABSORIGIN_FOLLOW
                    end

                    ParticleManager:SetParticleControlEnt(particle, cp.control_point_index, target, at, cp.attachment, target:GetAbsOrigin(), true)

                    print("CP", cp.control_point_index, at, cp.attachment)
                end

                self.wearableParticles[slot] = self.wearableParticles[slot] or {}
                table.insert(self.wearableParticles[slot], particle)
            end
        end,
        GetMappedParticle = function(self, original)
            return self.mappedParticles[original] or original
        end,
        FindDefaultItems = function(self)
            local heroName = self:GetName()
            local result = {}

            for id, item in pairs(GameItems.items) do
                if item.prefab == "default_item" and item.used_by_heroes[heroName] == 1 then
                    result[item.item_slot or "weapon"] = item
                    item.id = tonumber(id)
                end
            end

            return result
        end,
        FindSetItems = function(self, setName)
            local set = GameItems.item_sets[setName]
            local result = {}

            if set and set.items then
                for id, item in pairs(GameItems.items) do
                    for setItem, _ in pairs(set.items) do
                        if item.name == setItem then
                            result[item.item_slot or "weapon"] = item
                            item.id = tonumber(id)
                            break
                        end
                    end
                end
            end

            return result
        end,
        FindCurrentEffect = function(self, mainFunction, priorityFunction)
            local statusFx
            local maxStatusPriority = 0
            local minCreationTime = math.huge

            for _, modifier in pairs(self:AllModifiers()) do
                if modifier[mainFunction] then
                    local priority = 0

                    if modifier[priorityFunction] then
                        priority = modifier[priorityFunction](modifier)
                    end

                    if priority >= maxStatusPriority then
                        local creationTime = modifier:GetCreationTime()

                        if priority == maxStatusPriority then
                            if creationTime < minCreationTime then
                                minCreationTime = creationTime

                                statusFx = modifier[mainFunction](modifier)
                            end
                        else
                            statusFx = modifier[mainFunction](modifier)
                        end

                        maxStatusPriority = priority
                        minCreationTime = creationTime
                    end
                end
            end

            return statusFx
        end,
        UpdateEffect = function(self, wearable, effect, modifier)
            local visualsStatusFx = wearable:FindModifierByName(modifier)

            if visualsStatusFx ~= nil then
                visualsStatusFx:Destroy()
            end

            if effect ~= nil then
                CustomNetTables:SetTableValue("wearables", tostring(wearable:GetEntityIndex()), { fx = effect })
                wearable:AddNewModifier(wearable, nil, modifier, {})
            end
        end,
        AttachWearable = function(self, modelPath)
            local wearable = CreateUnitByName("wearable_model", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NOTEAM)

            local oldSet = wearable.SetModel

            wearable.SetModel = function(self, model)
                oldSet(self, model)
                self:SetOriginalModel(model)
            end

            wearable:SetModel(modelPath)
            wearable:FollowEntity(self:GetUnit(), true)
            wearable:AddNewModifier(wearable, nil, "modifier_wearable_visuals", {})

            table.insert(self.wearables, wearable)

            return wearable
        end,
        CleanParticles = function(self)
            for _, slotParticles in pairs(self.wearableParticles) do
                for _, particle in pairs(slotParticles) do
                    ParticleManager:DestroyParticle(particle, false)
                    ParticleManager:ReleaseParticleIndex(particle)
                end
            end

            self.wearableParticles = {}
        end,
        CleanWearables = function(self)
            for _, part in pairs(self.wearables) do
                CustomNetTables:SetTableValue("wearables", tostring(part:GetEntityIndex()), nil)
                CustomNetTables:SetTableValue("wearables", "activity_" .. tostring(part:GetEntityIndex()), nil)
                part:RemoveSelf()
            end

            self.wearables = {}
        end
    }) + ModelCheckerComponent()
end