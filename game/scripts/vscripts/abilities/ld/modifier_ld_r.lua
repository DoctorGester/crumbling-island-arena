modifier_ld_r = class({})

function modifier_ld_r:OnCreated(kv)
    if IsServer() then
        local hero = self:GetCaster().hero

        hero:SwapAbilities("ld_q", "ld_q_sub")
        hero:SwapAbilities("ld_w", "ld_w_sub")
        hero:SwapAbilities("ld_e", "ld_e_sub")
    end
end

function modifier_ld_r:OnDestroy(kv)
    if IsServer() then
        local hero = self:GetCaster().hero

        hero:SwapAbilities("ld_q_sub", "ld_q")
        hero:SwapAbilities("ld_w_sub", "ld_w")
        hero:SwapAbilities("ld_e_sub", "ld_e")
    end
end

function modifier_ld_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_MODEL_CHANGE
    }

    return funcs
end

function modifier_ld_r:GetModifierMoveSpeedOverride(params)
    return 300
end

function modifier_ld_r:GetModifierModelChange()
    return "models/heroes/lone_druid/true_form.vmdl"
end