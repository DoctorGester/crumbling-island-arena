require('lib/timers')
require('lib/animations')
require('misc')
require('util')

require('dynamic_entity')
require('hero')
require('player')
require('level')
require('hero_selection')
require('round')

require('spells')
require('debug_util')

STATE_NONE = 0
STATE_HERO_SELECTION = 1
STATE_ROUND_IN_PROGRESS = 2
STATE_ROUND_ENDED = 3

ROUND_ENDING_TIME = 5
FIXED_DAY_TIME = 0.27

THINK_PERIOD = 0.05

DUMMY_HERO = "npc_dota_hero_wisp"

if GameMode == nil then
	GameMode = class({})
end

function Precache(context)
	PrecacheResource("model", "models/development/invisiblebox.vmdl", context)
	PrecacheResource("particle", "particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf", context)
	PrecacheResource("soundfile", "soundevents/custom_sounds.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_earth_spirit.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context)

	LinkLuaModifier("modifier_invis_fade", "abilities/modifier_invis_fade", LUA_MODIFIER_MOTION_NONE)
end

function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:SetupMode()
end

function GameMode:OnThink()
	if GameRules:IsGamePaused() == true then
        return
    end

    GameRules:SetTimeOfDay(FIXED_DAY_TIME)

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and self.State == STATE_ROUND_IN_PROGRESS then
		self.Round:Update()
    end

    return THINK_PERIOD
end

function GameMode:EventPlayerConnected(args)
	local playerEntity = EntIndexToHScript(args.index + 1)

	if not IsValidEntity(playerEntity) then
		return
	end

	PlayerResource:SetCustomTeamAssignment(args.index, self.Teams[args.index])
end

function GameMode:EventStateChanged(args)
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Timers:CreateTimer(1, function () self:OnGameInProgress() end)
	end
end

function GameMode:InitSettings()
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroSelectionTime(1.0)
	GameRules:SetPreGameTime(0)
	GameRules:SetPostGameTime(10.0)
	GameRules:SetTreeRegrowTime(60.0)
	GameRules:SetUseCustomHeroXPValues(true)
	GameRules:SetGoldPerTick(0)
	GameRules:SetUseBaseGoldBountyOnHeroes(true)
	GameRules:SetFirstBloodActive(false)
	GameRules:SetCustomGameSetupTimeout(0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)

	local mode = GameRules:GetGameModeEntity()

	mode:SetCustomGameForceHero(DUMMY_HERO)
	mode:SetCameraDistanceOverride(1600)
	mode:SetCustomBuybackCostEnabled(true)
	mode:SetCustomBuybackCooldownEnabled(true)
	mode:SetBuybackEnabled(false)
	mode:SetTopBarTeamValuesOverride (true)
	mode:SetUseCustomHeroLevels(true)
	mode:SetCustomHeroMaxLevel(1)
	mode:SetFogOfWarDisabled(true)

	SendToServerConsole("dota_combine_models 0")
end

function GameMode:InitEvents()
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'EventPlayerConnected'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'EventStateChanged'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameMode, 'OnPlayerPickHero'), self)
end

function GameMode:SetupMode()
	GameMode = self

	self.Players = {}
	self:SetState(STATE_HERO_SELECTION)
	self:LoadCustomHeroes()
	self:UpdateAvailableHeroesTable()

	self.Round = nil

	GameRules:GetGameModeEntity():SetThink("OnThink", self, THINK_PERIOD) 

	self:InitSettings()
	self:InitEvents()

	self.Teams = {}
	self.Teams[0] = DOTA_TEAM_GOODGUYS
	self.Teams[1] = DOTA_TEAM_BADGUYS
	self.Teams[2] = DOTA_TEAM_CUSTOM_1
	self.Teams[3] = DOTA_TEAM_CUSTOM_2
	self.Teams[4] = DOTA_TEAM_CUSTOM_3
	self.Teams[5] = DOTA_TEAM_CUSTOM_4
	self.Teams[6] = DOTA_TEAM_CUSTOM_5
	self.Teams[7] = DOTA_TEAM_CUSTOM_6
	self.Teams[8] = DOTA_TEAM_CUSTOM_7
	self.Teams[9] = DOTA_TEAM_CUSTOM_8

	self.TeamColors = {}
	self.TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }	--		Teal
	self.TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }	--		Yellow
	self.TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }	--		Orange
	self.TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }	--		Blue
	self.TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	self.TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }	--		Brown
	self.TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan
	self.TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }	--		Olive
	self.TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }	--		Purple

	for team = 0, (DOTA_TEAM_COUNT-1) do
		GameRules:SetCustomGameTeamMaxPlayers(team, 1)
		color = self.TeamColors[team]
		if color then
			SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
		end
	end
	
	local count = math.min(PlayerResource:GetPlayerCount() - 1, 7)

	for i = 0, count do
		local color = self.TeamColors[self.Teams[i]]
		PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
	end
end

function OnSelectionHeroHover(eventSourceIndex, args)
	if GameMode.State == STATE_HERO_SELECTION then
		GameMode.HeroSelection:OnHover(args)
	end
end

function OnSelectionHeroClick(eventSourceIndex, args)
	if GameMode.State == STATE_HERO_SELECTION then
		GameMode.HeroSelection:OnClick(args)
	end
end

function OnRoundEnd()
	GameMode:SetState(STATE_ROUND_ENDED)

	for _, player in pairs(GameMode.Players) do
		player.hero.protected = true
	end

	Timers:CreateTimer(ROUND_ENDING_TIME, function ()
		if GameMode.Round.Winner then
			GameMode.Round.Winner.score = GameMode.Round.Winner.score + 1
			GameMode:UpdatePlayerTable()
		end

		GameMode.Round:Reset()
		GameMode:SetState(STATE_HERO_SELECTION)
		GameMode.HeroSelection:Start(OnHeroSelectionEnd)
		end
	)
end

function OnHeroSelectionEnd()
	GameMode:SetState(STATE_ROUND_IN_PROGRESS)
	GameMode.Round:CreateHeroes()
	GameMode.Round:Start(OnRoundEnd)
end

function GameMode:UpdatePlayerTable()
	local players = {}

	for i, player in pairs(self.Players) do
		local playerData = {}
		playerData.id = i
		playerData.color = self.TeamColors[PlayerResource:GetTeam(i)]
		playerData.score = player.score

		table.insert(players, playerData)
	end

	CustomNetTables:SetTableValue("main", "players", players)
end

function GameMode:UpdateAvailableHeroesTable()
	local heroes = {}

	for name, data in pairs(GameMode.AvailableHeroes) do
		data.name = name
		table.insert(heroes, data)
	end

	CustomNetTables:SetTableValue("main", "heroes", GameMode.AvailableHeroes)
end

function GameMode:SetState(state)
	local winner = nil

	if self.Round ~= nil then
		winner = self.Round.Winner
	end

	playerData = {}

	if winner ~= nil then
		playerData.id = winner.id
		playerData.color = self.TeamColors[PlayerResource:GetTeam(winner.id)]
	else
		playerData.id = -1
	end

	self.State = state
	CustomNetTables:SetTableValue("main", "gameInfo", { state = state, roundWinner = playerData })
end

function GameMode:LoadCustomHeroes()
	GameMode.AvailableHeroes = {}

	local customHeroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	local customAbilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

	for customName, data in pairs(customHeroes) do
		if data.override_hero ~= DUMMY_HERO then
			GameMode.AvailableHeroes[data.override_hero] = { ultimate = data.Ultimate, class = data.Class, customIcons = data.CustomIcons }

			local abilities = {}
			for i = 0, 10 do
				local abilityName = data["Ability"..tostring(i)]
				if abilityName and #abilityName ~= 0 then
					local ability = {}
					ability.name = abilityName
					ability.texture = customAbilities[ability.name].AbilityTextureName

					table.insert(abilities, ability)
				end
			end

			GameMode.AvailableHeroes[data.override_hero].abilities = abilities
		end
	end
end

function GameMode:OnGameInProgress()
	print("Setting players up")

	for i = 0, DOTA_MAX_PLAYERS do
		if PlayerResource:IsValidPlayer(i) then
			self.Players[i] = Player()
			self.Players[i]:SetPlayerID(i)
			self.Players[i]:SetTeam(self.Teams[i])
		end
	end

	self:UpdatePlayerTable()

	CustomGameEventManager:RegisterListener("selection_hero_hover", OnSelectionHeroHover)
	CustomGameEventManager:RegisterListener("selection_hero_click", OnSelectionHeroClick)

	self.GameItems = nil--LoadKeyValues("scripts/items/items_game.txt").items

	self.Level = Level()

	self.HeroSelection = HeroSelection()
	self.HeroSelection:Setup(self.Players, self.AvailableHeroes, self.TeamColors)

	self.Round = Round()
	self.Round:Setup(self.Level, self.Players, self.GameItems, self.AvailableHeroes)
	self.Round:Reset()

	Debug():CheckAndEnableDebug(self)

	self:SetState(STATE_HERO_SELECTION)
	self.HeroSelection:Start(OnHeroSelectionEnd)
end

function GameMode:OnPlayerPickHero(keys)
	if keys.hero == DUMMY_HERO then
		local hero = EntIndexToHScript(keys.heroindex)

		hero:SetAbsOrigin(Vector(0, 0, 10000))
		hero:AddNoDraw()
		AddLevelOneAbility(hero, "hidden_hero")
	end
end