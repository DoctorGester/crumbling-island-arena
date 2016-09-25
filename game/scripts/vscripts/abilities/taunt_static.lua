taunt_static = class({})

function taunt_static:GetChannelTime()
    return self.length
end

function taunt_static:OnAbilityPhaseStart()
    local hero = self:GetCaster():GetParentEntity()

    AddAnimationTranslate(hero:GetUnit(), self.translate)

    if self.sound then
        hero:EmitSound(self.sound)
    end

    return true
end

function taunt_static:OnAbilityPhaseInterrupted()
    RemoveAnimationTranslate(self:GetCaster())
end

function taunt_static:GetCastAnimation()
    return _G[self.activity]
end

function taunt_static:OnChannelFinish()
    self:OnAbilityPhaseInterrupted()
end

function taunt_static:OnSpellStart()
    self:OnAbilityPhaseInterrupted()
end