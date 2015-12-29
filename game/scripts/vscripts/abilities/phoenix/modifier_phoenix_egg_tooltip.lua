modifier_phoenix_egg_tooltip = class({})

function modifier_phoenix_egg_tooltip:GetTexture()
    return "phoenix_supernova"
end

function modifier_phoenix_egg_tooltip:IsHidden()
    return self:GetParent():HasModifier("modifier_phoenix_egg")
end