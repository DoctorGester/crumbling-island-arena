require('lib/timers')
require('lib/animations')
require("lib/vector_target")
require('targeting_indicator')
require('util')

require('dynamic_entity')
require('unit_entity')
require('hero')
require('player')
require('level')
require('hero_selection')
require('round')

require('spells')
require('projectile')
require('dash')
require('statistics')
require('chat')
require('debug_util')

STATE_NONE = 0
STATE_HERO_SELECTION = 1
STATE_ROUND_IN_PROGRESS = 2
STATE_ROUND_ENDED = 3
STATE_GAME_OVER = 4

ROUND_ENDING_TIME = 5
FIXED_DAY_TIME = 0.27

THINK_PERIOD = 0.01

GAME_GOAL = 75

DUMMY_HERO = "npc_dota_hero_wisp"

if GameMode == nil then
    GameMode = class({})
end

function Precache(context)
    PrecacheResource("particle", "particles/cracks.vpcf", context)
    PrecacheResource("particle", "particles/targeting/aoe.vpcf", context)
    PrecacheResource("particle", "particles/targeting/cone.vpcf", context)
    PrecacheResource("particle", "particles/targeting/line.vpcf", context)
    PrecacheResource("particle", "particles/targeting/thick_line.vpcf", context)
    PrecacheResource("particle", "particles/targeting/half_circle.vpcf", context)
    PrecacheResource("particle", "particles/targeting/range.vpcf", context)
    PrecacheResource("particle", "particles/targeting/global_target.vpcf", context)
    PrecacheResource("particle", "particles/aoe_marker.vpcf", context)
    PrecacheResource("particle", "particles/econ/courier/courier_kunkka_parrot/courier_kunkka_parrot_splash.vpcf", context)
    PrecacheResource("particle", "particles/dire_fx/bad_ancient_ambient.vpcf", context)

    PrecacheResource("particle", "particles/pugna/weapon_glow.vpcf", context)
    PrecacheResource("particle", "particles/pugna/ambient.vpcf", context)

    PrecacheResource("model", "models/development/invisiblebox.vmdl", context)
    PrecacheResource("particle", "particles/ui/ui_generic_treasure_impact.vpcf", context)
    PrecacheResource("soundfile", "soundevents/custom_sounds.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_vo_announcer.vsndevts", context)

    LinkLuaModifier("modifier_stunned_lua", "abilities/modifier_stunned", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_knockback_lua", "abilities/modifier_knockback", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_charges", "abilities/modifier_charges", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_hidden", "abilities/modifier_hidden", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_falling", "abilities/modifier_falling", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_falling_animation", "abilities/modifier_falling", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_hero", "abilities/modifier_hero", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_tower", "abilities/modifier_tower", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_creep", "abilities/modifier_creep", LUA_MODIFIER_MOTION_NONE)

    local heroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")

    for _, data in pairs(heroes) do
        PrecacheUnitByNameSync(data.override_hero, context)
    end

    VectorTarget:Precache(context)
end

function Activate()
    GameRules.GameMode = GameMode()
    GameRules.GameMode:SetupMode()
    VectorTarget:Init({ noOrderFilter = true })
end

function GameMode:OnThink()
    if GameRules:IsGamePaused() == true then
        return THINK_PERIOD
    end

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
    GameRules:SetPostGameTime(300)
    GameRules:SetTreeRegrowTime(60.0)
    GameRules:SetUseCustomHeroXPValues(true)
    GameRules:SetGoldPerTick(0)
    GameRules:SetUseBaseGoldBountyOnHeroes(true)
    GameRules:SetFirstBloodActive(false)
    GameRules:SetCustomGameSetupTimeout(0)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:SetTimeOfDay(FIXED_DAY_TIME)

    local mode = GameRules:GetGameModeEntity()

    mode:SetDaynightCycleDisabled(true)
    mode:SetCustomGameForceHero(DUMMY_HERO)
    mode:SetCameraDistanceOverride(1600)
    mode:SetCustomBuybackCostEnabled(true)
    mode:SetCustomBuybackCooldownEnabled(true)
    mode:SetBuybackEnabled(false)
    mode:SetTopBarTeamValuesOverride (true)
    mode:SetUseCustomHeroLevels(true)
    mode:SetAnnouncerDisabled(true)
    mode:SetCustomHeroMaxLevel(1)
    mode:SetFogOfWarDisabled(true)

    mode:SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "FilterExecuteOrder"), self)

    SendToServerConsole("dota_surrender_on_disconnect 0")
    SendToServerConsole("dota_combine_models 0")
end

function GameMode:FilterExecuteOrder(filterTable)
    local orderType = filterTable.order_type
    local index = 0
    local filteredUnits = {}
    for _, unitIndex in pairs(filterTable.units) do
        local unit = EntIndexToHScript(unitIndex)

        if orderType == DOTA_UNIT_ORDER_CAST_TOGGLE then
            local ability = EntIndexToHScript(filterTable.entindex_ability)

            if ability:IsCooldownReady() then
                filteredUnits[index] = unitIndex

                index = index + 1
            else
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(filterTable.issuer_player_id_const), "cooldown_error", {})
            end
        elseif not unit:IsChanneling() or orderType == DOTA_UNIT_ORDER_STOP or orderType == DOTA_UNIT_ORDER_HOLD_POSITION then
            filteredUnits[index] = unitIndex

            index = index + 1
        end
    end

    filterTable.units = filteredUnits
    return VectorTarget:OrderFilter(filterTable)
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
    ListenToGameEvent('player_reconnected', Dynamic_Wrap(self, 'EventPlayerReconnected'), self)
    ListenToGameEvent('player_disconnect', Dynamic_Wrap(self, 'EventPlayerDisconnected'), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'EventStateChanged'), self)
    ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'OnPlayerPickHero'), self)
    ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
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

function GameMode:IncreaseScore(player, amount)
    player.score = player.score + amount
    self:UpdatePlayerTable()

    if player.score >= self.gameGoal then
        if not self.winner then
            self.winner = player
        elseif player ~= self.winner then
            table.insert(self.runnerUps, player.id)
        end
    end
end

function GameMode:OnDamageDealt(hero, source)
    if hero ~= source and source and source.owner then
        self:IncreaseScore(source.owner, 1)

        Statistics.IncreaseDamageDealt(source.owner)
    end
end

function GameMode:EndGame()
    EmitAnnouncerSound("announcer_ann_custom_end_08")
    self:UpdateGameInfo()
    self:SetState(STATE_GAME_OVER)
    GameRules:SetGameWinner(PlayerResource:GetTeam(self.winner.id))
end

function GameMode:OnRoundEnd(round)
    local winner = round.winner

    playerData = {}

    if winner ~= nil then
        playerData.id = winner.id
        playerData.color = self.TeamColors[PlayerResource:GetTeam(winner.id)]
        self:IncreaseScore(winner, 3)

        Statistics.IncreaseRoundsWon(winner)
    else
        playerData.id = -1
    end

    CustomNetTables:SetTableValue("main", "roundState", { roundWinner = playerData })

    self:SetState(STATE_ROUND_ENDED)

    for _, player in pairs(self.Players) do
        player.hero.protected = true
    end

    Timers:CreateTimer(ROUND_ENDING_TIME, function ()
        round:Destroy()
        self.round = nil

        if self.winner then
            self:EndGame()
        else
            if self.roundNumber == 4 then
                self.heroSelection.HardHeroesLocked = false
                self:UpdateGameInfo()
            end

            self:SetState(STATE_HERO_SELECTION)
            self.heroSelection:Start(function() self:OnHeroSelectionEnd() end)
            self.level:Reset()
        end
    end)
end

function GameMode:OnHeroSelectionEnd()
    self.roundNumber = self.roundNumber + 1
    self.round = Round(self.Players, self.AvailableHeroes, function(round) self:OnRoundEnd(round) end)
    self.round:CreateHeroes()
    self:SetState(STATE_ROUND_IN_PROGRESS)
    self:UpdateGameInfo()

    Timers:CreateTimer(1.5,
        function()
            --EmitAnnouncerSound("announcer_ann_custom_adventure_alerts_42")
            EmitAnnouncerSound("announcer_announcer_battle_begin_01")
        end
    )
end

function GameMode:OnEntityKilled(event)
    local entity = EntIndexToHScript(event.entindex_killed)

    if entity:IsHero() and entity.hero then
        entity.hero.round.entityDied = true
    end
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
    self.State = state

    CustomNetTables:SetTableValue("main", "gameState", { state = state })
end

function GameMode:UpdateGameInfo()
    local players = {}

    for i, player in pairs(self.Players) do
        local playerData = {}
        playerData.id = i
        playerData.color = self.TeamColors[player.team]
        playerData.score = player.score

        players[i] = playerData
    end

    CustomNetTables:SetTableValue("main", "gameInfo", {
        goal = self.gameGoal,
        hardHeroesLocked = self.heroSelection.HardHeroesLocked,
        winner = self.winner and self.winner.id or nil,
        roundNumber = self.roundNumber,
        runnerUps = self.runnerUps,
        statistics = Statistics.stats,
        players = players
    })
end

function GameMode:LoadCustomHeroes()
    self.AvailableHeroes = {}

    local customHeroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    local customAbilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

    for customName, data in pairs(customHeroes) do
        if data.override_hero ~= DUMMY_HERO then
            self.AvailableHeroes[data.override_hero] = {
                ultimate = data.Ultimate,
                class = data.Class,
                customIcons = data.CustomIcons,
                difficulty = data.Difficulty or "easy"
            }

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

    Chat(self.Players, self.Users, self.TeamColors)

    self.roundNumber = 1
    self.gameGoal = GAME_GOAL
    self.winner = nil
    self.runnerUps = {}

    Statistics.Init(self.Players)

    self:UpdatePlayerTable()
    self.GameItems = nil--LoadKeyValues("scripts/items/items_game.txt").items

    self.level = Level()
    self.heroSelection = HeroSelection(self.Players, self.AvailableHeroes, self.TeamColors)

    self:UpdateGameInfo()

    self:RegisterThinker(1,
        function()
            if self.State == STATE_HERO_SELECTION and self.heroSelection then
                self.heroSelection:Update()
            end
        end
    )

    self:RegisterThinker(0.01,
        function()
            if self.State == STATE_ROUND_IN_PROGRESS and self.round then
                self.round:Update()
                self.level:Update()
            end
        end
    )

    CheckAndEnableDebug()

    self:SetState(STATE_HERO_SELECTION)
    self.heroSelection:Start(function() self:OnHeroSelectionEnd() end)
end

function GameMode:OnPlayerPickHero(keys)
    if keys.hero == DUMMY_HERO then
        local hero = EntIndexToHScript(keys.heroindex)

        hero:SetAbsOrigin(Vector(0, 0, 10000))
        hero:AddNoDraw()
        hero:AddNewModifier(hero, nil, "modifier_hidden", {})
    end
end