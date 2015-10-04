storm_spirit_e = class({})
LinkLuaModifier("modifier_storm_spirit_e", "abilities/storm_spirit/modifier_storm_spirit_e", LUA_MODIFIER_MOTION_NONE)

function storm_spirit_e:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local remnant = Misc:FindClosestStormRemnant(caster, target)

	if remnant then
		caster:AddNewModifier(caster, self, "modifier_storm_spirit_e", {})
		caster:SetForwardVector((target - caster:GetAbsOrigin()):Normalized())
		caster:EmitSound("Hero_StormSpirit.BallLightning")
		caster:EmitSound("Hero_StormSpirit.BallLightning.Loop")

		local dashData = {}
		dashData.unit = caster
		dashData.to = remnant:GetAbsOrigin()
		dashData.velocity = 1200
		dashData.onArrival = 
			function (unit)
				caster:StopSound("Hero_StormSpirit.BallLightning.Loop")
				unit:RemoveModifierByName("modifier_storm_spirit_e")
				Misc:DestroyStormRemnant(unit, remnant)
			end

		Spells:Dash(dashData)
	end
end

function storm_spirit_e:CastFilterResultLocation(location)
	-- Remnant data can't be accessed on the client
	if not IsServer() then return UF_SUCCESS end

	if not Misc:HasRemnants(self:GetCaster()) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function storm_spirit_e:GetCustomCastErrorLocation(location)
	if not IsServer() then return "" end

	if not Misc:HasRemnants(self:GetCaster()) then
		return "#dota_hud_error_cant_cast_no_remnants"
	end

	return ""
end