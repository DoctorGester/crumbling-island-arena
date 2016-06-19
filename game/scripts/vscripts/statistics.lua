Statistics = Statistics or class({})

function Statistics:constructor(players)
	self.stats = {}

	for _, player in pairs(players) do
		self.stats[player.id] = {}
	end
end

function Statistics:IncreaseValue(player, value, amount)
	if not player or not self.stats[player.id] then
		return
	end

	self.stats[player.id][value] = (self.stats[player.id][value] or 0) + amount
end

function Statistics:IncreaseRoundsWon(player)
	self:IncreaseValue(player, "roundsWon", 1)
end

function Statistics:IncreaseDamageDealt(player)
	self:IncreaseValue(player, "damageDealt", 1)
end

function Statistics:IncreaseGroundDamageDealt(player)
	self:IncreaseValue(player, "groundDamageDealt", 1)
end

function Statistics:IncreaseHealingReceived(player)
	self:IncreaseValue(player, "healingReceived", 1)
end

function Statistics:IncreaseProjectilesFired(player)
	self:IncreaseValue(player, "projectilesFired", 1)
end

function Statistics:IncreaseFBs(player)
	self:IncreaseValue(player, "firstBloods", 1)
end

function Statistics:IncreaseMVPs(player)
	self:IncreaseValue(player, "mvps", 1)
end

function Statistics:IncreaseKills(player)
	self:IncreaseValue(player, "kills", 1)
end

function Statistics:AddPlayedHero(player, heroName)
	if not player then
		return
	end
	
	player = player.id

	local set = self.stats[player].playedHeroes

	if not set then
		set = {}
		self.stats[player].playedHeroes = set
	end

	set[heroName] = (set[heroName] or 0) + 1
end

function Statistics.MergeTables(source, target)
	for key, value in pairs(source) do
		local currentValue = target[key]

		if type(value) == "number" then
			target[key] = (currentValue or 0) + value
		end

		if type(value) == "table" then
			if not currentValue then
				currentValue = {}
				target[key] = currentValue
			end

			Statistics.MergeTables(value, currentValue)
		end
	end
end

function Statistics:Add(statistics)
	for player, stats in pairs(statistics.stats) do
		Statistics.MergeTables(stats, self.stats[player])
	end
end