sk_q = class({})

function sk_q:GroundEffect(position, target, effect)
    local hero = self:GetCaster().hero
    local effect = ImmediateEffect(effect or "particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf", PATTACH_POINT, hero)
    ParticleManager:SetParticleControl(effect, 0, position)
    ParticleManager:SetParticleControl(effect, 1, target or position)
end

function sk_q:GetBehavior()
    local burrowed = self:GetCaster():HasModifier("modifier_sk_e")

    if burrowed then
        return DOTA_ABILITY_BEHAVIOR_POINT
    end

    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function sk_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local casterPos = hero:GetPos()
    local burrowed = self:GetCaster():HasModifier("modifier_sk_e")

    if burrowed then
        local ability = self
        local target = self:GetCursorPosition()
        local direction = target - casterPos

        if direction:Length2D() == 0 then
            direction = hero:GetFacing()
        end

        local tick = 0
        local effectPrev = casterPos

        local projectileData = {}
        projectileData.owner = hero
        projectileData.from = hero:GetPos()
        projectileData.to = target
        projectileData.velocity = 900
        projectileData.distance = 2000
        projectileData.radius = 64
        projectileData.heroBehaviour = BEHAVIOUR_DEAL_DAMAGE_AND_PASS
        projectileData.onMove =
            function(self, prev, pos)
                self.passed = self.passed + (pos - prev):Length2D()

                if tick % 5 == 0 then
                    ability:GroundEffect(effectPrev, pos)
                    effectPrev = pos
                end

                tick = tick + 1

                if self.passed >= self.distance then
                    self:TargetReachedEvent()
                end
            end

        projectileData.onTargetReached =
            function (projectile)
                hero:StopSound("Arena.SK.CastQ.Sub2")
                projectile:Destroy()
            end

        Spells:CreateProjectile(projectileData)
        hero:EmitSound("Arena.SK.CastQ.Sub")
        hero:EmitSound("Arena.SK.CastQ.Sub2")
    else
        StartAnimation(self:GetCaster(), { duration = 0.3, activity = ACT_DOTA_SAND_KING_BURROW_IN, translate = "sandking_rubyspire_burrowstrike" })
        self:GroundEffect(casterPos)
        hero:EmitSound("Arena.SK.CastQ")

        Timers:CreateTimer(0.3,
            function()
                local target = casterPos + hero:GetFacing() * 350
                self:GroundEffect(target)
                StartAnimation(self:GetCaster(), { duration = 0.5, activity = ACT_DOTA_SAND_KING_BURROW_OUT, translate = "sandking_rubyspire_burrowstrike"})
                GridNav:DestroyTreesAroundPoint(target, 128, true)
                hero:FindClearSpace(target, true)
                Spells:AreaDamage(hero, target, 200)
            end
        )
    end
end
