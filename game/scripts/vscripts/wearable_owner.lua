WearableOwner = WearableOwner or class({}, nil, BreakableEntity)

function WearableOwner:constructor(round, unitName, pos, team, findSpace)
    getbase(WearableOwner).constructor(self, round, unitName, pos, team, findSpace)

    self.wearables = {}
    self.wearableParticles = {}
    self.mappedParticles = {}
    self.wearableSlots = {}
    self.hideQueue = nil
end

function WearableOwner:LoadItem(id)
    return self:LoadItems(id)[1]
end

function WearableOwner:GetWearableBySlot(slot)
    return self.wearableSlots[slot]
end

function WearableOwner:LoadItems(...)
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
            if item.model_player then
                local wearable = self:AttachWearable(item.model_player)
                self:AttachVisuals(wearable, item.visuals or {}, styles[item.id])

                table.insert(sessionWearables, wearable)
                self.wearableSlots[slot] = wearable
            else
                self:AttachVisuals(self:GetUnit(), item.visuals or {}, styles[item.id])
            end
        end
    end

    return sessionWearables
end

function WearableOwner:AttachVisuals(wearable, visuals, style)
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
                CustomNetTables:SetTableValue("wearables", "activity_"..tostring(wearable:GetEntityIndex()), { activity = visual.modifier })
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

        local particle = ParticleManager:CreateParticle(self:GetMappedParticle(system.system), PATTACH_POINT_FOLLOW, target)

        for _, cp in pairs(system.control_points or {}) do
            local at = attachTypes[cp.attach_type]

            if at == nil then
                print("Unknown attachment type", cp.attach_type)
                at = PATTACH_ABSORIGIN_FOLLOW
            end

            ParticleManager:SetParticleControlEnt(particle, cp.control_point_index, target, at, cp.attachment, target:GetAbsOrigin(), true)
        end

        table.insert(self.wearableParticles, particle)
    end
end

function WearableOwner:GetMappedParticle(original)
    return self.mappedParticles[original] or original
end

function WearableOwner:FindDefaultItems()
    local heroName = self:GetName()
    local result = {}

    for id, item in pairs(GameItems.items) do
        if item.prefab == "default_item" and item.used_by_heroes[heroName] == 1 then
            result[item.item_slot or "weapon"] = item
            item.id = tonumber(id)
        end
    end

    return result
end

function WearableOwner:FindSetItems(setName)
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
end

function WearableOwner:HasModelChanged()
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

function WearableOwner:FindCurrentEffect(mainFunction, priorityFunction)
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
end

function WearableOwner:UpdateEffect(wearable, effect, modifier)
    local visualsStatusFx = wearable:FindModifierByName(modifier)

    if visualsStatusFx ~= nil then
        visualsStatusFx:Destroy()
    end

    if effect ~= nil then
        CustomNetTables:SetTableValue("wearables", tostring(wearable:GetEntityIndex()), { fx = effect })
        wearable:AddNewModifier(wearable, nil, modifier, {})
    end
end

function WearableOwner:Update()
    getbase(WearableOwner).Update(self)

    local invisLevel = 0.0
    local modelChanged = self:HasModelChanged()
    local statusFx = self:FindCurrentEffect("GetStatusEffectName", "StatusEffectPriority")
    local heroFx = self:FindCurrentEffect("GetHeroEffectName", "HeroEffectPriority")

    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.GetModifierInvisibilityLevel then
            invisLevel = math.max(invisLevel, math.min(modifier:GetModifierInvisibilityLevel(), 1.0))
        end
    end

    if self.hideQueue ~= nil then
        getbase(WearableOwner).SetHidden(self, self.hideQueue)

        for _, wearable in pairs(self.wearables) do
            if self.hideQueue then
                wearable:AddNoDraw()
            else
                wearable:RemoveNoDraw()
            end
        end

        self.hideQueue = nil
    end


    local statusFxChanged = self.lastStatusFx ~= statusFx
    self.lastStatusFx = statusFx

    local heroFxChanged = self.lastHeroFx ~= heroFx
    self.lastHeroFx = heroFx

    for _, wearable in pairs(self.wearables) do
        local visuals = wearable:FindModifierByName("modifier_wearable_visuals")

        if visuals then
            local count = invisLevel * 100

            if modelChanged then
                count = count + 101
            end

            visuals:SetStackCount(count)
        end

        if statusFxChanged then
            WearableOwner:UpdateEffect(wearable, statusFx, "modifier_wearable_visuals_status_fx")
        end

        if heroFxChanged then
            WearableOwner:UpdateEffect(wearable, heroFx, "modifier_wearable_visuals_hero_fx")
        end
    end
end

function WearableOwner:SetHidden(hidden)
    self.hideQueue = hidden
end

function WearableOwner:AttachWearable(modelPath)
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
end

function WearableOwner:CleanParticles()
    for _, particle in pairs(self.wearableParticles) do
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end

    self.wearableParticles = {}
end

function WearableOwner:CleanWearables()
    for _, part in pairs(self.wearables) do
        CustomNetTables:SetTableValue("wearables", tostring(part:GetEntityIndex()), nil)
        CustomNetTables:SetTableValue("wearables", "activity_"..tostring(part:GetEntityIndex()), nil)
        part:RemoveSelf()
    end

    self.wearables = {}
end

function WearableOwner:Remove()
    self:CleanWearables()
    self:CleanParticles()

    getbase(WearableOwner).Remove(self)
end
