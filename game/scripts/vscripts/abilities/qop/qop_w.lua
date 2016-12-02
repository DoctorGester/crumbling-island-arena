qop_w = class({})

LinkLuaModifier("modifier_qop_w", "abilities/qop/modifier_qop_w", LUA_MODIFIER_MOTION_NONE)

function qop_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 700)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    local effect = ParticleManager:CreateParticle("particles/qop_w/qop_w.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
    ParticleManager:ReleaseParticleIndex(effect)

    local faceFilter = function(victim)
        return victim:GetFacing():Dot(direction) < 0
    end

    hero:AreaEffect({
        onlyHeroes = true,
        filter = Filters.Cone(hero:GetPos(), 700, direction, math.pi / 2) + faceFilter,
        modifier = { name = "modifier_qop_w", duration = 1.5, ability = self }
    })

    hero:EmitSound("Arena.QOP.CastW")

    hero:FindAbility("qop_r"):AbilityUsed(self)
end

function qop_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function qop_w:GetPlaybackRateOverride()
    return 1.5
end