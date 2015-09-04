Misc = class({})

function Misc:CreateStormRemnant(owner, location, facing)
	local dummy = CreateUnitByName(owner:GetName(), location, false, owner, nil, owner:GetTeamNumber())
	dummy:SetForwardVector(facing)
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
end