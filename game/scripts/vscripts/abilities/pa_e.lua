pa_e = class({})

LinkLuaModifier("modifier_pa_e", "abilities/modifier_pa_e", LUA_MODIFIER_MOTION_NONE)

function pa_e:EndJump(self)
	local caster = self:GetCaster()

	caster:SwapAbilities("pa_e", "pa_e_sub", true, false)
	caster:RemoveModifierByName("modifier_pa_e")
end

function pa_e:OnSpellStart()
	local caster = self:GetCaster()
	local facing = caster:GetForwardVector()

	caster:AddNewModifier(caster, self, "modifier_pa_e", {})
	StartAnimation(caster, { duration=2.5, activity=ACT_DOTA_CAST_ABILITY_2 })

	local heightFunc = 
		function (from, to, result)
			return (result - to):Length2D() / 300 * 110
		end

	local dashData = {}
	dashData.unit = caster
	dashData.to = caster:GetAbsOrigin() + facing * 400
	dashData.velocity = 1000
	dashData.onArrival = 
		function (unit)
			caster.inFirstJump = false

			if caster.jumpSecondTime then
				StartAnimation(caster, { duration=2.5, activity=ACT_DOTA_CAST_ABILITY_2 })

				local secondDashData = {}
				secondDashData.unit = caster
				secondDashData.to = caster:GetAbsOrigin() + facing * 420
				secondDashData.velocity = 1000
				--secondDashData.heightFunction = heightFunc
				secondDashData.onArrival = 
					function (unit)
						caster.jumpSecondTime = false

						pa_e:EndJump(self)
					end

				Spells:Dash(secondDashData)
			else
				pa_e:EndJump(self)
			end
		end

	--dashData.heightFunction = heightFunc

	caster.inFirstJump = true
	Spells:Dash(dashData)

	if caster.paQProjectile == nil then
		caster:SwapAbilities("pa_e", "pa_e_sub", false, true)
		caster:FindAbilityByName("pa_e_sub"):SetActivated(true)
	end
end

function pa_e:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end