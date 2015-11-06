sniper_r = class({})
LinkLuaModifier("modifier_sniper_r", "abilities/sniper/modifier_sniper_r", LUA_MODIFIER_MOTION_NONE)

function sniper_r:OnToggle()
    local hero = self:GetCaster().hero
    local on = self:GetToggleState()

    if on then
        hero:AddNewModifier(hero, self, "modifier_sniper_r", {})
    else
        hero:RemoveModifier("modifier_sniper_r")
    end
end
