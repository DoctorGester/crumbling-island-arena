pa_e_sub = class({})

function pa_e_sub:OnSpellStart()
	local caster = self:GetCaster()
	local facing = caster:GetForwardVector()
end