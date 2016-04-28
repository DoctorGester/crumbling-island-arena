GameSetup = GameSetup or class({})

GAME_SETUP_STAGE_MODE = 0
GAME_SETUP_STAGE_TEAM = 1

function GameSetup:constructor(players, teams)
    self.timer = 30
    self.players = players
    self.teams = teams
    self.stage = GAME_SETUP_STAGE_MODE
    self.selectedMode = nil
    self.gameGoal = 0

    self.playerState = {}

    for _, player in pairs(self.players) do
        self.playerState[player.id] = {
            selectedMode = nil,
            selectedTeam = nil
        }
    end
end

function GameSetup:AddPlayer(player)
    self.playerState[player.id] = {
        selectedMode = nil,
        selectedTeam = nil
    }

    self:UpdateNetworkState()
end

function GameSetup:GetGameGoal()
    if self.selectedMode == GAME_MODE_FFA then
        return 75
    end

    if self.selectedMode == GAME_MODE_2V2 then
        return 150
    end

    return 0
end

function GameSetup:UpdateNetworkState()
    local result = {}
    result.stage = self.stage
    result.selectedMode = self.selectedMode
    result.players = self.playerState

    CustomNetTables:SetTableValue("main", "gameSetup", result)
end

function GameSetup:UpdateModeSelection()
    local ffaVotes = self:GetModeVotesCount(GAME_MODE_FFA)
    local teamVotes = self:GetModeVotesCount(GAME_MODE_2V2)
    local players = self:GetPlayerCount()

    if teamVotes >= players / 2 then
        self.selectedMode = GAME_MODE_2V2
        self.stage = GAME_SETUP_STAGE_TEAM
        EmitAnnouncerSound("announcer_ann_custom_mode_07")
        
        --EmitAnnouncerSound("announcer_ann_custom_vote_complete")

        if self.timer < 15 then
            self.timer = 15
            self:SendTimeToPlayers()
        end

        return
    end

    if ffaVotes > players / 2 then
        self.selectedMode = GAME_MODE_FFA
        EmitAnnouncerSound("announcer_ann_custom_mode_06")

        self.timer = 3
        self:SendTimeToPlayers()

        return
    end
end

function GameSetup:UpdateTeamSelection()
    local team1Players = self:GetTeamPlayerCount(0)
    local team2Players = self:GetTeamPlayerCount(1)
    local players = self:GetPlayerCount()

    if team1Players + team2Players == players then
        if self.timer > 3 then
            self.timer = 3
            self:SendTimeToPlayers()
        end
    end
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

    if mode ~= GAME_MODE_FFA and mode ~= GAME_MODE_2V2 then
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

    if team ~= 0 and team ~= 1 then
        return
    end

    if self:GetTeamPlayerCount(team) >= 2 then
        return
    end

    self.playerState[player.id].selectedTeam = team
    self:UpdateTeamSelection()
    self:UpdateNetworkState()
end

function GameSetup:SendTimeToPlayers()
    CustomGameEventManager:Send_ServerToAllClients("setup_timer_tick", { time = self.timer })
end

function GameSetup:SelectRandomOptions()
    if self.stage == GAME_SETUP_STAGE_MODE and self.selectedMode == nil then
        for id, player in pairs(self.playerState) do
            if self.players[id]:IsConnected() and player.selectedMode == nil then
                player.selectedMode = GAME_MODE_FFA
            end
        end

        self:UpdateModeSelection()
        self:UpdateNetworkState()

        return
    end

    if self.stage == GAME_SETUP_STAGE_TEAM then
        for id, player in pairs(self.playerState) do
            if player.selectedTeam == nil then
                if self:GetTeamPlayerCount(0) < 2 then
                    player.selectedTeam = 0
                else
                    player.selectedTeam = 1
                end
            end
        end

        self:UpdateTeamSelection()
        self:UpdateNetworkState()

        return
    end
end

function GameSetup:Start()
    print("Starting game setup")

    self:SendTimeToPlayers()

    EmitAnnouncerSound("announcer_ann_custom_vote_begun")

    self.modeListener = CustomGameEventManager:RegisterListener("setup_mode_select", function(id, ...) Dynamic_Wrap(self, "OnModeSelect")(self, ...) end)
    self.teamListener = CustomGameEventManager:RegisterListener("setup_team_select", function(id, ...) Dynamic_Wrap(self, "OnTeamSelect")(self, ...) end)

    self:UpdateNetworkState()
end

function GameSetup:End()
    CustomGameEventManager:UnregisterListener(self.modeListener)
    CustomGameEventManager:UnregisterListener(self.teamListener)

    if self.selectedMode == GAME_MODE_2V2 then
        for id, player in pairs(self.playerState) do
            self.players[id]:SetTeam(self.teams[player.selectedTeam])
        end
    end

    if self.selectedMode == GAME_MODE_FFA then
        local team = 0
        for id, player in pairs(self.playerState) do
            self.players[id]:SetTeam(self.teams[team])
            team = team + 1
        end
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