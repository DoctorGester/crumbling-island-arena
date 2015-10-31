cm_e_sub = class({})

function cm_e_sub:OnSpellStart()
	local hero = self:GetCaster().hero
	local icePath = hero:GetIcePath()
	
	if icePath then
		local particle = "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf"
		local deathSim = SpawnEntityFromTableSynchronous("prop_dynamic", {
			origin = hero:GetPos(),
			model = "models/heroes/crystal_maiden/crystal_maiden_deathsim.vmdl",
			DefaultAnim = "crystal_maiden_deathsim1_anim"
		})
		deathSim:SetForwardVector(hero:GetFacing())
		ImmediateEffectPoint(particle, PATTACH_CUSTOMORIGIN, hero, hero:GetPos())
		Timers:CreateTimer(5, function() deathSim:RemoveSelf() end)

		hero:FindClearSpace(icePath.position, true)
		hero:SwapAbilities("cm_e_sub", "cm_e")
		hero:EmitSound("Arena.CM.CastSubE")
		icePath:Destroy()
		ImmediateEffectPoint(particle, PATTACH_CUSTOMORIGIN, hero, hero:GetPos())
	end
end