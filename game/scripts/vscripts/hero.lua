if not Hero then
    Hero = class({}, nil, WearableOwner)
end

function Hero:constructor(round)
    DynamicEntity.constructor(self, round) -- Intended

    self.protected = false
    self.modifierImmune = false
    self.removeOnDeath = false
    self.collisionType = COLLISION_TYPE_RECEIVER

    self.soundsStarted = {}
    self.wearables = {}
    self.wearableParticles = {}
    self.mappedParticles = {}
    self.wearableSlots = {}
end

function Hero:SetUnit(unit)
    getbase(Hero).SetUnit(self, unit)
    unit.hero = self
end

function Hero:GetShortName()
    return self:GetName():sub(("npc_dota_hero_"):len() + 1)
end

function Hero:LoadWearables()
    local cosmetics = Cosmetics[self:GetShortName()]
    local result = {}

    self.passEnabled = PlayerResource:HasCustomGameTicketForPlayerID(self.owner.id)

    if cosmetics then
        local function processIgnore(t)
            local ignore = t.ignore

            if ignore then
                for _, item in pairs(tostring(ignore):split(",")) do
                    table.insert(result, { ignore = tonumber(item) })
                end
            end
        end

        if cosmetics.ignore == "all" then
            for _, item in pairs(self:FindDefaultItems()) do
                table.insert(result, { ignore = item.id })
            end
        else
            processIgnore(cosmetics)
        end

        local ordered = {}

        for id, entry in pairs(cosmetics) do
            if type(entry) == "table" then
                ordered[tonumber(id)] = entry
            end
        end

        for _, entry in ipairs(ordered) do
            local t = entry.type
            local passBase = (t == "pass_base" and self.passEnabled)
            local elite = (t == "elite")

            if elite then
                self.awardEnabled = GameRules.GameMode:IsAwardedForSeason(self.owner.id, entry.season)

                elite = elite and self.awardEnabled
            end

            local passLevel = (t == "pass" and entry.level <= (self.owner.passLevel or 0))

            if passBase or elite or passLevel then
                processIgnore(entry)

                if entry.set then
                    table.insert(result, entry.set)
                end

                if entry.item then
                    for _, item in pairs(tostring(entry.item):split(",")) do
                        table.insert(result, tonumber(item))
                    end
                end

                if entry.particles then
                    for original, asset in pairs(entry.particles) do
                        self.mappedParticles[original] = asset
                    end
                end

                if entry.emote then
                    self:GetUnit():RemoveAbility("placeholder_emote")
                    self:GetUnit():AddAbility("emote"):SetLevel(1)
                end

                if entry.taunt then
                    self:GetUnit():RemoveAbility("placeholder_taunt")

                    local ability = entry.taunt.type == "static" and "taunt_static" or "taunt_moving"
                    local taunt = self:GetUnit():AddAbility(ability)
                    local length = entry.taunt.length

                    if length == nil then
                        length = 1.5
                    end

                    taunt:SetLevel(1)
                    taunt.length = length
                    taunt.activity = entry.taunt.activity
                    taunt.sound = entry.taunt.sound
                    taunt.translate = entry.taunt.translate
                end
            end
        end
    end

    self:LoadItems(unpack(result))
end

function Hero:StopSound(sound)
    getbase(Hero).StopSound(self, sound)

    table.insert(self.soundsStarted, sound)
end

function Hero:SetOwner(owner)
    local c = GameRules.GameMode.TeamColors[owner.team]
    local name = IsInToolsMode() and "Player" or PlayerResource:GetPlayerName(owner.id)

    self.owner = owner
    self.unit:SetControllableByPlayer(owner.id, true)
    self.unit:SetCustomHealthLabel(name, c[1], c[2], c[3])
    PlayerResource:SetOverrideSelectionEntity(owner.id, self.unit)

    self:LoadWearables()
end

function Hero:IsAwardEnabled()
    return self.awardEnabled
end

function Hero:GetPos()
    return self.unit:GetAbsOrigin()
end

function Hero:GetRad()
    return self.unit:BoundingRadius2D() * 2
end

function Hero:GetHealth()
    return math.floor(self.unit:GetHealth())
end

function Hero:Alive()
    return IsValidEntity(self.unit) and self.unit:IsAlive()
end

function Hero:SetPos(pos)
    self.unit:SetAbsOrigin(pos)
end

function Hero:SetHealth(health)
    self.unit:SetHealth(math.floor(health))
end

function Hero:SwapAbilities(from, to)
    self.unit:SwapAbilities(from, to, false, true)
end

function Hero:IsInvulnerable()
    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.IsInvulnerable then
            local result = modifier:IsInvulnerable(self)

            if result == true then
                return true
            end
        end
    end

    return self.invulnerable
end

function Hero:Damage(source)
    if source == nil then source = self end

    if not self:Alive() or self.protected or self.falling then
        return
    end

    if self:IsInvulnerable() and source ~= self then
        return
    end

    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.OnDamageReceived then
            local result = modifier:OnDamageReceived(source, self)

            if result == false then -- == false so nil works
                return
            end
        end
    end

    local damageTable = {
        victim = self.unit,
        attacker = source.unit,
        damage = 1,
        damage_type = DAMAGE_TYPE_PURE,
    }

    ApplyDamage(damageTable)

    local sign = ParticleManager:CreateParticle("particles/msg_fx/msg_damage.vpcf", PATTACH_CUSTOMORIGIN, mode)
    ParticleManager:SetParticleControl(sign, 0, self:GetPos())
    ParticleManager:SetParticleControl(sign, 1, Vector(0, 1, 3))
    ParticleManager:SetParticleControl(sign, 2, Vector(2, 2, 0))
    ParticleManager:SetParticleControl(sign, 3, Vector(200, 0, 0))
    ParticleManager:ReleaseParticleIndex(sign)

    GameRules.GameMode:OnDamageDealt(self, source)

    if not self:Alive() then
        self:OnDeath()
    end
end

function Hero:OnDeath() end

function Hero:Heal()
    if self.unit:IsAlive() then
        self.unit:SetHealth(self.unit:GetHealth() + 1)

        local sign = ParticleManager:CreateParticle("particles/msg_fx/msg_heal.vpcf", PATTACH_CUSTOMORIGIN, mode)
        ParticleManager:SetParticleControl(sign, 0, self:GetPos())
        ParticleManager:SetParticleControl(sign, 1, Vector(10, 1, 0))
        ParticleManager:SetParticleControl(sign, 2, Vector(2, 2, 0))
        ParticleManager:SetParticleControl(sign, 3, Vector(100, 255, 50))
        ParticleManager:ReleaseParticleIndex(sign)

        self.round.statistics:IncreaseHealingReceived(self.owner)
    end
end

function Hero:RestoreMana()
    if self.unit:IsAlive() then
        self.unit:SetMana(self.unit:GetMana() + 1)

        local sign = ParticleManager:CreateParticle("particles/msg_fx/msg_mana_add.vpcf", PATTACH_CUSTOMORIGIN, mode)
        ParticleManager:SetParticleControl(sign, 0, self:GetPos())
        ParticleManager:SetParticleControl(sign, 1, Vector(10, 1, 0))
        ParticleManager:SetParticleControl(sign, 2, Vector(2, 2, 0))
        ParticleManager:SetParticleControl(sign, 3, Vector(0, 248, 255))
        ParticleManager:ReleaseParticleIndex(sign)
    end
end

function Hero:FindAbility(name)
    return self.unit:FindAbilityByName(name)
end

function Hero:EnableUltimate(ultimate)
    self.unit:FindAbilityByName(ultimate):SetLevel(1)
end

function Hero:Hide()
    if IsValidEntity(self.unit) then
        self.unit:SetAbsOrigin(Vector(0, 0, 10000))
        self.unit:AddNoDraw()
        self:AddNewModifier(self, nil, "modifier_hidden", {})
    end
end

function Hero:CanFall()
    local airborne = false

    for _, modifier in pairs(self.unit:FindAllModifiers()) do
        if modifier.Airborne and modifier:Airborne() then
            airborne = true
            break
        end
    end

    return not airborne
end

function Hero:MakeFall()
    getbase(Hero).MakeFall(self)

    local modifier = self:FindModifier("modifier_knockback_lua")

    if modifier then
        self.lastKnockbackCaster = modifier:GetCaster().hero
    end
end

function Hero:AddNewModifier(source, ability, name, params)
    if name ~= "modifier_falling" then
        for _, modifier in pairs(self:AllModifiers()) do
            if modifier.OnModifierAdded then
                local result = modifier:OnModifierAdded(source, ability, name, params)

                if result == false then
                    return
                end
            end
        end
    end

    return getbase(Hero).AddNewModifier(self, source, ability, name, params)
end

function Hero:Update()
    getbase(Hero).Update(self)

    if self.owner and self.unit and self.owner:IsConnected() and PlayerResource:GetPlayer(self.owner.id) then
        local assigned = PlayerResource:GetPlayer(self.owner.id):GetAssignedHero()

        if assigned then
            assigned:SetAbsOrigin(self:GetPos())
        end
    end
end

function Hero:Setup()
    self:AddNewModifier(self, nil, "modifier_hero", {})
    self.unit:SetAbilityPoints(0)

    local count = self.unit:GetAbilityCount() - 1
    for i = 0, count do
        local ability = self.unit:GetAbilityByIndex(i)

        if ability ~= nil and not ability:IsAttributeBonus() and not ability:IsHidden()  then
            local name = ability:GetName()

            if string.find(name, "sub") then
                ability:SetHidden(true)
            end

            ability:SetLevel(1)
        end
    end
end

function Hero:Remove()
    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.GetName and modifier:GetName() ~= "modifier_falling" then
            modifier:Destroy()
        end
    end

    for _, sound in pairs(self.soundsStarted) do
        getbase(Hero).StopSound(self, sound)
    end

    getbase(Hero).Remove(self)
end
