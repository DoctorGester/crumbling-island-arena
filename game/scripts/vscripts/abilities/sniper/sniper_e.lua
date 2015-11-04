sniper_e = class({})
LinkLuaModifier("modifier_sniper_e", "abilities/sniper/modifier_sniper_e", LUA_MODIFIER_MOTION_NONE)

function sniper_e:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_sniper_e", { duration = 4 })
end

function sniper_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end