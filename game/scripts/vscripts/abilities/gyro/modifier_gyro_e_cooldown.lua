modifier_gyro_e_cooldown = class({})
local self = modifier_gyro_e_cooldown

function self:OnDamageReceived(source, hero)
    hero:FindAbility("gyro_e"):StartCooldown(3)
    return true
end

function self:IsHidden()
    return true
end