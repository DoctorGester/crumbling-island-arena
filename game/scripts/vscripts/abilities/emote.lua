emote = class({})

function emote:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()

    hero:EmitSound(hero:GetShortName())
end

function emote:ProcsMagicStick()
    return false
end