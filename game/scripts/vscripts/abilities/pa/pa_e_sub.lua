pa_e_sub = class({})

function pa_e_sub:OnSpellStart()
    local caster = self:GetCaster()

    if caster.inFirstJump then
        caster.jumpSecondTime = true
        self:SetActivated(false)
    end
end