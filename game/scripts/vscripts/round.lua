GRACE_TIME = 1

if Round == nil then
	Round = class({})
end

function Round:Setup(level, players, gameItems, availableHeroes)
	self.StageTwoTimer = 0
	self.StageThreeTimer = 0
	self.UltsTimer = 0
	self.SuddenDeathTimer = 0

	self.StageTwoTimerTime = 500
	self.StageThreeTimerTime = 800
	self.UltsTimerTime = 700
	self.SuddenDeathTimerTime = 1200

	self.Stage = 1

	self.Winner = nil

	self.Level = level
	self.Players = players
	self.GameItems = gameItems
	self.AvailableHeroes = availableHeroes

	self.SpawnPoints = {}

	for i = 0, 7 do
		self.SpawnPoints[i] = "spawn"..i
	end
end

function Round:CheckEndConditions()
	local amountAlive = 0
	local lastAlive = nil

	for _, player in pairs(self.Players) do
		if player.hero:Alive() then
			amountAlive = amountAlive + 1
			lastAlive = player
		end
	end

	if amountAlive == 0 then
		self.Winner = nil
		self:EndRound()
	end

	if amountAlive == 1 then
		self.Winner = lastAlive
		self:EndRound()
	end
end

function Round:EndRound()
	for _, player in pairs(self.Players) do
		player.hero.protected = true
	end

	Timers:CreateTimer(function ()
		Timers:RemoveTimer("GameTimers")
		Timers:RemoveTimer("SuddenDeathPeriodic")
	end)

	Timers:CreateTimer(GRACE_TIME, function()
		Misc:CleanUpRound() -- Removing spell stuff
		self.Callback()
	end)
end

function Round:Update()
	local someoneDied = false

	for _, player in pairs(self.Players) do
	    local hero = player.hero

	    if hero ~= nil then
		    if not hero.falling then
		    	if self.Level:TestOutOfMap(hero, self.Stage) then
		    		hero:StartFalling()
		    	end
		   	else
				local result = hero:UpdateFalling()

				if result then
					CustomGameEventManager:Send_ServerToPlayer(player.player, "hero_falls", {})

					someoneDied = true
				end
		   	end
	   	end
	end

	if someoneDied then
		self:CheckEndConditions()
	end
end

function Round:CreateHeroes()
	Shuffle(self.SpawnPoints)

	for i, player in pairs(self.Players) do
		local oldHero = player.hero

		PrecacheUnitByNameAsync(player.selectedHero,
			function ()
				local hero = Hero()
				hero:SetUnit(PlayerResource:ReplaceHeroWith(i, player.selectedHero, 0, 0))
				oldHero:Delete()

				--LoadDefaultHeroItems(player.hero, self.GameItems)
				local ultimate = self.AvailableHeroes[hero:GetName()].ultimate
				hero:Setup(ultimate)
				hero:SetPlayer(player)

				local spawnPoint = Entities:FindAllByName(self.SpawnPoints[i])[1]
				hero:SetPos(spawnPoint:GetAbsOrigin())

				player.hero = hero

				CustomGameEventManager:Send_ServerToPlayer(player.player, "update_heroes", {})
			end
		, i)
	end
end

function Round:UpdateTimers()
	CustomNetTables:SetTableValue("main", "timers", { 
		stageTwo = self.StageTwoTimer,
		stageThree = self.StageThreeTimer,
		ults = self.UltsTimer,
		suddenDeath = self.SuddenDeathTimer
	});
end

function Round:DealDamage(attacker, target, checkForEnd)
	if target == nil then return end
	if attacker == nil then attacker = target end

	if not target:Alive() or target.protected or target.falling then
		return
	end

	local damageTable = {
		victim = target.unit,
		attacker = attacker.unit,
		damage = 1,
		damage_type = DAMAGE_TYPE_PURE,
	}
	 
	ApplyDamage(damageTable)

	CustomGameEventManager:Send_ServerToPlayer(target.player.player, "hero_takes_damage", {})

	if checkForEnd then
		self:CheckEndConditions()
	end
end

function Round:Heal(target)
	target:Heal()

	CustomGameEventManager:Send_ServerToPlayer(target.player, "hero_healed", {})
end

function Round:Reset()
	if self.Stage == 2 then
		self.Level:SwapLayers("InfoLayer2", "InfoLayer1")
	end

	if self.Stage == 3 then
		self.Level:SwapLayers("InfoLayer3", "InfoLayer1")
	end

	self.Stage = 1

	self.Level:EnableObstructors(Entities:FindAllByClassname("point_simple_obstruction"), false)

	GridNav:RegrowAllTrees()

	for _, player in pairs(self.Players) do
	    player.hero:Hide()
	end
end

function Round:EnableSuddenDeath()
	Timers:CreateTimer("SuddenDeathPeriodic", {
		endTime = 1,
		callback = function ()
			for _, player in pairs(self.Players) do
				self:DealDamage(nil, player, false)
			end

			self:CheckEndConditions()

			return 1
		end
	})
end

function Round:Start(callback)
	self.Stage = 1
	self.Callback = callback

	self.StageTwoTimer = self.StageTwoTimerTime
	self.StageThreeTimer = self.StageThreeTimerTime
	self.UltsTimer = self.UltsTimerTime
	self.SuddenDeathTimer = self.SuddenDeathTimerTime

	self:UpdateTimers()

	Timers:CreateTimer("GameTimers", {
		callback = function ()
			self.StageTwoTimer = math.max(-1, self.StageTwoTimer - 1)
			self.StageThreeTimer = math.max(-1, self.StageThreeTimer - 1)
			self.UltsTimer = math.max(-1, self.UltsTimer - 1)
			self.SuddenDeathTimer = math.max(-1, self.SuddenDeathTimer - 1)

			-- TODO remove corpses if out of the map when layer changes
			if self.StageTwoTimer == 0 then
				self.Level:SwapLayers("InfoLayer1", "InfoLayer2")
				self.Level:EnableObstructors(Entities:FindAllByName(SECOND_STAGE_OBSTRUCTOR), true)

				self.Stage = 2
			end

			if self.StageThreeTimer == 0 then
				self.Level:SwapLayers("InfoLayer2", "InfoLayer3")
				self.Level:EnableObstructors(Entities:FindAllByName(THIRD_STAGE_OBSTRUCTOR), true)

				self.Stage = 3
			end

			if self.UltsTimer == 0 then
				for _, player in pairs(self.Players) do
	    			local hero = player.hero
	    			local ultimate = self.AvailableHeroes[hero:GetName()].ultimate

	    			hero:EnableUltimate(ultimate)

	    			CustomGameEventManager:Send_ServerToAllClients("ultimates_enabled", {})
				end
			end

			if self.SuddenDeathTimer == 0 then
				self:EnableSuddenDeath()
			end

			self:UpdateTimers()

			return 0.1
		end
	})
end