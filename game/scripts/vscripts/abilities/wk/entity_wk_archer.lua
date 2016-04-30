WKArcher = WKArcher or class({}, nil, UnitEntity)

function WKArcher:constructor(round, owner, ability, position, target, speed)
    getbase(WKArcher).constructor(self, round, "wk_archer", position, owner.unit:GetTeamNumber())

    self.ability = ability
    self.owner = owner.owner
    self.hero = owner
    self.size = 64
    self.start = position
    self.target = target
    self.removeOnDeath = false

    self:SetFacing((target - position):Normalized() + Vector(0, 0, 0.5))
    self:AddNewModifier(self.hero, nil, "modifier_wk_skeleton", { duration = 1.5 * speed })

    if owner.owner then
        self:GetUnit():SetControllableByPlayer(owner.owner.id, true)
    end

    StartAnimation(self:GetUnit(), { duration = 1.5 * speed, activity = ACT_DOTA_ATTACK, rate = 0.5 })

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetUnit())
    ParticleManager:SetParticleControlEnt(particle, 1, self:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetUnit():GetOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)
end

function WKArcher:GetPos()
    return self:GetUnit():GetAbsOrigin()
end

function WKArcher:CollidesWith(target)
    return false
end

function WKArcher:Update()
    getbase(WKArcher).Update(self)

    if self.falling then
        return
    end

    if self:FindModifier("modifier_wk_skeleton"):GetRemainingTime() <= 0 then
        self:EmitSound("Arena.WK.CastW2")

        PointTargetProjectile(self.round, {
            owner = self.hero,
            from = self:GetPos() + Vector(0, 0, 128),
            to = self.target,
            speed = 1800,
            parabola = 600,
            graphics = "particles/wk_w/wk_w.vpcf",
            hitCondition = 
                function(self, target)
                    return false
                end,
            targetReachedFunction =
                function(projectile)
                    local sound = "Arena.WK.HitW"
                    local hit = self.hero:AreaEffect({
                        filter = Filters.Area(self.target, 200),
                        filterProjectiles = true,
                        damage = true,
                        modifier = { name = "modifier_wk_w", duration = 2.0, ability = self.ability }
                    })

                    if hit then
                        sound = "Arena.WK.HitW2"
                    end

                    ScreenShake(self.target, 5, 150, 0.25, 2000, 0, true)
                    self:EmitSound(sound)
                end
        }):Activate()

        self:Destroy()
        return
    end
end

function WKArcher:Remove()
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death.vpcf", PATTACH_ABSORIGIN, self:GetUnit())
    ParticleManager:ReleaseParticleIndex(particle)

    self:GetUnit():AddNoDraw()

    getbase(WKArcher).Remove(self)
end