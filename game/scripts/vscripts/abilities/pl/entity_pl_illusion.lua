EntityPLIllusion = EntityPLIllusion or class({}, nil, UnitEntity)
local self = EntityPLIllusion

function self:constructor(round, owner, target, facing, ability)
    getbase(EntityPLIllusion).constructor(self, round, "pl_illusion", target, owner.unit:GetTeamNumber())

    self.owner = owner.owner
    self.hero = owner
    self.health = 1
    self.size = 64
    self.collisionType = COLLISION_TYPE_INFLICTOR

    local unit = self:GetUnit()
    
    if owner.owner then
        unit:SetControllableByPlayer(owner.owner.id, true)
    end

    unit.hero = self

    self:AddNewModifier(self.hero, ability, "modifier_pl_illusion", {})
    self:SetFacing(facing)
    self:SetPos(target)
    self.ability = ability

    self.justSpawned = true
    self.refreshTime = GameRules:GetGameTime()

    self.removeOnDeath = false

    self:GetUnit():SetBaseMoveSpeed(600)
    self:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_SPAWN, 1.5)

    self:EmitSound("Arena.PL.Illusion")

    FX("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_illusion.vpcf", PATTACH_ABSORIGIN, self, { cp1 = self:GetPos(), release = true })
end

function self:Update()
    getbase(EntityPLIllusion).Update(self)

    if not self.falling then
        local time = GameRules:GetGameTime()

        if self.justSpawned and time - self.refreshTime > 0.6 then
            self:GetUnit():StartGesture(ACT_DOTA_IDLE)
            self:GetUnit():FadeGesture(ACT_DOTA_IDLE)
            self.justSpawned = false
            self.refreshTime = time

            if not self:HasModifier("modifier_pl_q") then
                if self.castTarget then
                    local ability = self:GetUnit():AddAbility("pl_q")
                    ability:SetLevel(1)

                    self:GetUnit():CastAbilityOnPosition(self.castTarget, ability, self.owner.id)
                elseif self.target then
                    PLIllusionDash(self, self.target, self.ability)
                end
            end
        end

        if time - self.refreshTime > 12 then
            self:Destroy()
        end
    end
end

function self:CollideWith(target)
    if target == self.hero then
        target:EmitSound("Arena.PL.HitE")
        target:AddNewModifier(target, self.ability, "modifier_pl_e_speed", { duration = 3 })
        self:Destroy()
    end
end

function self:QueueCast(target)
    self.castTarget = target
end

function self:Refresh()
    self.refreshTime = GameRules:GetGameTime()
end

function self:GetPos()
    return self:GetUnit():GetAbsOrigin()
end

function self:SetTarget(target)
    self.target = target

    if not self.justSpawned then
        if self:HasModifier("modifier_pl_e_dash") then
            self.round.spells:InterruptDashes(self)
        end

        PLIllusionDash(self, self.target, self.ability)
    end
end

function self:Remove()
    ImmediateEffectPoint("particles/units/heroes/hero_phantom_lancer/phantomlancer_illusion_destroy.vpcf", PATTACH_ABSORIGIN, self.hero, self:GetPos())
    self:GetUnit():AddNoDraw()

    getbase(EntityPLIllusion).Remove(self)
end

function self:Damage(source)
    self:Destroy()
end

function self:CollidesWith(source)
    return true
end


PLIllusionDash = PLIllusionDash or class({}, nil, Dash)

function PLIllusionDash:constructor(illusion, target, ability)
    getbase(PLIllusionDash).constructor(self, illusion, target:GetPos(), 1300, {
        forceFacing = true,
        modifier = { name = "modifier_pl_e_dash" },
        noFixedDuration = true,
        hitParams = {
            modifier = { name = "modifier_pl_e_slow", ability = ability, duration = 2.0 },
        }
    })

    self.target = target
    self.ability = ability
end

function PLIllusionDash:HasEnded()
    return (self.target:GetPos() - self.hero:GetPos()):Length2D() <= 250 or not self.target:Alive()
end

function PLIllusionDash:PositionFunction(current)
    local diff = self.target:GetPos() - current
    return current + (diff:Normalized() * self.velocity)
end

function PLIllusionDash:Update(...)
    getbase(PLIllusionDash).Update(self, ...)

    if self.hero:Alive() then
        self.tick = (self.tick or 0) + 1

        if self.tick % 5 == 0 then
            self.hero:EmitSound("Arena.PL.StepE")
        end
    end
end