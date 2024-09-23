LycanWolf = LycanWolf or class({}, nil, UnitEntity)

function LycanWolf:constructor(round, owner, target, offsetModifier, ability)
    local direction = (target - owner:GetPos()):Normalized()
    direction = Vector(direction.y, -direction.x, 0)
    local pos = owner:GetPos() + direction * 200 * offsetModifier

    getbase(LycanWolf).constructor(self, round, "lycan_wolf", pos, owner.unit:GetTeamNumber(), true)

    self.owner = owner.owner
    self.hero = owner
    self.size = 128
    self.start = owner:GetPos()
    self.target = target
    self.offsetModifier = offsetModifier
    self.removeOnDeath = false
    self.attacking = nil
    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.startTime = GameRules:GetGameTime()
    self.ability = ability

    self:SetFacing(target - self.start)

    self:AddComponent(HealthComponent())
    self:AddNewModifier(self.hero, nil, "modifier_lycan_q", { duration = 3 })
    self:SetCustomHealth(2)
    self:EnableHealthBar()

    if owner:IsAwardEnabled() then
        local awardModel = "models/items/lycan/wolves/hunter_kings_wolves/hunter_kings_wolves.vmdl"
        
        self:GetUnit():SetModel(awardModel)
        self:GetUnit():SetOriginalModel(awardModel)
    end

    ImmediateEffect("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN, self.unit)
end

function LycanWolf:GetPos()
    return self:GetUnit():GetAbsOrigin()
end

function LycanWolf:CollidesWith(target)
    return self.owner.team ~= target.owner.team
end

function LycanWolf:CollideWith(target)
    local unit = self:GetUnit()

    if not instanceof(target, Projectile) and not instanceof(target, Obstacle) and not unit:IsStunned() and not unit:IsRooted() and not self.attacking and not target:IsAirborne() then
        local direction = (target:GetPos() - self:GetPos())
        local distance = direction:Length2D()
        
        unit:Stop()

        self:FindModifier("modifier_lycan_q"):SetDuration(0.15, false)
        self:SetFacing(direction:Normalized())
        self.attacking = target
        self.collisionType = COLLISION_TYPE_RECEIVER
        self:EmitSound("Arena.Lycan.HitQ")

        StartAnimation(unit, { duration = 0.15, activity = ACT_DOTA_ATTACK, rate = 3.0 })
    end
end

function LycanWolf:Update()
    getbase(LycanWolf).Update(self)

    if self.falling then
        return
    end

    if self:FindModifier("modifier_lycan_q"):GetRemainingTime() <= 0 then
        local blocked = self.attacking and self.attacking:AllowAbilityEffect(self, self.ability) == false

        if not blocked and self.attacking and self.attacking:Alive() then
            local distance = (self.attacking:GetPos() - self:GetPos()):Length2D()

            if distance <= 250 then
                self.attacking:Damage(self, self.ability:GetDamage())
                self:EmitSound("Arena.Lycan.HitQ2")
                LycanUtil.MakeBleed(self.hero, self.attacking)
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

    local direction = self.target - self.start
    local normal = direction:Normalized()
    local currentPosition = self:GetPos() - self.start
    local projected = (currentPosition:Length2D() + 300) * normal

    local progress = projected:Length2D() / direction:Length2D() - 2 -- graph shifting
    local y = (progress * progress) * 200
    local offset = Vector(normal.y, -normal.x) * y * self.offsetModifier
    local result = self.start + projected + offset

    if (self.i or 0) % 5 == 0 then
        self:GetUnit():MoveToPosition(result)
    end
    
    self.i = (self.i or 0) + 1
end