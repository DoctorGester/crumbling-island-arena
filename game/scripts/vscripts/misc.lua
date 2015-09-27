Misc = class({})

function Misc:CreateStormRemnant(owner, location, facing)
	local dummy = CreateUnitByName(owner:GetName(), location, false, owner, nil, owner:GetTeamNumber())
	local effectPath = "particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf"
	dummy:SetForwardVector(facing)
	dummy:AddNewModifier(owner, nil, "modifier_remnant", { effect = effectPath })
	AddLevelOneAbility(dummy, "storm_spirit_q_remnant")

	if not owner.remnants then
		owner.remnants = {}
	end

	table.insert(owner.remnants, dummy)
end


function Misc:DestroyStormRemnant(owner, remnant)
	if not owner.lastRemnants then
		owner.lastRemnants = {}
	end

	table.insert(owner.lastRemnants, { position = remnant:GetAbsOrigin(), facing = remnant:GetForwardVector() })

	if #owner.lastRemnants > 3 then
		table.remove(owner.lastRemnants, 1)
	end

	remnant:RemoveSelf()

	for key, value in pairs(owner.remnants) do
		if value == remnant then
			table.remove(owner.remnants, key)
			break
		end
	end
end

function Misc:FindClosestStormRemnant(owner, point)
	if owner.remnants then
		table.sort(owner.remnants, 
			function(first, second)
				local l1 = (point - first:GetAbsOrigin()):Length2D()
				local l2 = (point - second:GetAbsOrigin()):Length2D()
				return l1 < l2
		 	end
		 )

		return owner.remnants[1]
	end

	return nil
end

function Misc:HasRemnants(owner)
	return owner.remnants and #owner.remnants > 0
end

function Misc:RetrievePAWeapon(hero)
	hero:SwapAbilities("pa_q", "pa_q_sub", true, false)
	hero:SwapAbilities("pa_w", "pa_w_sub", true, false)

	if hero.inFirstJump then
		hero:SwapAbilities("pa_e", "pa_e_sub", false, true)
	end

	hero.paQProjectile = nil
end

function Misc:RemovePAWeapon(hero)
	hero:SwapAbilities("pa_q", "pa_q_sub", false, true)
	hero:SwapAbilities("pa_w", "pa_w_sub", false, true)
	hero:SwapAbilities("pa_e", "pa_e_sub", true, false)
	hero:FindAbilityByName("pa_q_sub"):StartCooldown(1.5)
	hero:FindAbilityByName("pa_q_sub"):SetActivated(true)
end

function Misc:DestroyPAWeapon(hero)
	hero:SwapAbilities("pa_q", "pa_q_sub", true, false)
	hero:FindAbilityByName("pa_q"):StartCooldown(3)
	hero.paQProjectile = nil

	Timers:CreateTimer(3, 
		function()
			hero:SwapAbilities("pa_w", "pa_w_sub", true, false)
		end
	)
end

function Misc:GetPASpeedMultiplier(projectile)
	if projectile.owner:FindModifierByName("modifier_pa_r") then
		return 2
	end

	return 1
end

function Misc:SetUpPAProjectile(projectileData)
	projectileData.heroCondition =
		function(self, target, prev, pos)
			return SegmentCircleIntersection(prev, pos, target.hero:GetAbsOrigin(), self.radius)
		end

	projectileData.heroBehaviour =
		function(self, target)
			if self.gracePeriod[target] == nil or self.gracePeriod[target] <= 0 then
				if self.owner == target then
					Misc:RetrievePAWeapon(self.owner)
					return true
				else
					Spells:ProjectileDamage(self, target)
					self.gracePeriod[target] = 30
				end
			end

			return false
		end

	projectileData.onMove = 
		function(self, prev, cur)
			for target, time in pairs(self.gracePeriod) do
				self.gracePeriod[target] = time - 1
			end
		end

	projectileData.onProjectileCollision = 
		function(self, second)
			Misc:DestroyPAWeapon(self.owner)
		end
end

function Misc:CleanUpRound()
	local round = GameRules.GameMode.Round

	for _, player in pairs(round.Players) do
		if player.hero.remnants then
			for _, remnant in pairs(player.hero.remnants) do
				remnant:RemoveSelf()
			end

			player.hero.remnants = nil
			player.hero.lastRemnants = nil
		end
	end

	for _, projectile in pairs(Projectiles) do
		projectile:Destroy()
	end
end