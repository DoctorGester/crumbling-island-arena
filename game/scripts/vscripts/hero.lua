if not Hero then
    Hero = class({}, nil, UnitEntity)
end

function Hero:constructor(round)
    DynamicEntity.constructor(self, round) -- Intended

    self.protected = false
    self.modifierImmune = false
    self.removeOnDeath = false
    self.collisionType = COLLISION_TYPE_RECEIVER
end

function Hero:SetUnit(unit)
    self.unit = unit
    unit.hero = self
end

function Hero:SetOwner(owner)
    local c = GameRules.GameMode.TeamColors[owner.team]
    local name = IsInToolsMode() and "Player" or PlayerResource:GetPlayerName(owner.id)

    self.owner = owner
    self.unit:SetControllableByPlayer(owner.id, true)
    self.unit:SetCustomHealthLabel(name, c[1], c[2], c[3])
    PlayerResource:SetOverrideSelectionEntity(owner.id, self.unit)
end

function Hero:GetName()
    return self.unit:GetUnitName()
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

function Hero:Damage(source)
    if source == nil then source = self end

    if not self:Alive() or self.protected or self.falling then
        return
    end

    if self:IsInvulnerable() and source ~= self then
        return
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
end

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

function Hero:FindAbility(name)
    return self.unit:FindAbilityByName(name)
end

function Hero:EnableUltimate(ultimate)
    self.unit:FindAbilityByName(ultimate):SetLevel(1)
end

function Hero:Hide()
    self.unit:SetAbsOrigin(Vector(0, 0, 10000))
    self.unit:AddNoDraw()
    self:AddNewModifier(self, nil, "modifier_hidden", {})
end

function Hero:CanFall()
    local airborne = false

    if not IsValidEntity(self.unit) then
        return false
    end

    for _, modifier in pairs(self.unit:FindAllModifiers()) do
        if modifier.Airborne and modifier:Airborne() then
            airborne = true
            break
        end
    end

    return not airborne
end

function Hero:Update()
    getbase(Hero).Update(self)

    if self.owner and self.unit and self.owner:IsConnected() and PlayerResource:GetPlayer(self.owner.id) then
        local assigned = PlayerResource:GetPlayer(self.owner.id):GetAssignedHero()

        if IsValidEntity(self.unit) and assigned then
            assigned:SetAbsOrigin(self:GetPos())
        end
    end
end

function Hero:Setup()
    self:AddNewModifier(self, nil, "modifier_hero", {})
    --self.unit:SetAbilityPoints(0)

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