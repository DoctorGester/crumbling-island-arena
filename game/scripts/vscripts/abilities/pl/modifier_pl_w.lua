modifier_pl_w = class({})
local self = modifier_pl_w

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function self:OnDamageReceived(source, hero)
    if source.hero then
        source = source.hero
    end

    hero:AddNewModifier(source, self:GetAbility(), "modifier_pl_w_invul", { duration = 0.25 })

    self:Destroy()

    return false
end

function self:OnModifierAdded(source, ability, modifier, params)
    return modifier == "modifier_pl_w_invul"
end

function self:GetStatusEffectName()
    return "particles/status_fx/status_effect_phantom_lancer_illstrong.vpcf"
end

function self:StatusEffectPriority()
    return 10
end

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function self:GetOverrideAnimation(params)
    return ACT_DOTA_OVERRIDE_ABILITY_2
end