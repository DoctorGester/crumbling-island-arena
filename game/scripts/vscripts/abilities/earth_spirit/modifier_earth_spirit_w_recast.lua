modifier_earth_spirit_w_recast = class({})

function modifier_earth_spirit_w_recast:IsHidden()
    return true
end

if IsServer() then
    function modifier_earth_spirit_w_recast:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        hero:SwapAbilities("earth_spirit_w", "earth_spirit_w_sub")
        hero:FindAbility("earth_spirit_w_sub"):StartCooldown(0.1)
    end

    function modifier_earth_spirit_w_recast:OnDestroy()
        local hero = self:GetParent():GetParentEntity()

        hero:SwapAbilities("earth_spirit_w_sub", "earth_spirit_w")
    end
end