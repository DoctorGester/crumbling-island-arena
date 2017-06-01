taunt_moving = class({})

function taunt_moving:OnSpellStart()
    AddAnimationTranslate(self:GetCaster(), self.translate, self.length)
    self:GetCaster():StartGesture(_G[self.activity])

    if self.sound then
        self:GetCaster():EmitSound(self.sound)
    end
end

function taunt_moving:ProcsMagicStick()
    return false
end