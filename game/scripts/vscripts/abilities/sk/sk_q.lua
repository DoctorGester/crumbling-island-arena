sk_q = class({})

LinkLuaModifier("modifier_sk_q", "abilities/sk/modifier_sk_q", LUA_MODIFIER_MOTION_NONE)

function sk_q:GroundEffect(position, target, effect)
    local hero = self:GetCaster().hero
    local effect = ImmediateEffect(effect or "particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf", PATTACH_POINT, hero)
    ParticleManager:SetParticleControl(effect, 0, position)
    ParticleManager:SetParticleControl(effect, 1, target or position)
end

function sk_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local area = 250

    hero:EmitSound("Arena.SK.CastQ")

    CreateAOEMarker(hero, target, area, 1.2, Vector(212, 212, 144))

    Timers:CreateTimer(1.2, function()
        hero:StopSound("Arena.SK.CastQ")
        hero:EmitSound("Arena.SK.EndQ", target)
        hero:AreaEffect({
            filter = Filters.Area(target, area),
            filterProjectiles = true,
            damage = true,
            modifier = { name = "modifier_sk_q", ability = self, duration = 1.2 }
        })

        Spells:GroundDamage(target, area)
        local index = ImmediateEffectPoint("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_ABSORIGIN, hero, target)
        ParticleManager:SetParticleControl(index, 1, Vector(area, area, area))
    end)

    if true then return end

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
        projectileData.radius = 90
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
                Spells:GroundDamage(casterPos, 256)
                self:GroundEffect(target)
                StartAnimation(self:GetCaster(), { duration = 0.5, activity = ACT_DOTA_SAND_KING_BURROW_OUT, translate = "sandking_rubyspire_burrowstrike"})
                GridNav:DestroyTreesAroundPoint(target, 128, true)
                hero:FindClearSpace(target, true)
                Spells:AreaDamage(hero, target, 200)
            end
        )
    end
end

function sk_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function sk_q:GetPlaybackRateOverride()
    return 1.5
end
