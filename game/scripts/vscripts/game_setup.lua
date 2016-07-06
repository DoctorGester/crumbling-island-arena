GameSetup = GameSetup or class({})

GAME_SETUP_STAGE_MODE = 0
GAME_SETUP_STAGE_TEAM = 1

function GameSetup:constructor(modes, players, teams)
    self.timer = IsInToolsMode() and 5 or 30
    self.players = players
    self.teams = teams
    self.stage = GAME_SETUP_STAGE_MODE
    self.selectedMode = nil
    self.modes = modes
    self.teamNumber = 0

    self.playerState = {}

    for _, player in pairs(self.players) do
        self.playerState[player.id] = {
            selectedMode = nil,
            selectedTeam = nil
        }
    end
end

function GameSetup:UpdateModes()
    local result = {}

    for mode, params in pairs(self.modes) do
        local teamNumber = self:CalculateTeamCount(params)

        if teamNumber > 1 then
            table.insert(result, mode)
        end
    end

    table.sort(result, function(mode1, mode2)
        return self.modes[mode1].playersInTeam < self.modes[mode2].playersInTeam
    end)

    CustomNetTables:SetTableValue("gameSetup", "modes", result)
end

function GameSetup:CalculateTeamCount(mode)
    local players = self:GetPlayerCount()
    local result = players / mode.playersInTeam

    if result - math.floor(result) < 0.5 then
        return math.floor(result)
    else
        return math.ceil(result)
    end
end

function GameSetup:AddPlayer(player)
    self.playerState[player.id] = {
        selectedMode = nil,
        selectedTeam = nil
    }

    self:UpdateNetworkState()
    self:UpdateModes()
end

function GameSetup:GetSpawnPoints()
    return self.modes[self.selectedMode].spawns
end

function GameSetup:GetPlayersInTeam()
    return self.modes[self.selectedMode].playersInTeam
end

function GameSetup:UpdateNetworkState()
    local result = {}
    result.stage = self.stage
    result.selectedMode = self.selectedMode
    result.players = self.playerState

    CustomNetTables:SetTableValue("gameSetup", "state", result)
end

function GameSetup:DistinctTeams()
    local team = 0
    for _, player in pairs(self.playerState) do
        player.selectedTeam = team
        team = team + 1
    end
end

function GameSetup:MostVotedMode()
    local count = -1
    local mostVoted = nil

    for mode, _ in pairs(self.modes) do
        local votes = self:GetModeVotesCount(mode)

        if votes > count then
            count = votes
            mostVoted = mode
        end
    end

    return mostVoted
end

function GameSetup:SetupSelectedMode()
    local params = self.modes[self.selectedMode]

    self.teamNumber = self:CalculateTeamCount(params)

    if params.playersInTeam > 1 then
        self.stage = GAME_SETUP_STAGE_TEAM

        -- Pre-team match registration
        local gameMode = GameRules.GameMode
        Stats.SubmitMatchInfo(gameMode.Players, self.selectedMode, GAME_VERSION, function(...) gameMode:OnRanksReceived(...) end)

        if self.timer < 15 then
            self.timer = 15
        end

        CustomNetTables:SetTableValue("gameSetup", "teams", { teamNumber = self.teamNumber })
    else
        self:DistinctTeams()
        self.timer = 3
    end

    EmitAnnouncerSound(params.announce)
    self:SendTimeToPlayers()
end

function GameSetup:UpdateModeSelection()
    if self.selectedMode ~= nil then
        return
    end

    local players = self:GetPlayerCount()
    local notVoted = self:GetModeVotesCount(nil)

    for mode, params in pairs(self.modes) do
        local votes = self:GetModeVotesCount(mode)

        if (votes >= players / 2 and params.playersInTeam > 1) or (votes > players / 2 and params.playersInTeam == 1) then
            self.selectedMode = mode
            self:SetupSelectedMode()

            break
        end
    end

    if notVoted == 0 and self.selectedMode == nil then
        self.selectedMode = self:MostVotedMode()
        self:SetupSelectedMode()
    end
end

function GameSetup:UpdateTeamSelection()
    local lonelyTeam = self:FindLonelyTeam()

    if lonelyTeam ~= nil then
        for _, playerState in pairs(self.playerState) do
            if playerState.selectedTeam == nil then
                playerState.selectedTeam = lonelyTeam
            end
        end

        self:UpdateNetworkState()
    end

    local count = 0
    local players = self:GetPlayerCount()

    for team = 0, self.teamNumber - 1 do
        count = count + self:GetTeamPlayerCount(team)
    end

    if count == players then
        if self.timer > 3 then
            self.timer = 3
            self:SendTimeToPlayers()
        end
    end
end

function GameSetup:FindLonelyTeam()
    local lonelyTeam = nil

    for team = 0, self.teamNumber - 1 do
        local count = self:GetTeamPlayerCount(team)

        if count < self.modes[self.selectedMode].playersInTeam then
            if lonelyTeam ~= nil then
                return nil
            end

            lonelyTeam = team
        end
    end

    return lonelyTeam
end

function GameSetup:CountProperty(property, mode)
    local count = 0

    for id, player in pairs(self.playerState) do
        if self.players[id]:IsConnected() and player[property] == mode then
            count = count + 1
        end
    end

    return count
end

function GameSetup:GetPlayerCount()
    return self:CountProperty("nonExistingProperty", nil)
end

function GameSetup:GetModeVotesCount(mode)
    return self:CountProperty("selectedMode", mode)
end

function GameSetup:GetTeamPlayerCount(team)
    return self:CountProperty("selectedTeam", team)
end

function GameSetup:OnModeSelect(args)
    local player = self.players[args.PlayerID]
    local mode = args.mode

    if not self.stage == GAME_SETUP_STAGE_MODE then
        return
    end

    if not player:IsConnected() then
        return
    end

    if self.playerState[player.id].selectedMode ~= nil then
        return
    end

    if self.modes[mode] == nil then
        return
    end

    self.playerState[player.id].selectedMode = mode
    self:UpdateModeSelection()
    self:UpdateNetworkState()
end

function GameSetup:OnTeamSelect(args)
    local player = self.players[args.PlayerID]
    local team = args.team

    if not self.stage == GAME_SETUP_STAGE_TEAM then
        return
    end

    if not player:IsConnected() then
        return
    end

    if self.playerState[player.id].selectedTeam ~= nil then
        return
    end

    if team < 0 or team >= self.teamNumber then
        return
    end

    if self:GetTeamPlayerCount(team) >= self.modes[self.selectedMode].playersInTeam then
        return
    end

    self.playerState[player.id].selectedTeam = team
    self:UpdateTeamSelection()
    self:UpdateNetworkState()
end

function GameSetup:SendTimeToPlayers()
    CustomGameEventManager:Send_ServerToAllClients("setup_timer_tick", { time = self.timer })
end

function GameSetup:GetLowestPlayerTeam()
    local playerCount = 24
    local lowestTeam = -1

    for i = 0, self.teamNumber - 1 do
        local count = self:GetTeamPlayerCount(i)

        if count < playerCount and count < self.modes[self.selectedMode].playersInTeam then
            lowestTeam = i
            playerCount = count
        end
    end

    return lowestTeam
end

function GameSetup:SelectRandomOptions()
    if self.stage == GAME_SETUP_STAGE_MODE and self.selectedMode == nil then
        for id, player in pairs(self.playerState) do
            if self.players[id]:IsConnected() and player.selectedMode == nil then
                player.selectedMode = "ffa"
            end
        end

        self:UpdateModeSelection()
        self:UpdateNetworkState()

        return
    end

    if self.stage == GAME_SETUP_STAGE_TEAM then
        for id, player in pairs(self.playerState) do
            if player.selectedTeam == nil then
                player.selectedTeam = self:GetLowestPlayerTeam()
            end
        end

        self:UpdateTeamSelection()
        self:UpdateNetworkState()

        return
    end
end

function GameSetup:Start()
    print("Starting game setup", self:GetPlayerCount())

    if self:GetPlayerCount() <= 2 then
        if IsInToolsMode() then
            Timers:CreateTimer(3, function()
                self.selectedMode = "ffa"
                self:DistinctTeams()
                self:End()
            end)
        else
            self.selectedMode = "ffa"
            self:DistinctTeams()
            self:End()
        end
    else
        self:SendTimeToPlayers()

        EmitAnnouncerSound("announcer_ann_custom_vote_begun")

        self.modeListener = CustomGameEventManager:RegisterListener("setup_mode_select", function(id, ...) Dynamic_Wrap(self, "OnModeSelect")(self, ...) end)
        self.teamListener = CustomGameEventManager:RegisterListener("setup_team_select", function(id, ...) Dynamic_Wrap(self, "OnTeamSelect")(self, ...) end)

        self:UpdateNetworkState()
        self:UpdateModes()
    end
end

function GameSetup:End()
    if self.modeListener and self.teamListener then
        CustomGameEventManager:UnregisterListener(self.modeListener)
        CustomGameEventManager:UnregisterListener(self.teamListener)
    end

    for id, player in pairs(self.playerState) do
        self.players[id]:SetTeam(self.teams[player.selectedTeam])
    end

    statCollection:setFlags({ version = GAME_VERSION, mode = self.selectedMode })
    GameRules:FinishCustomGameSetup()
end

function GameSetup:Update()
    self.timer = math.max(self.timer - 1, -1)
    self:SendTimeToPlayers()

    if self.timer == 0 then
        self:SelectRandomOptions()
    end

    if self.timer == -1 then
        self:End()
    end
end