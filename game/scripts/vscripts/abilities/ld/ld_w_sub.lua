ld_w_sub = class({})

LinkLuaModifier("modifier_ld_w_sub", "abilities/ld/modifier_ld_w_sub", LUA_MODIFIER_MOTION_NONE)

function ld_w_sub:OnSpellStart()
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()

    hero:AreaEffect({
        filter = Filters.Area(pos, 350),
        filterProjectiles = true,
        modifier = { name = "modifier_ld_w_sub", duration = 2.5, ability = self }
    })

    local effect = ImmediateEffect("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, pos)
    ParticleManager:SetParticleControlEnt(effect, 1, hero:GetUnit(), PATTACH_POINT_FOLLOW, "attach_mouth", pos, true)

    hero:EmitSound("Arena.LD.CastWSub")

    ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)
end

function ld_w_sub:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end