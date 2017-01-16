modifier_undying_r = class({})
self = modifier_undying_r

if IsServer() then
    function self:OnCreated()
        local hero = self:GetParent():GetParentEntity()

        hero:SwapAbilities("undying_q", "undying_q_sub")
        hero:FindAbility("undying_w"):SetActivated(false)
        hero:FindAbility("undying_e"):SetActivated(false)
        hero:FindAbility("undying_r"):SetActivated(false)
    end

    function self:OnDestroy()
        local hero = self:GetParent():GetParentEntity()

        hero:SwapAbilities("undying_q_sub", "undying_q")
        hero:FindAbility("undying_w"):SetActivated(true)
        hero:FindAbility("undying_e"):SetActivated(true)
        hero:FindAbility("undying_r"):SetActivated(true)

        local shield = hero:FindModifier("modifier_undying_q_health")

        if shield then
            shield:Destroy()
        end
    end
end

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MODEL_CHANGE
    }

    return funcs
end

function self:GetModifierMoveSpeedOverride(params)
    return 450 + self:GetCaster():GetModifierStackCount("modifier_undying_q_health", self:GetCaster()) * 20
end

function self:GetModifierModelChange()
    return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function self:GetActivityTranslationModifiers()
    return "haste"
end

function self:RemoveOnDeath()
    return false
end