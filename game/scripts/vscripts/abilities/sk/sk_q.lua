sk_q = class({})

LinkLuaModifier("modifier_sk_q", "abilities/sk/modifier_sk_q", LUA_MODIFIER_MOTION_NONE)

function sk_q:GroundEffect(position, target, effect)
    local hero = self:GetCaster().hero
    local effect = ImmediateEffect(effect or "particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf", PATTACH_POINT, hero)
    ParticleManager:SetParticleControl(effect, 0, position)
    ParticleManager:SetParticleControl(effect, 1, target or position)
end

function sk_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local area = 250

    hero:EmitSound("Arena.SK.CastQ")

    CreateAOEMarker(hero, target, area, 1.2, Vector(212, 212, 144))

    TimedEntity(1.2, function()
        hero:StopSound("Arena.SK.CastQ")
        hero:EmitSound("Arena.SK.EndQ", target)
        hero:AreaEffect({
            ability = self,
            filter = Filters.Area(target, area),
            filterProjectiles = true,
            damage = self:GetDamage(),
            modifier = { name = "modifier_sk_q", ability = self, duration = 1.2 },
            action = function(target)
                SKUtil.AbilityHit(hero, target)
            end
        })

        ScreenShake(target, 5, 150, 0.25, 2000, 0, true)
        Spells:GroundDamage(target, area, hero)
        local index = ImmediateEffectPoint("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_ABSORIGIN, hero, target)
        ParticleManager:SetParticleControl(index, 1, Vector(area, area, area))
    end):Activate()
end

function sk_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function sk_q:GetPlaybackRateOverride()
    return 1.5
end
