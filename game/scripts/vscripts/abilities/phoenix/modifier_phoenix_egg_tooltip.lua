modifier_phoenix_egg_tooltip = class({})

function modifier_phoenix_egg_tooltip:GetTexture()
    return "phoenix_supernova"
end

function modifier_phoenix_egg_tooltip:IsHidden()
    return self:GetParent():HasModifier("modifier_phoenix_egg")
end

function modifier_phoenix_egg_tooltip:OnDamageReceived()
    local hero = self:GetParent():GetParentEntity()

    if not hero:FindModifier(EGG_MODIFIER) and hero:GetHealth() == 1 then
        hero:GetUnit():Interrupt()
        hero:AddNewModifier(hero, nil, EGG_MODIFIER, { duration = 5 })
        return false
    end
end

function modifier_phoenix_egg_tooltip:OnDamageReceivedPriority()
    return PRIORITY_POST_SHIELD_ACTION
end