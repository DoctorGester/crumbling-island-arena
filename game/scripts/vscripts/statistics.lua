Statistics = Statistics or {}

function Statistics.Init(players)
	Statistics.stats = {}

	for _, player in pairs(players) do
		Statistics.stats[player.id] = {}
	end
end

function Statistics.IncreaseValue(player, value, amount)
	Statistics.stats[player.id][value] = (Statistics.stats[player.id][value] or 0) + amount
end

function Statistics.IncreaseRoundsWon(player)
	Statistics.IncreaseValue(player, "roundsWon", 1)
end

function Statistics.IncreaseDamageDealt(player)
	Statistics.IncreaseValue(player, "damageDealt", 1)
end

function Statistics.IncreaseGroundDamageDealt(player)
	Statistics.IncreaseValue(player, "groundDamageDealt", 1)
end

function Statistics.IncreaseHealingReceived(player)
	Statistics.IncreaseValue(player, "healingReceived", 1)
end

function Statistics.IncreaseProjectilesFired(player)
	Statistics.IncreaseValue(player, "projectilesFired", 1)
end

function Statistics.AddPlayedHero(player, heroName)
	player = player.id

	local set = Statistics.stats[player].playedHeroes

	if not set then
		set = {}
		Statistics.stats[player].playedHeroes = set
	end

	set[heroName] = (set[heroName] or 0) + 1
end