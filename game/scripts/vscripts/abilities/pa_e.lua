pa_e = class({})

function pa_e:OnSpellStart()
	local caster = self:GetCaster()
	local facing = caster:GetForwardVector()
end