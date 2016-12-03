LDBear = LDBear or class({}, nil, UnitEntity)

function LDBear:constructor(round, owner, ability, position, direction)
    getbase(LDBear).constructor(self, round, "ld_bear", position, owner.unit:GetTeamNumber())

    self.ability = ability
    self.owner = owner.owner
    self.hero = owner
    self.size = 128
    self.start = position
    self.direction = direction
    self.removeOnDeath = false
    self.attacking = nil
    self.collisionType = COLLISION_TYPE_INFLICTOR

    self:SetFacing(direction)
    self:AddNewModifier(self.hero, nil, "modifier_ld_bear", { duration = 3 })

    if owner.owner then
        self:GetUnit():SetControllableByPlayer(owner.owner.id, true)
    end

    local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_blink_start.vpcf", PATTACH_ABSORIGIN, self:GetUnit())
    ParticleManager:ReleaseParticleIndex(effect)

    self:EmitSound("Arena.LD.CastE")
end

function LDBear:GetPos()
    return self:GetUnit():GetAbsOrigin()
end

function LDBear:CollidesWith(target)
    return self.owner.team ~= target.owner.team
end

function LDBear:CollideWith(target)
    local unit = self:GetUnit()

    if not instanceof(target, Projectile) and not unit:IsStunned() and not unit:IsRooted() and not self.attacking and not target:IsAirborne() then
        local direction = (target:GetPos() - self:GetPos())
        local distance = direction:Length2D()

        ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP })

        self:FindModifier("modifier_ld_bear"):SetDuration(0.25, false)
        self:SetFacing(direction:Normalized())
        self.attacking = target
        self.collisionType = COLLISION_TYPE_RECEIVER
        self:EmitSound("Arena.LD.HitE")

        StartAnimation(unit, { duration = 0.25, activity = ACT_DOTA_ATTACK, rate = 1.5 })
    end
end

function LDBear:Update()
    getbase(LDBear).Update(self)

    if self.falling then
        return
    end

    if self:FindModifier("modifier_ld_bear"):GetRemainingTime() <= 0 then
        if self.attacking and self.attacking:Alive() then
            local distance = (self.attacking:GetPos() - self:GetPos()):Length2D()

            if distance <= 250 then
                self.attacking:Damage(self)
                self.attacking:AddNewModifier(self.hero, self.ability, "modifier_ld_root", { duration = 1.5 })

                self:EmitSound("Arena.WK.HitQ2")
            end
        end

        self:Destroy()
        return
    end

    if self.attacking then
        if self:GetUnit():IsStunned() or self:GetUnit():IsRooted() then
            self.collisionType = COLLISION_TYPE_INFLICTOR
            self.attacking = false
        end

        return
    end

    local result = ClampToMap(self.start + self.direction * 5000)

    local firstUpdate = self.i == nil

    self.i = (self.i or 20) + 1

    if self.i % 30 == 0 or firstUpdate then
        ExecuteOrderFromTable({ UnitIndex = self:GetUnit():GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, Position = result })
    end
end

function LDBear:Damage() end