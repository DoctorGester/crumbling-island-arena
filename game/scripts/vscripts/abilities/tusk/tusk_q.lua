tusk_q = class({})

function tusk_q:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    local pos = hero:GetPos()

    if hero:AreaEffect({
        filter = Filters.Cone(pos, 350, direction, math.pi),
        sound = "Arena.Tusk.HitQ",
        damage = true,
        action = function(target)
            local effectPos = target:GetPos() + Vector(0, 0, 64)
            local direction = (pos - effectPos):Normalized()
            local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, target:GetUnit())
            ParticleManager:ReleaseParticleIndex(effect)

            Knockback(target, self, target:GetPos() - hero:GetPos(), 300, 1000)
        end
    }) then
        ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)
    end

    hero:EmitSound("Arena.Tusk.CastQ")
end

function tusk_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_5
end

function tusk_q:GetPlaybackRateOverride()
    return 2.0
end