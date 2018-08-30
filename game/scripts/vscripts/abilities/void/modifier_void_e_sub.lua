modifier_void_e_sub = class({})
local self = modifier_void_e_sub

if IsServer() then
    function self:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        hero:FindAbility("void_e_sub"):EndCooldown()
    end

    function self:OnDestroy()
        local hero = self:GetParent():GetParentEntity()
        hero:SwapAbilities("void_e_sub", "void_e")
    end
end

function self:IsHidden()
    return true
end