modifier_gyro_w = class({})
local self = modifier_gyro_w

if IsServer() then
    function self:OnCreated()
        local hero = self:GetParent():GetParentEntity()

        hero:SwapAbilities("gyro_w", "gyro_w_sub")
        hero:EmitSound("Arena.Gyro.CastW")
    end

    function self:OnDestroy()
        local hero = self:GetParent():GetParentEntity()

        hero:StopSound("Arena.Gyro.CastW")
        hero:SwapAbilities("gyro_w_sub", "gyro_w")
        hero:FindAbility("gyro_w"):StartCooldown(hero:FindAbility("gyro_w"):GetCooldown(1))
    end

    function self:OnDamageReceived(source, hero)
        hero:EmitSound("Arena.Gyro.HitW")
        self:Destroy()

        return false
    end

    function self:OnDamageReceivedPriority()
        return 0
    end
end

function self:GetEffectName()
    return "particles/gyro_w/gyro_w.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end
