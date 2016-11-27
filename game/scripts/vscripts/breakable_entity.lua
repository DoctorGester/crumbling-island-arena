BreakableEntity = BreakableEntity or class({}, nil, UnitEntity)

function BreakableEntity:constructor(round, unitName, pos, team, findSpace)
    getbase(BreakableEntity).constructor(self, round, unitName, pos, team, findSpace)

    self.customHealth = false
end

function BreakableEntity:SetCustomHealth(health)
    self.customHealth = true
    self.health = health
end

function BreakableEntity:EnableHealthBar()
    self.healthBarEnabled = true

    self:GetUnit():SetMaxHealth(self.health)
    self:GetUnit():SetBaseMaxHealth(self.health)
end

function BreakableEntity:Damage(source, amount, isPhysical)
    if amount == nil then
        amount = 3
    end

    if source == nil then source = self end

    if not self:Alive() or self.protected or self.falling then
        return
    end

    if self:IsInvulnerable() and source ~= self then
        return
    end

    local all = self:AllModifiers()

    table.sort(all, function(a, b)
        local ap = a.OnDamageReceivedPriority and a:OnDamageReceivedPriority() or 0
        local bp = b.OnDamageReceivedPriority and b:OnDamageReceivedPriority() or 0

        return ap > bp
    end)

    for _, modifier in pairs(all) do
        if modifier.OnDamageReceived then
            local result = modifier:OnDamageReceived(source, self, amount, isPhysical)

            if result == false then -- == false so nil works
                return
            end

            if result ~= true then
                amount = result or amount;
            end
        end
    end

    if self.customHealth then
        self.health = math.max(0, self.health - amount)

        if self.health <= 0 then
            self:Destroy()
        elseif self.healthBarEnabled then
            self:GetUnit():SetHealth(self.health)
        end
    else
        local damageTable = {
            victim = self.unit,
            attacker = source.unit,
            damage = amount,
            damage_type = DAMAGE_TYPE_PURE,
        }

        ApplyDamage(damageTable)
    end

    self:GetUnit():AddNewModifier(self:GetUnit(), nil, "modifier_damaged", { duration = 0.2 })

    local sign = ParticleManager:CreateParticle("particles/msg_damage.vpcf", PATTACH_CUSTOMORIGIN, mode)
    ParticleManager:SetParticleControl(sign, 0, self:GetPos())
    ParticleManager:SetParticleControl(sign, 1, Vector(0, amount, 0))
    ParticleManager:SetParticleControl(sign, 2, Vector(1, 1, 0))
    ParticleManager:SetParticleControl(sign, 3, Vector(255, 255, 255))
    ParticleManager:ReleaseParticleIndex(sign)

    if not self:Alive() then
        self:OnDeath(source)
    end
end

function BreakableEntity:OnDeath(source) end