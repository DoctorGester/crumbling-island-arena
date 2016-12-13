require('lib/timers')
require('lib/animations')
require('lib/vector_target')
require('lib/statcollection')
require('targeting_indicator')
require('util')
require('stats')

require('dynamic_entity')
require('unit_entity')
require('breakable_entity')
require('wearable_owner')
require('hero')
require('player')
require('level')
require("levels/polygon")
require("levels/level_lua")
require('gamesetup/game_setup')
require('teambuilder')
require('hero_selection')
require('round')
require('rune')
require('deathmatch')
require('quests')
require('heroes/hero_util')

require('spells')
require('wrappers')
require('projectile')
require('arc_projectile')
require('dash')
require('statistics')
require('chat')
require('debug_util')

_G.GAME_VERSION = "2.0"
_G.STATE_NONE = 0
_G.STATE_GAME_SETUP = 1
_G.STATE_HERO_SELECTION = 2
_G.STATE_ROUND_IN_PROGRESS = 3
_G.STATE_ROUND_ENDED = 4
_G.STATE_GAME_OVER = 5
_G.STATE_GAME_OVER_DM = 6

ROUND_ENDING_TIME = 6
FIXED_DAY_TIME = 0.27

THINK_PERIOD = 0.01

DUMMY_HERO = "npc_dota_hero_wisp"

if GameMode == nil then
    GameMode = class({})
end

function Precache(context)
    for _, path in pairs(require('particles')) do
        PrecacheResource("particle", path, context)
        print("Precaching", path)
    end

    PrecacheResource("model", "models/development/invisiblebox.vmdl", context)
    PrecacheResource("particle", "particles/ui/ui_generic_treasure_impact.vpcf", context)
    PrecacheResource("soundfile", "soundevents/custom_sounds.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/emotes.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_announcer.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/music/dsadowski_01/soundevents_music.vsndevts", context)

    PrecacheResource("model", "models/items/lycan/wolves/hunter_kings_wolves/hunter_kings_wolves.vmdl", context)

    PrecacheUnitByNameSync("wk_skeleton", context)
    PrecacheUnitByNameSync("wk_zombie", context)
    PrecacheUnitByNameSync("wk_archer", context)

    _G.GameItems = LoadKeyValues("scripts/items/items_game.txt")
    _G.Cosmetics = LoadKeyValues("scripts/npc/cosmetics.txt")

    local heroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")

    for _, data in pairs(heroes) do
        PrecacheUnitByNameSync(data.override_hero, context)

        local allItems = {}
        local wearableOwnerProxy = {
            GetName = function() return data.override_hero end
        }

        for _, item in pairs(WearableOwner.FindDefaultItems(wearableOwnerProxy)) do
            table.insert(allItems, item)
        end

        local shortName = data.override_hero:sub(("npc_dota_hero_"):len() + 1)
        local cosmetics = Cosmetics[shortName]

        if cosmetics then
            for _, entry in pairs(cosmetics) do
                if type(entry) == "table" then
                    if entry.set then
                        for _, item in pairs(WearableOwner.FindSetItems(nil, entry.set) or {}) do
                            table.insert(allItems, item)
                        end
                    end

                    if entry.item then
                        for _, item in pairs(tostring(entry.item):split(",")) do
                            local realItem = GameItems.items[item]

                            if realItem then
                                table.insert(allItems, realItem)
                            end
                        end
                    end
                end
            end
        end

        for _, item in pairs(allItems) do
            if item.model_player then
                PrecacheModel(item.model_player, context)
                print("Precaching", item.model_player)
            end
        end
    end

    local units = LoadKeyValues("scripts/npc/npc_units_custom.txt")

    for key, _ in pairs(units) do
        if not string.starts(key, "hero_") then
            PrecacheUnitByNameSync(key, context)
        end
    end

    VectorTarget:Precache(context)
end

function Activate()
    if IsInToolsMode() and GetMapName():starts("prefabs") then
        return WritePrefab()
    end

    GameRules.GameMode = GameMode()
    GameRules.GameMode:SetupMode()
end

function WritePrefab()
    local name = string.gsub(GetMapName(), ".*\\(.*)", "%1")..".lua"
    local pieces = Entities:FindAllByName("map_part")
    local file = io.open(name, "w")

    file:write("local pieces = {}\n")

    for _, piece in pairs(pieces) do
        local m = piece:GetModelName():gsub(".*entities/(.*)", "%1")
        local p = piece:GetAbsOrigin()

        file:write(("pieces[%q] = Vector(%f, %f, %f)\n"):format(m, p.x, p.y, p.z))
    end

    file:write("return pieces")
    file:close()
end

function GameMode:OnThink()
    if GameRules:IsGamePaused() then
        return THINK_PERIOD
    end

    local now = Time()
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        for _, thinker in ipairs(self.Thinkers) do
            if now >= thinker.next then
                thinker.next = math.max(thinker.next + thinker.period, now)
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

    local id = args.PlayerID

    if id == -1 then
        return
    end

    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        if string.len(PlayerResource:GetSelectedHeroName(id)) == 0 then
            CreateHeroForPlayer(DUMMY_HERO, playerEntity)
        end
    end

    self:EnsurePlayersHaveControllers()
    
    local userID = args.userid

    self.Users = self.Users or {}
    self.Users[userID] = playerEntity

    if not self.Players[id] then
        local player = Player()
        player:SetPlayerID(id)
        self.Players[id] = player

        if self.gameSetup then
            self.gameSetup:AddPlayer(player)
        end
    elseif self.Players[id].team ~= nil then
        if PlayerResource:GetCustomTeamAssignment(id) ~= self.Players[id].team then
            PlayerResource:SetCustomTeamAssignment(id, self.Players[id].team)
        end
    end
end

function GameMode:EnsurePlayersHaveControllers()
    Timers:CreateTimer(5, function()
        if GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            for _, player in pairs(self.Players) do
                local playerEntity = PlayerResource:GetPlayer(player.id)

                if playerEntity and IsValidEntity(playerEntity) and string.len(PlayerResource:GetSelectedHeroName(player.id)) == 0 then
                    CreateHeroForPlayer(DUMMY_HERO, playerEntity)
                end
            end
        end
    end)
end

function GameMode:EventPlayerReconnected(args)
    print("Player reconnected")
    PrintTable(args)

    if self.HeroSelection then
        self.HeroSelection:UpdateSelectedHeroes()
    end

    self:EnsurePlayersHaveControllers()
end

function GameMode:EventPlayerDisconnected(args)
    print("Player disconnected")
    PrintTable(args)

    if self.HeroSelection then
        self.HeroSelection:UpdateSelectedHeroes()
    end
end

function GameMode:EventStateChanged(args)
    local newState = GameRules:State_Get()

    if not IsInToolsMode() and PlayerResource:GetPlayerCount() > 1 and newState >= DOTA_GAMERULES_STATE_INIT and not statCollection.doneInit then
        statCollection:init()
    end

    if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        if IsInToolsMode() then
            Timers:CreateTimer(1, function() self:OnGameSetup() end)
        else
            self:OnGameSetup()
        end
    end
     
    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        self:OnGameInProgress()
    end
end

function GameMode:OnGameSetup()
    print("Setting players up")

    local amount = 0
    local i = 0

    for id = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayer(id) then
            local player = Player()
            player:SetPlayerID(id)
            self.Players[player.id] = player

            i = i + 1
            amount = amount + 1
        end
    end

    local circleSize = 1200

    if GetMapName() ~= "ranked_2v2" then
        circleSize = 1550
    end

    local roundSpawnPoints = {}

    for i = 0, 3 do
        local a = i * math.pi / 4 * 2
        table.insert(roundSpawnPoints, Vector(math.cos(a), math.sin(a), 0) * circleSize)
    end

    local roundSpawnPointsBig = {}

    for i = 0, 5 do
        local a = i * math.pi / 6 * 2
        table.insert(roundSpawnPointsBig, Vector(math.cos(a), math.sin(a), 0) * circleSize)
    end

    local teamSpawnPoints = {}

    for _, start in ipairs(Entities:FindAllByName("3v3_start")) do
        table.insert(teamSpawnPoints, start:GetAbsOrigin())
    end

    local modes = {
        ["ffa"] = { playersInTeam = 1, announce = "announcer_ann_custom_mode_06", spawns = roundSpawnPointsBig },
        ["dm"] = { playersInTeam = 1, announce = "announcer_announcer_type_death_match", spawns = roundSpawnPointsBig },
        ["2v2"] = { playersInTeam = 2, announce = "announcer_ann_custom_mode_07", spawns = roundSpawnPoints },
        ["3v3"] = { playersInTeam = 3, announce = "announcer_ann_custom_mode_07", spawns = teamSpawnPoints }
    }

    local forcedMode = nil

    if GetMapName() == "ranked_2v2" and amount == 4 then
        forcedMode = "2v2"
    end

    if GetMapName() == "ranked_3v3" then
        if amount == 4 then
            forcedMode = "2v2"
        end

        if amount == 6 then
            forcedMode = "3v3"
        end
    end

    if amount == 3 or amount == 5 then
        modes["2v2"] = nil
        modes["3v3"] = nil
    end

    if amount <= 2 then
        forcedMode = "ffa"
    end

    self:LoadCustomHeroes()
    self:UpdateAvailableHeroesTable()

    self.gameSetup = GameSetup(modes, self.Players, self.Teams, forcedMode)
    self.rankedMode = self:GetRankedMode()

    self:SetState(STATE_GAME_SETUP)
    self.gameSetup:Start()

    CustomNetTables:SetTableValue("gameSetup", "misc", { rankedMode = self.rankedMode })

    self:RegisterThinker(1,
        function()
            if self.State == STATE_GAME_SETUP and self.gameSetup then
                self.gameSetup:Update()
            end
        end
    )
end

function GameMode:InitSettings()
    GameRules:SetHeroRespawnEnabled(false)
    GameRules:SetUseUniversalShopMode(false)
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:SetHeroSelectionTime(1.0)
    GameRules:SetPreGameTime(0)
    GameRules:SetPostGameTime(300000)
    GameRules:SetTreeRegrowTime(60.0)
    GameRules:SetUseCustomHeroXPValues(true)
    GameRules:SetGoldPerTick(0)
    GameRules:SetUseBaseGoldBountyOnHeroes(true)
    GameRules:SetFirstBloodActive(false)
    GameRules:EnableCustomGameSetupAutoLaunch(false)
    GameRules:SetTimeOfDay(FIXED_DAY_TIME)

    local mode = GameRules:GetGameModeEntity()

    mode:SetDaynightCycleDisabled(true)
    mode:SetCustomGameForceHero(DUMMY_HERO)
    mode:SetCameraDistanceOverride(1600)
    mode:SetCustomBuybackCostEnabled(true)
    mode:SetCustomBuybackCooldownEnabled(true)
    mode:SetBuybackEnabled(false)
    mode:SetTopBarTeamValuesOverride (true)
    mode:SetAnnouncerDisabled(true)
    mode:SetFogOfWarDisabled(true)
    mode:SetWeatherEffectsDisabled(true)

    mode:SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "FilterExecuteOrder"), self)

    if IsInToolsMode() then
        SendToServerConsole("dota_surrender_on_disconnect 0")
        SendToServerConsole("dota_auto_surrender_all_disconnected_timeout 10000")
    end
end

function GameMode:FilterExecuteOrder(filterTable)
    local orderType = filterTable.order_type
    local index = 0
    local filteredUnits = {}
    for _, unitIndex in pairs(filterTable.units) do
        local unit = EntIndexToHScript(unitIndex)

        -- Yes, that happened
        if unit ~= nil then
            if orderType == DOTA_UNIT_ORDER_STOP or orderType == DOTA_UNIT_ORDER_HOLD_POSITION then
                self.lastOrders[unit] = nil
            end

            if orderType == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
                self.lastOrders[unit] = Vector(filterTable.position_x, filterTable.position_y)
            end

            if orderType == DOTA_UNIT_ORDER_CAST_POSITION and self.lastOrders[unit] then
                local ability = EntIndexToHScript(filterTable.entindex_ability)

                if ability:IsCooldownReady() and not ability:IsInAbilityPhase() and ability:GetName():ends("_a") then
                    --if unit:IsMoving() then
                        Timers:CreateTimer(0.1, function()
                            if IsValidEntity(unit) then
                                ExecuteOrderFromTable({
                                    UnitIndex = unitIndex, 
                                    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                                    Position = self.lastOrders[unit],
                                    Queue = true
                                })
                            end
                        end)
                    --end
                end
            end

            local currentChanneling = nil

            local count = unit:GetAbilityCount()
            for i = 0, count - 1 do
                local ability = unit:GetAbilityByIndex(i)

                if ability and ability:IsChanneling() then
                    currentChanneling = ability:GetName()
                end
            end

            if orderType == DOTA_UNIT_ORDER_CAST_TOGGLE then
                local ability = EntIndexToHScript(filterTable.entindex_ability)

                if ability:IsCooldownReady() then
                    filteredUnits[index] = unitIndex

                    index = index + 1
                else
                    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(filterTable.issuer_player_id_const), "cooldown_error", {})
                end
            elseif not unit:IsChanneling() or currentChanneling == "taunt_static" or orderType == DOTA_UNIT_ORDER_STOP or orderType == DOTA_UNIT_ORDER_HOLD_POSITION then
                filteredUnits[index] = unitIndex

                index = index + 1
            end
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
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNpcSpawned'), self)
    ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
end

function GameMode:InitModifiers()
    LinkLuaModifier("modifier_stunned_lua", "abilities/modifier_stunned", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_silence_lua", "abilities/modifier_silence_lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_knockback_lua", "abilities/modifier_knockback", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_charges", "abilities/modifier_charges", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_hidden", "abilities/modifier_hidden", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_falling", "abilities/modifier_falling", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_hero", "abilities/modifier_hero", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_tower", "abilities/modifier_tower", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_creep", "abilities/modifier_creep", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_preview", "abilities/modifier_preview", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_damaged", "abilities/modifier_damaged", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_wearable_visuals", "abilities/modifier_wearable_visuals", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_wearable_visuals_status_fx", "abilities/modifier_wearable_visuals", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_wearable_visuals_activity", "abilities/modifier_wearable_visuals", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_attack_speed", "abilities/modifier_attack_speed", LUA_MODIFIER_MOTION_NONE)
end

function GameMode:SetupMode()
    self.Players = {}
    self.Thinkers = {}
    self:SetState(STATE_GAME_SETUP)

    self.Round = nil

    GameRules:GetGameModeEntity():SetThink("OnThink", self, THINK_PERIOD)

    self:InitSettings()
    self:InitEvents()
    self:InitModifiers()

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
    self.TeamColors[DOTA_TEAM_BADGUYS]  = { 161, 127, 255 }
    self.TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }  --      Pink
    self.TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }   --      Orange
    self.TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }   --      Blue
    self.TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }  --      Green
    self.TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }   --      Brown
    self.TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }  --      Cyan
    self.TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }  --      Olive
    self.TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }  --      Purple

    for team = 0, (DOTA_TEAM_COUNT-1) do
        GameRules:SetCustomGameTeamMaxPlayers(team, 3)
        local color = self.TeamColors[team]
        if color then
            SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
        end
    end

    self.cameraDummy = CreateUnitByName("npc_dummy_unit", Vector(-550, 500, 0), false, nil, nil, DOTA_TEAM_NOTEAM)
    self.lastOrders = {}
end

function GameMode:GetTeamScore(team)
    local score = 0

    for _, player in pairs(self.Players) do
        if player.team == team then
            score = score + player.score
        end
    end

    return score
end

function GameMode:SendKillMessageToTeam(team, victim)
    CustomGameEventManager:Send_ServerToTeam(team, "kill_message", { victim = victim, token = "KMNormal" })
end

function GameMode:SendFirstBloodMessage(victim)
    CustomGameEventManager:Send_ServerToAllClients("kill_message", { victim = victim, token = "KMFirstBlood", sound = "UI.FirstBlood" })
end

function GameMode:RecordKill(victim, source, fell)
    if victim.owner.team ~= source.owner.team then
        self.round.statistics:IncreaseKills(source.owner)

        local heroCount = self:CountHeroes()

        if not self.firstBloodBy then
            self.firstBloodBy = source
            self.round.statistics:IncreaseFBs(source.owner)

            if heroCount > 3 then
                self:SendFirstBloodMessage(victim:GetName())
            end
        elseif heroCount > 3 then
            self:SendKillMessageToTeam(source.owner.team, victim:GetName())
        end
    end

    if not fell then
        FX("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN, source, {
            cp4 = victim:GetPos(),
            release = true
        })
    end

     CustomGameEventManager:Send_ServerToAllClients("kill_log_entry", {
        killer = source.owner.hero:GetName(),
        victim = victim:GetName(),
        color = self.TeamColors[source.owner.team],
        fell = fell
    })
end

function GameMode:OnDamageDealt(hero, source, amount)
    if hero ~= source and source and source.owner and hero.owner and source.owner.team ~= hero.owner.team then
        if self.round then
            self.round.statistics:IncreaseDamageDealt(source.owner, amount)
        end
    end

    if not hero:Alive() and hero.owner then
        self:RecordKill(hero, source, false)
    end
end

function GameMode:EndGame()
    if self.winner then
        Stats.SubmitMatchResult(self.winner, self.Players, function(...) self:OnMatchResultsReceived(...) end)
    end

    for _, player in pairs(self.Players) do
        Quests.IncreaseProgress(player, "gamesPlayed")
    end

    Stats.SubmitQuestProgress(self.Players, function(...) self:OnQuestResultsReceived(...) end)

    EmitAnnouncerSound("announcer_ann_custom_end_08")
    self:UpdateGameInfo()
    self:SetState(STATE_GAME_OVER)
    GameRules:SetGameWinner(self.winner)
end

function GameMode:CheckEveryoneAbandoned()
    if self.State == STATE_GAME_OVER then
        return
    end

    local teams = {}
    local teamCount = 0
    local playerCount = 0
    
    for _, player in pairs(self.Players) do
        local con = PlayerResource:GetConnectionState(player.id)

        if con ~= DOTA_CONNECTION_STATE_ABANDONED and con ~= DOTA_CONNECTION_STATE_DISCONNECTED then
            teams[player.team] = true
        end

        playerCount = playerCount + 1
    end

    local connectedTeamCount = 0
    local connectedTeam = nil

    for team, _ in pairs(teams) do
        connectedTeamCount = connectedTeamCount + 1
        connectedTeam = team
    end

    if playerCount > 1 and connectedTeamCount == 1 then
        self.abandonTimer = (self.abandonTimer or 0) + 1

        if self.abandonTimer == 1 then
            SystemMessage("SystemEveryoneLeft", { time = 40 })
        end

        if self.abandonTimer == 30 then
            SystemMessage("SystemEveryoneLeft", { time = 10 })
        end

        if self.abandonTimer > 40 then
            if self.State == STATE_ROUND_IN_PROGRESS and self.round then
                self.generalStatistics:Add(self.round.statistics)
                self:SubmitRoundInfo(self.round, connectedTeam, true)
                Stats.SubmitRoundInfo(self.Players, self.roundNumber - 2, connectedTeam, self.round.statistics)
            else
                self:SubmitRoundInfo({ statistics = Statistics(self.Players) }, connectedTeam, true)
                Stats.SubmitRoundInfo(self.Players, self.roundNumber - 2, connectedTeam, Statistics(self.Players))
            end

            self.winner = connectedTeam
            self:EndGame()
        end
    else
        self.abandonTimer = 0
    end
end

function GameMode:CountHeroes()
    local amount = 0

    for _, player in pairs(self.Players) do
        if player.hero ~= nil then
            amount = amount + 1
        end
    end

    return amount
end

function GameMode:OnRoundEnd(round)
    local playersInTeam = self.gameSetup:GetPlayersInTeam()
    local winner = round.winner
    local roundData = {}
    local firstBloodData = nil
    local mvpData = nil

    for _, player in pairs(self.Players) do
        if player.team == winner then
            if self:GetTeamScore(player.team) >= self.gameGoal then
                self.winner = player.team
            end
        end
    end

    for _, player in pairs(self.Players) do
        if player:IsConnected() and player.hero and player.hero:Alive() then
            self.scoreEarned[player] = self.currentScoreAddition
            self.currentScoreAddition = self.currentScoreAddition + 1
        end

        if player:IsConnected() and player.hero and player.team == winner then
            self.scoreEarned[player] = (self.scoreEarned[player] or 0) + 1
        end
    end

    local connectedCounts = {}

    for _, player in pairs(self.Players) do
        if player:IsConnected() and player.hero then
            connectedCounts[player.team] = (connectedCounts[player.team] or 0) + 1
        end
    end

    for team, count in pairs(connectedCounts) do
        for _, player in pairs(self.Players) do
            if player.team == team and player:IsConnected() and player.hero then
                self.scoreEarned[player] = math.ceil(self.scoreEarned[player] * (playersInTeam / count))
            end
        end
    end

    if self:CountHeroes() > 3 then
        if self.firstBloodBy then
            local firstBloodPlayer = self.firstBloodBy.owner

            firstBloodData = {}
            firstBloodData.id = firstBloodPlayer.id
            firstBloodData.color = self.TeamColors[firstBloodPlayer.team]
            firstBloodData.hero = firstBloodPlayer.selectedHero

            self.scoreEarned[firstBloodPlayer] = (self.scoreEarned[firstBloodPlayer] or 0) + 1
        end

        local mvp = nil
        local maxScore = 3

        for _, player in pairs(self.Players) do
            if player.hero then
                local stats = round.statistics.stats[player.id]
                local mvpScore = (stats.damageDealt or 0) + (stats.kills or 0) * 3

                if mvpScore > maxScore then
                    maxScore = mvpScore
                    mvp = player
                end
            end
        end

        if mvp then
            mvpData = {}
            mvpData.id = mvp.id
            mvpData.color = self.TeamColors[mvp.team]
            mvpData.hero = mvp.selectedHero

            round.statistics:IncreaseMVPs(mvp)

            self.scoreEarned[mvp] = (self.scoreEarned[mvp] or 0) + 1
        end
    end

    for player, earned in pairs(self.scoreEarned) do
        player.score = player.score + earned
    end
    
    for _, player in pairs(self.Players) do
        local playerData = {}
        playerData.id = player.id
        playerData.team = player.team
        playerData.color = self.TeamColors[player.team]
        playerData.earned = self.scoreEarned[player]
        playerData.score = player.score
        playerData.hero = player.selectedHero
        playerData.winner = player.team == winner

        table.insert(roundData, playerData)

        if playerData.winner then
            round.statistics:IncreaseRoundsWon(player)
        end
    end

    -- Setting up end-camera
    round:Destroy()
    DoEntFire("round_end_layer_entity", "ShowWorldLayerAndSpawnEntities", "", 0.0, nil, nil)
    self.level:Hide()

    local positions = {
        { Vector(100, -400, 17), Vector(1, -0.4, 0), true },
        { Vector(300, -300, 17), Vector(0.8, -1, 0) },
        { Vector(100, -170, 17), Vector(0.25, -0.5, 0) }
    }

    local index = 1
    local tempPlayers = {}
    local tempHeroes = {}

    for _, player in pairs(self.Players) do
        if player.selectedHero and player.team == winner then
            table.insert(tempPlayers, player)
        end

        PlayerResource:SetOverrideSelectionEntity(player.id, nil)
        PlayerResource:SetCameraTarget(player.id, self.cameraDummy)
    end

    Shuffle(tempPlayers)

    for _, player in pairs(tempPlayers) do
        local hero = self.round:LoadHeroClass(player.selectedHero)
        local unit = CreateUnitByName(player.selectedHero, positions[index][1], false, nil, nil, player.team)
        hero:SetUnit(unit)
        hero.owner = player
        hero:LoadWearables()
        self.round:LoadHeroMixins(player.selectedHero, hero)

        if instanceof(hero, Jugger) then
            hero:AttachWearable(hero:GetSwordModel(0))
        end

        unit:SetAbsOrigin(positions[index][1])
        unit:AddNewModifier(unit, nil, "modifier_preview", {})
        unit:SetForwardVector(positions[index][2]:Normalized())

        local data = self.AvailableHeroes[player.selectedHero]
        unit:StartGesture(_G[data.endActivity])

        if data.endTranslation then
            AddAnimationTranslate(unit, data.endTranslation)
        end

        if positions[index][3] then
            Timers:CreateTimer(ROUND_ENDING_TIME / 3, function()
                if hero:FindAbility("emote") then
                    EmitAnnouncerSound(hero:GetShortName())
                else
                    EmitAnnouncerSound("Round."..hero:GetShortName())
                end
            end)
        end

        table.insert(tempHeroes, hero)

        index = index + 1
    end

    self:UpdatePlayerTable()
    self.generalStatistics:Add(round.statistics)
    self:SubmitRoundInfo(round, winner, self.winner ~= nil)
    Stats.SubmitRoundInfo(self.Players, self.roundNumber - 2, winner, round.statistics)

    CustomNetTables:SetTableValue("main", "roundState", { roundData = roundData, goal = self.gameGoal, firstBlood = firstBloodData, mvp = mvpData })

    self:SetState(STATE_ROUND_ENDED)

    Timers:CreateTimer(ROUND_ENDING_TIME, function ()
        for _, hero in pairs(tempHeroes) do
            hero:GetUnit():RemoveSelf()
        end

        DoEntFire("round_end_layer_entity", "HideWorldLayerAndDestroyEntities", "", 0.0, nil, nil)
        self.level:Show()

        self.round = nil

        for _, player in pairs(self.Players) do
            PlayerResource:SetCameraTarget(player.id, nil)
        end

        if self.winner then
            self:EndGame()
        else
            self:SetState(STATE_HERO_SELECTION)
            self.heroSelection:Start(function() self:OnHeroSelectionEnd() end)
            
            GameRules:GetGameModeEntity():StopSound("dsadowski_01.music.battle_01")
            GameRules:GetGameModeEntity():EmitSound("dsadowski_01.music.countdown")
        end
    end)
end

function GameMode:OnHeroSelectionEnd()
    GameRules:GetGameModeEntity():EmitSound("dsadowski_01.music.battle_01")

    self.level:Reset()
    self.currentScoreAddition = 1
    self.scoreEarned = {}
    self.roundNumber = self.roundNumber + 1
    self.round = Round(self.Players, self.Teams, self.AvailableHeroes,
        function(round)
            if self:IsDeathMatch() then
                self.deathmatch:OnRoundEnd(round)
            else
                self:OnRoundEnd(round)
            end
        end
    )
    self.round:CreateHeroes(self.gameSetup:GetSpawnPoints())
    self.firstBloodBy = nil
    self:SetState(STATE_ROUND_IN_PROGRESS)
    self:UpdateGameInfo()
    self:UpdatePlayerTable()

    Timers:CreateTimer(1.5,
        function()
            local roundSoundNumber = self.roundNumber - 1

            if roundSoundNumber <= 10 and not self:IsDeathMatch() then
                EmitAnnouncerSound(string.format("announcer_ann_custom_round_%02d", roundSoundNumber))
            else
                EmitAnnouncerSound("announcer_announcer_battle_begin_01")
            end
        end
    )
end

function GameMode:OnEntityKilled(event)
    local entity = EntIndexToHScript(event.entindex_killed)

    if entity:IsHero() and entity.hero then
        if not self:IsDeathMatch() then
            entity.hero.round.entityDied = true

            self.scoreEarned[entity.hero.owner] = self.currentScoreAddition
            self.currentScoreAddition = self.currentScoreAddition + 1
        end

        PlayerResource:SetOverrideSelectionEntity(entity.hero.owner.id, nil)

        if entity:GetAbsOrigin().z <= -MAP_HEIGHT then
            local lastKnockbackCaster = entity.hero.lastKnockbackSource
            lastKnockbackCaster = lastKnockbackCaster or self.level:FindReasonForFalling(entity.hero)

            self:RecordKill(entity.hero, lastKnockbackCaster or entity.hero, true)
        end
    end
end

function GameMode:UpdatePlayerTable()
    local players = {}

    for i, player in pairs(self.Players) do
        local playerData = {}
        playerData.id = i
        playerData.hero = player.selectedHero
        playerData.team = player.team
        playerData.color = self.TeamColors[player.team]
        playerData.score = player.score
        playerData.gamesPlayed = self.gamesPlayed and self.gamesPlayed[i] or nil

        table.insert(players, playerData)
    end

    CustomNetTables:SetTableValue("main", "players", {
        players = players,
        goal = self.gameGoal
    })
end

function GameMode:UpdateAvailableHeroesTable()
    local heroes = {}

    for name, data in pairs(self.AvailableHeroes) do
        heroes[name] = {
            customIcons = data.customIcons,
            difficulty = data.difficulty,
            order = data.order,
            disabled = data.disabled,
            name = name,
            abilities = data.abilities,
            banned = data.banned,
            forNewPlayers = data.forNewPlayers,
            range = data.range
        }

        table.insert(heroes, hero)
    end

    CustomNetTables:SetTableValue("static", "heroes", heroes)
    CustomNetTables:SetTableValue("static", "abilities", self.AllAbilities)
end

function GameMode:IsDeathMatch()
    return self.gameSetup:GetSelectedMode() == "dm"
end

-- A replica of server-side function
function GameMode:GetRankedMode()
    local players = 0
    local mode = self.gameSetup:GetSelectedMode()

    for _, player in pairs(self.Players) do
        players = players + 1
    end

    if GetMapName() == "unranked" then
        return nil
    end

    if mode == "2v2" and players == 4 then
        return "teams"
    end

    if mode == "3v3" and players == 6 then
        return "teams"
    end

    if mode == "ffa" and players == 2 then
        return "duel"
    end

    return nil
end

function GameMode:SetState(state)
    self.State = state

    CustomNetTables:SetTableValue("main", "gameState", { state = state })
end

function GameMode:SubmitRoundInfo(round, winner, gameOver)
    local winners = {}

    if winner then
        for i, player in pairs(self.Players) do
            if player.team == winner then
                winners[PlayerResource:GetSteamAccountID(player.id)] = true
            end
        end
    end

    local players = {}

    for i, player in pairs(self.Players) do
        local playerData = {}

        if player.selectedHero then
            playerData.hero = string.gsub(player.selectedHero, "npc_dota_hero_", "")
        else
            playerData.hero = ""
        end

        playerData.steamID32 = PlayerResource:GetSteamAccountID(player.id)
        playerData.score = player.score

        local stats = round.statistics.stats[player.id]
        playerData.dD = stats.damageDealt or 0
        playerData.pF = stats.projectilesFired or 0

        table.insert(players, playerData)
    end

    statCollection:sendStage3(winners, gameOver)
    statCollection:sendCustom({ game = {}, players = players })
end

function GameMode:UpdateGameInfo()
    local players = {}

    for i, player in pairs(self.Players) do
        local playerData = {}
        playerData.id = i
        playerData.team = player.team
        playerData.color = self.TeamColors[player.team]
        playerData.score = player.score

        players[i] = playerData
    end

    CustomNetTables:SetTableValue("main", "gameInfo", {
        goal = self.gameGoal,
        winner = self.winner,
        roundNumber = self.roundNumber,
        statistics = self.generalStatistics.stats,
        players = players,
        rankedMode = self.rankedMode
    })
end

function GameMode:ParseSteamId64Table(data)
    local result = {}

    for _, player in pairs(self.Players) do
        for id, value in pairs(data) do
            if tostring(PlayerResource:GetSteamID(player.id)) == tostring(id) then
                result[player.id] = value
            end
        end
    end

    return result
end

function GameMode:OnRanksReceived(ranks)
    local parsed = self:ParseSteamId64Table(ranks)
    CustomNetTables:SetTableValue("ranks", "current", parsed)

    return parsed
end

function GameMode:OnAchievementsReceived(achievements)
    self.achievements = self:ParseSteamId64Table(achievements)

    for playerId, achievement in pairs(self.achievements) do
        self.Players[playerId].wasTopPlayer = achievement.wasTopPlayer
    end

    CustomNetTables:SetTableValue("ranks", "achievements", self.achievements)
end

function GameMode:OnPassExperienceReceived(experience)
    self.passExperience = self:ParseSteamId64Table(experience)

    for playerId, experience in pairs(self.passExperience) do
        local player = self.Players[playerId]
        player.passExperience = experience % 1000
        player.passLevel = math.floor(experience / 1000)

        SystemMessage("SystemPassLevel", { player = playerId, color = self.TeamColors[player.team], level = player.passLevel + 1 })
    end

    CustomNetTables:SetTableValue("pass", "experience", self.passExperience)
end

function GameMode:IsAwardedForSeason(playerId, season)
    if self.achievements == nil then
        return false
    end

    local achievement = self.achievements[playerId]

    if not achievement then
        return false
    end

    if achievement.achievedSeasons then
        return vlua.find(achievement.achievedSeasons, season) ~= nil
    end

    return false
end

function GameMode:OnMatchResultsReceived(data)
    local ranks = data.rankDetails

    if ranks and ranks.previous and ranks.updated then
        CustomNetTables:SetTableValue("ranks", "update", {
            previous = self:ParseSteamId64Table(ranks.previous),
            updated = self:ParseSteamId64Table(ranks.updated),
            currentSeason = self.currentSeason
        })
    end
end

function GameMode:OnQuestResultsReceived(data)
    if data and type(data) == "table" then
        CustomNetTables:SetTableValue("pass", "questResults", self:ParseSteamId64Table(data))
    end
end

function GameMode:LoadCustomHeroes()
    self.AvailableHeroes = {}

    local customHeroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    local customAbilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

    local enableForDebug = false--IsInToolsMode() and PlayerResource:GetPlayerCount() == 1
    local order = 0

    self.AllAbilities = {}

    for customName, data in pairs(customHeroes) do
        if data.override_hero ~= DUMMY_HERO then
            self.AvailableHeroes[data.override_hero] = {
                ultimate = data.Ultimate,
                class = data.Class,
                customIcons = data.CustomIcons,
                difficulty = data.Difficulty or "easy",
                order = data.Order or math.huge,
                disabled = (data.Disabled and data.Disabled == "true" and not enableForDebug) or false,
                initialCD = data.UltiCooldown,
                endActivity = data.RoundEndActivity or "ACT_DOTA_LOADOUT",
                endTranslation = data.RoundEndTranslation,
                defaultMixin = data.DefaultMixin,
                removeWearablesOnDeath = data.RemoveWearablesOnDeath,
                removeWearablesDelay = data.RemoveWearablesDelay,
                hideOnDeathDelay = data.HideOnDeathDelay,
                forNewPlayers = data.ForNewPlayers,
                range = data.Range
            }

            local abilities = {}

            for i = 0, 10 do
                local abilityName = data["Ability"..tostring(i)]
                if abilityName and #abilityName ~= 0 and not abilityName:starts("placeholder") then
                    local ability = {}
                    ability.name = abilityName
                    ability.texture = customAbilities[ability.name].AbilityTextureName
                    ability.damage = customAbilities[ability.name].Damage

                    table.insert(abilities, abilityName)
                    self.AllAbilities[abilityName] = ability
                end
            end

            self.AvailableHeroes[data.override_hero].abilities = abilities
        end
    end
end

function GameMode:AssignBannedHeroes()
    local banned = self.gameSetup:GetBannedHeroes()

    if banned == nil then
        return
    end

    for _, hero in pairs(banned) do
        self.AvailableHeroes[hero].banned = true
    end
end

function GameMode:NetworkCosmetics()
    local result = {}
    local imageMap = {}

    for hero, cosmetics in pairs(Cosmetics) do
        for _, asset in pairs(cosmetics) do
            if type(asset) == "table" then
                if asset.type == "pass" or asset.type == "pass_base" then
                    local images = nil

                    if asset.item then
                        for _, item in pairs(tostring(asset.item):split(",")) do
                            local realItem = GameItems.items[item]

                            if realItem then
                                local wasEmpty = images == nil
                                images = (images or "")..(wasEmpty and "" or ",")..realItem.image_inventory
                            end
                        end

                        imageMap[asset.item] = images
                    end

                    if asset.type == "pass" then
                        result[asset.level] = {
                            item = asset.item,
                            emote = asset.emote,
                            taunt = asset.taunt ~= nil,
                            hero = hero,
                            images = images
                        }
                    end
                end
            end
        end
    end

    CustomNetTables:SetTableValue("pass", "cosmetics", result)
    CustomNetTables:SetTableValue("pass", "heroes", { cosmetics = Cosmetics, images = imageMap })
end

function GameMode:OnGameInProgress()
    self:AssignBannedHeroes()
    self:UpdateAvailableHeroesTable()
    self:NetworkCosmetics()
    self:Start()
end

function GameMode:Start()
    if not statCollection.sentStage2 and statCollection.sentStage1 then
        statCollection:sendStage2()
    end

    Stats.SubmitMatchInfo(self.Players, self.gameSetup:GetSelectedMode(), GAME_VERSION,
        function(data)
            self.currentSeason = data.currentSeason

            if data.gamesPlayed then
                self.gamesPlayed = self:ParseSteamId64Table(data.gamesPlayed)
                self:UpdatePlayerTable()
            end

            if data.achievements then
                self:OnAchievementsReceived(data.achievements)
            end

            if data.passExperience then
                self:OnPassExperienceReceived(data.passExperience)
            end
        end
    )

    Quests.Init(self.Players)

    self.chat = Chat(self.Players, self.Users, self.TeamColors)

    self.roundNumber = 1
    self.winner = nil

    self.generalStatistics = Statistics(self.Players)

    self.level = Level()
    self.level:LoadPolygons()
    self.level:Clusterize()
    self.level:AssociatePieces()

    self.heroSelection = HeroSelection(
        self.Players,
        self.AvailableHeroes,
        self.TeamColors, 
        self.chat,
        true,
        self.rankedMode ~= nil
    )

    if self.rankedMode == "duel" then
        self.heroSelection.SelectionTimerTime = 15
    end

    if self:IsDeathMatch() then
        self.deathmatch = DeathMatch(self.Players, self.AvailableHeroes)
        self.heroSelection.SelectionTimerTime = 40
        self.deathmatch:Activate(GameMode, self)
        self.level:SetSlowFactor(7)
        self.level:EnableRegeneration(10, 20)
        self.level:SetFinishingDistance(1200)

        self:RegisterThinker(1,
            function()
                if self.State == STATE_ROUND_IN_PROGRESS then
                    self.deathmatch:Update()
                end
            end
        )
    end

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

    self:RegisterThinker(1,
        function()
            if self.State ~= STATE_GAME_OVER then
                self:CheckEveryoneAbandoned()
            end
        end
    )

    if self:IsDeathMatch() then
        self.gameGoal = PlayerResource:GetPlayerCount() * 3
    else
        self.gameGoal = PlayerResource:GetPlayerCount() * 6 * self.gameSetup:GetPlayersInTeam()
    end

    self:UpdatePlayerTable()
    self:UpdateGameInfo()

    CheckAndEnableDebug()

    self:SetState(STATE_HERO_SELECTION)
    self.heroSelection:Start(function() self:OnHeroSelectionEnd() end)

    GameRules:GetGameModeEntity():EmitSound("dsadowski_01.music.countdown")
end

function GameMode:OnNpcSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)

    if npc:IsRealHero() and npc:GetName() == DUMMY_HERO then
        npc:AddNoDraw()
        npc:AddNewModifier(hero, nil, "modifier_hidden", {})
    end
end

-- Deathmatch extension reload

if IsInToolsMode() and GameRules.GameMode and GameRules.GameMode.deathmatch then
    GameRules.GameMode.deathmatch:Activate(GameMode, GameRules.GameMode)
end

if IsInToolsMode() then
    _G.Cosmetics = LoadKeyValues("scripts/npc/cosmetics.txt")

    for i = 0, 30 do
        for hero, cosmetics in pairs(Cosmetics) do
            for _, asset in pairs(cosmetics) do
                if type(asset) == "table" then
                    if asset.level == i then
                        print(i, hero)
                        break
                    end
                end
            end
        end
    end

    GameMode.InitModifiers()
    GameRules.GameMode:LoadCustomHeroes()
    GameRules.GameMode:UpdateAvailableHeroesTable()

    GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "FilterExecuteOrder"), GameRules.GameMode)
end