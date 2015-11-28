modifier_lycan_r = class({})

function modifier_lycan_r:OnCreated(kv)
    if IsServer() then
        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(index, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

        ImmediateEffect("particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    end
end

function modifier_lycan_r:OnDestroy(kv)
    if IsServer() then
        ImmediateEffect("particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    end
end

function modifier_lycan_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_MOVESPEED_MAX
    }

    return funcs
end

function modifier_lycan_r:GetModifierMoveSpeed_Max(params)
    return 1000
end

function modifier_lycan_r:GetModifierMoveSpeedOverride(params)
    return 700
end

function modifier_lycan_r:GetModifierModelChange()
    return "models/heroes/lycan/lycan_wolf.vmdl"
end