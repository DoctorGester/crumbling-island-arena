modifier_brew_beer = class({})

if IsClient() then
    function modifier_brew_beer:OnCreated()
        self:GetParent().beerStacks = (self:GetParent().beerStacks or 0) + 1
    end

    function modifier_brew_beer:OnDestroy()
        self:GetParent().beerStacks = math.max(0, (self:GetParent().beerStacks or 0) - 1)
    end
end

function modifier_brew_beer:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_brew_beer:IsDebuff()
    return true
end

function modifier_brew_beer:GetModifierMoveSpeedBonus_Percentage(params)
    return -7
end

function modifier_brew_beer:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end

function modifier_brew_beer:StatusEffectPriority()
    return 2
end

function modifier_brew_beer:GetStatusEffectName()
    return "particles/status_fx/status_effect_brewmaster_drunken_haze.vpcf"
end

function modifier_brew_beer:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_brew_beer:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
