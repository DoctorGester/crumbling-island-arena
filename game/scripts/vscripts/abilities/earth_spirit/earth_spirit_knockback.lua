EarthSpiritKnockback = EarthSpiritKnockback or class({}, nil, SoftKnockback)

function EarthSpiritKnockback:constructor(ability, hero, source, direction, force, params)
	params = params or {}

	if instanceof(hero, EarthSpiritRemnant) then
		params.hitParams = {
			ability = self,
			modifier = { name = "modifier_stunned_lua", ability = ability, duration = 0.7 },
			filter = function(target) return target ~= source end,
			knockback = {
				direction = function() return self.direction end,
				force = function(victim)
					if self.direction:Dot((victim:GetPos() - hero:GetPos()):Normalized()) < 1.0 then
						return 50
					end

					return 0
				end,
				decrease = 3
			}
		}
	else
		params.hitParams = {
			ability = self,
			filter = function(target) return instanceof(target, EarthSpiritRemnant) end,
			action = function(remnant)
				if hero:AllowAbilityEffect(source, ability) then
					hero:AddNewModifier(source, ability, "modifier_stunned_lua", { duration = 0.7 })
				end
			end
		}
	end

	getbase(EarthSpiritKnockback).constructor(self, hero, source, direction, force, params)

	self.particle = FX("particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hero, {
		cp1 = self.hero:GetPos(),
		cp4 = self.hero:GetPos(),
		release = false
	})
end

function EarthSpiritKnockback:Update()
	getbase(EarthSpiritKnockback).Update(self)

	ParticleManager:SetParticleControlForward(self.particle, 3, self.direction:Normalized())
end

function EarthSpiritKnockback:End(...)
	getbase(EarthSpiritKnockback).End(self, ...)

	ResolveNPCPositions(self.hero:GetPos(), 200)

	DFX(self.particle)
end
