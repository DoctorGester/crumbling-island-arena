undying_r = class({})
LinkLuaModifier("modifier_undying_r", "abilities/undying/modifier_undying_r", LUA_MODIFIER_MOTION_NONE)

function undying_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    for _, modifier in pairs(self:GetCaster():FindAllModifiersByName("modifier_undying_q_health")) do
        modifier:Destroy()
    end

    hero:AddNewModifier(hero, self, "modifier_undying_r", {})
    hero:SwapAbilities("undying_q", "undying_q_sub")
    hero:SwapAbilities("undying_w", "undying_w_sub")
    hero:FindAbility("undying_e"):SetHidden(true)
    hero:FindAbility("undying_r"):SetHidden(true)
    hero:SetHealth(3)
    hero:EmitSound("Arena.Undying.CastR")

    FX("particles/units/heroes/hero_undying/undying_fg_transform.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, {})
end

function undying_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end
