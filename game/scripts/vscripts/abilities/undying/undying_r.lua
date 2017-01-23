undying_r = class({})
LinkLuaModifier("modifier_undying_r", "abilities/undying/modifier_undying_r", LUA_MODIFIER_MOTION_NONE)

function undying_r:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()
    local shield = hero:FindModifier("modifier_undying_q_health")

    if shield then
        shield:SetDuration(-1, true)
    end

    hero:AddNewModifier(hero, self, "modifier_undying_r", { duration = 8.0 })
    hero:EmitSound("Arena.Undying.CastR")
end

function undying_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end
