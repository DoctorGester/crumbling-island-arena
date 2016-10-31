modifier_gyro_q = class({})
local self = modifier_gyro_q

if IsServer() then
    function self:OnCreated()
        self:GetParent():GetParentEntity():SwapAbilities("gyro_q", "gyro_q_sub")
        self:SetStackCount(3)
    end

    function self:OnDestroy()
        local hero = self:GetParent():GetParentEntity()

        hero:SwapAbilities("gyro_q_sub", "gyro_q")
        hero:FindAbility("gyro_q"):StartCooldown(hero:FindAbility("gyro_q"):GetCooldown(1))
    end
end