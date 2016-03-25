lycan_e = class({})

LinkLuaModifier("modifier_lycan_e", "abilities/lycan/modifier_lycan_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lycan_e_silence", "abilities/lycan/modifier_lycan_e_silence", LUA_MODIFIER_MOTION_NONE)

function lycan_e:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AreaEffect({
        filter = Filters.Area(hero:GetPos(), 350),
        modifier = { name = "modifier_lycan_e", ability = self, duration = 2.0 }
    })

    ImmediateEffect("particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf", PATTACH_ABSORIGIN, hero)
    hero:EmitSound("Arena.Lycan.CastE")
end

function lycan_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end