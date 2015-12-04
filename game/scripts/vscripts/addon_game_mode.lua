require('lib/timers')
require('lib/animations')
require("lib/vector_target")
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

THINK_PERIOD = 0.01

DUMMY_HERO = "npc_dota_hero_wisp"

if GameMode == nil then
    GameMode = class({})
end

function Precache(context)
    PrecacheResource("model", "fbx1.vmdl", context)
    PrecacheResource("model", "models/development/invisiblebox.vmdl", context)
    PrecacheResource("particle", "particles/ui/ui_generic_treasure_impact.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_tiny/tiny_avalanche.vpcf", context)
    PrecacheResource("soundfile", "soundevents/custom_sounds.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_vo_announcer.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_earth_spirit.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context)

    LinkLuaModifier("modifier_invis_fade", "abilities/modifier_invis_fade", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_blind", "abilities/modifier_blind", LUA_MODIFIER_MOTION_NONE)

    VectorTarget:Precache(context)
end

function Activate()
    GameRules.GameMode = GameMode()
    GameRules.GameMode:SetupMode()
    VectorTarget:Init()

    coroutine.create(
        function()
            local a = 10
            for i = 0, 1000000 do
                a = a + i
            end
            print("GORILLA"..tostring(a))
        end
    )
end

function GameMode:OnThink()
    if GameRules:IsGamePaused() == true then
        return
    end

    GameRules:SetTimeOfDay(FIXED_DAY_TIME)

    local now = Time()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        for _, thinker in ipairs(self.Thinkers) do
            
            if now >= thinker.next then
                thinker.next = thinker.next + thinker.period
                thinker.callback()
            end
        end
    end

    return THINK_PERIOD
end

function GameMode:EventPlayerConnected(args)
    local playerEntity = EntIndexToHScript(args.index + 1)

    if not IsValidEntity(playerEntity) then
        return
    end

    print("Player connected")
    PrintTable(args)

    local userID = args.userid

    self.Users = self.Users or {}
    self.Users[userID] = playerEntity

    PlayerResource:SetCustomTeamAssignment(args.index, self.Teams[args.index])
end

function GameMode:EventPlayerReconnected(args)
    if self.HeroSelection then
        self.HeroSelection:UpdateSelectedHeroes()
    end
end

function GameMode:EventPlayerDisconnected(args)
    if self.HeroSelection then
        self.HeroSelection:UpdateSelectedHeroes()
    end
end

function GameMode:EventStateChanged(args)
    local newState = GameRules:State_Get()

    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        self:OnGameInProgress()
    end
end

function GameMode:InitSettings()
    GameRules:SetHeroRespawnEnabled(false)
    GameRules:SetUseUniversalShopMode(false)
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
    mode:SetAnnouncerDisabled(true)
    mode:SetCustomHeroMaxLevel(1)
    --mode:SetFogOfWarDisabled(true)

    SendToServerConsole("dota_combine_models 0")
end

function GameMode:RegisterThinker(period, callback)
    local timer = {}
    timer.period = period
    timer.callback = callback
    timer.next = Time() + period

    self.Thinkers = self.Thinkers or {}

    table.insert(self.Thinkers, timer)
end

function GameMode:InitEvents()
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'EventPlayerConnected'), self)
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(self, 'EventPlayerReconnected'), self)
    ListenToGameEvent('player_disconnect', Dynamic_Wrap(self, 'EventPlayerDisconnected'), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'EventStateChanged'), self)
    ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'OnPlayerPickHero'), self)
end

function GameMode:SetupMode()
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
    self.TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }  --      Teal
    self.TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }   --      Yellow
    self.TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }  --      Pink
    self.TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }   --      Orange
    self.TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }   --      Blue
    self.TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }  --      Green
    self.TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }   --      Brown
    self.TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }  --      Cyan
    self.TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }  --      Olive
    self.TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }  --      Purple

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

function GameMode:OnRoundEnd()
    self:SetState(STATE_ROUND_ENDED)

    for _, player in pairs(self.Players) do
        player.hero.protected = true
    end

    Timers:CreateTimer(ROUND_ENDING_TIME, function ()
        if self.Round.Winner then
            self.Round.Winner.score = self.Round.Winner.score + 1
            self:UpdatePlayerTable()
        end

        self.Round:Reset()
        self:SetState(STATE_HERO_SELECTION)
        self.HeroSelection:Start(function() self:OnHeroSelectionEnd() end)
        end
    )
end

function GameMode:OnHeroSelectionEnd()
    self.Round:CreateHeroes()
    self.Round:Start(function() self:OnRoundEnd() end)
    self:SetState(STATE_ROUND_IN_PROGRESS)

    Timers:CreateTimer(1.5,
        function()
            --EmitAnnouncerSound("announcer_ann_custom_adventure_alerts_42")
            EmitAnnouncerSound("announcer_announcer_battle_begin_01")
        end
    )
end

function GameMode:UpdatePlayerTable()
    local players = {}

    for i, player in pairs(self.Players) do
        local playerData = {}
        playerData.id = i
        playerData.color = self.TeamColors[player.team]
        playerData.score = player.score

        table.insert(players, playerData)
    end

    CustomNetTables:SetTableValue("main", "players", players)
end

function GameMode:UpdateAvailableHeroesTable()
    local heroes = {}

    for name, data in pairs(self.AvailableHeroes) do
        data.name = name
        table.insert(heroes, data)
    end

    CustomNetTables:SetTableValue("main", "heroes", self.AvailableHeroes)
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
    self.AvailableHeroes = {}

    local customHeroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    local customAbilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

    for customName, data in pairs(customHeroes) do
        if data.override_hero ~= DUMMY_HERO then
            self.AvailableHeroes[data.override_hero] = { ultimate = data.Ultimate, class = data.Class, customIcons = data.CustomIcons }

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

            self.AvailableHeroes[data.override_hero].abilities = abilities
        end
    end
end

function GameMode:OnGameInProgress()
    print("Setting players up")

    local i = 0

    for id = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayer(id) then
            local player = Player()
            player:SetPlayerID(id)
            player:SetTeam(self.Teams[i])

            self.Players[player.id] = player
            i = i + 1
        end
    end

    PrintTable(self.Players)

    self:UpdatePlayerTable()
    self.GameItems = nil--LoadKeyValues("scripts/items/items_game.txt").items

    self.Level = Level()
    self.HeroSelection = HeroSelection(self.Players, self.AvailableHeroes, self.TeamColors)
    self.Round = Round(self.Level, self.Players, self.GameItems, self.AvailableHeroes)
    self.Round:Reset()

    self:RegisterThinker(1,
        function()
            if self.State == STATE_HERO_SELECTION and self.HeroSelection then
                self.HeroSelection:Update()
            end
        end
    )

    self:RegisterThinker(0.1,
        function()
            if self.State == STATE_ROUND_IN_PROGRESS then
                self.Round:Update()
            end
        end
    )

    self:RegisterThinker(0.01,
        function()
            if self.State == STATE_ROUND_IN_PROGRESS then
                self.Round:UpdateFalling()
            end
        end
    )

    Debug():CheckAndEnableDebug(self)

    self:SetState(STATE_HERO_SELECTION)
    self.HeroSelection:Start(function() self:OnHeroSelectionEnd() end)
end

function GameMode:OnPlayerPickHero(keys)
    if keys.hero == DUMMY_HERO then
        local hero = EntIndexToHScript(keys.heroindex)

        hero:SetAbsOrigin(Vector(0, 0, 10000))
        hero:AddNoDraw()
        AddLevelOneAbility(hero, "hidden_hero")
    end
end