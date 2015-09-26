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
			local d = (from - to):Length2D()
			local x = (from - result):Length2D()
			return ParabolaZ(50, d, x)
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

				local facing = caster:GetForwardVector()
				local secondDashData = {}
				secondDashData.unit = caster
				secondDashData.to = caster:GetAbsOrigin() + facing * 420
				secondDashData.velocity = 1000
				secondDashData.heightFunction = heightFunc
				secondDashData.onArrival = 
					function (unit)
						caster.jumpSecondTime = false

						pa_e:EndJump(self)
					end

				-- Leaving prop
				local prop = SpawnEntityFromTableSynchronous("prop_dynamic", { model = "models/heroes/phantom_assassin/phantom_assassin_weapon.vmdl" })
				local facingAngle = math.deg(math.atan2(facing.y, facing.x)) + 90
				local qangle = QAngle(90, 0, facingAngle)
				prop:SetAbsOrigin(caster:GetAbsOrigin())
				prop:SetAngles(qangle.x, qangle.y, qangle.z)

				Misc:RemovePAWeapon(caster)

				caster.paQProp = prop

				Timers:CreateTimer(0.2,
					function()
						Spells:Dash(secondDashData)
					end
				)
			else
				pa_e:EndJump(self)
			end
		end

	dashData.heightFunction = heightFunc

	caster.inFirstJump = true

	Timers:CreateTimer(0.3,
		function()
			Spells:Dash(dashData)
		end
	)

	if caster.paQProjectile == nil and caster.paQProp == nil then
		caster:SwapAbilities("pa_e", "pa_e_sub", false, true)
		caster:FindAbilityByName("pa_e_sub"):SetActivated(true)
	end
end