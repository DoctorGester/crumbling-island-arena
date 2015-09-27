pa_w_sub = class({})

LinkLuaModifier("modifier_pa_w_sub", "abilities/modifier_pa_w_sub", LUA_MODIFIER_MOTION_NONE)

function pa_w_sub:OnSpellStart()
	local caster = self:GetCaster()

	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local direction = target - caster:GetOrigin()
	local ability = self

	if direction:Length2D() == 0 then
		direction = caster:GetForwardVector()
	end

	direction = direction:Normalized()

	local projectileData = {}
	projectileData.owner = caster
	projectileData.from = caster:GetOrigin()
	projectileData.to = target
	projectileData.velocity = 1200
	projectileData.graphics = "particles/pa_w_sub/pa_w_sub.vpcf"
	projectileData.distance = 800
	projectileData.radius = 48
	projectileData.heroBehaviour =
		function(self, target)
			Spells:ProjectileDamage(self, target)
			target:AddNewModifier(caster, ability, "modifier_pa_w_sub", { duration = 2 })

			return true
		end

	projectileData.initProjectile = 
		function(self)
			self.velocity = direction * projectileData.velocity
			self.passed = 0

			ParticleManager:SetParticleControl(self.effectId, 1, target)
			ParticleManager:SetParticleControl(self.effectId, 2, direction)
			ParticleManager:SetParticleControl(self.effectId, 3, target - caster:GetOrigin())
		end

	Spells:CreateProjectile(projectileData)
end

function pa_w_sub:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end