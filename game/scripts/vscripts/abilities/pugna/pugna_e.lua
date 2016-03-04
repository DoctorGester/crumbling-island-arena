pugna_e = class({})
LinkLuaModifier("modifier_pugna_e", "abilities/pugna/modifier_pugna_e", LUA_MODIFIER_MOTION_NONE)

function pugna_e:OnToggle()
    local hero = self:GetCaster().hero
    local on = self:GetToggleState()

    if on then
        hero:AddNewModifier(hero, self, "modifier_pugna_e", {})
    else
        hero:FindModifier("modifier_pugna_e"):Destroy()
    end
    
    hero:UpdateColor()
    hero:EmitSound("Arena.Pugna.CastE")
    self:StartCooldown(self:GetCooldown(1))
end

function pugna_e:GetIntrinsicModifierName()
    return "modifier_pugna_e"
end