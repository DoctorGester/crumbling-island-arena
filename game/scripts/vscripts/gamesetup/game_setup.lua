require('gamesetup/setup_stage')
require('gamesetup/mode_selection_stage')
require('gamesetup/team_selection_stage')
require('gamesetup/ban_stage')

GameSetup = GameSetup or class({})

function GameSetup:constructor(modes, players, teams, forcedMode)
    self.players = players
    self.teams = teams
    self.modes = modes
    self.outputs = {}
    self.timer = 0

    self.nextStageTimer = 0

    if forcedMode then
        self.outputs["stage_mode"] = {}
        self.outputs["stage_mode"].selectedMode = forcedMode
        self.outputs["stage_mode"].playersInTeam = self.modes[forcedMode].playersInTeam
        --EmitAnnouncerSound(modes[forcedMode].announce)
    end
end

function GameSetup:Start()
    self:StageAdvance()

    if GameRules.GameMode.rankedMode ~= nil then
        EmitAnnouncerSound("Announcer.SetupRanked")
    else
        EmitAnnouncerSound("Announcer.SetupUnranked")
    end
end

function GameSetup:AddPlayer( ... )
    if self.currentStage ~= nil then
        self.currentStage:NetworkInputs()
    end
end

function GameSetup:GetNextStageAndTime()
    if self.currentStage == nil and self:GetSelectedMode() == nil then
        return ModeSelectionStage("stage_mode", self.players, self.modes), IsInToolsMode() and 5 or 15
    end

    if (self:GetSelectedMode() ~= nil and self.currentStage == nil) or self.currentStage:Is("stage_mode") then
        if self:GetSelectedMode() == "dm" then
            return nil
        end

        if self:GetSelectedMode() == "ffa" then
            if GameRules.GameMode.rankedMode ~= nil then
                self:FreeForAllTeams()
                EmitAnnouncerSound("Announcer.SetupBanStage")
                return BanStage("stage_bans", self.players, 3), IsInToolsMode() and 5 or 15
            end

            return nil
        end

        local gameMode = GameRules.GameMode
        Stats.RequestMatchAchievements(gameMode.Players, function(data)
            if data and data.gamesPlayed then
                local result = gameMode:ParseSteamId64Table(data.gamesPlayed)
                PrintTable(result)

                if self.currentStage:Is("stage_team") then
                    self.currentStage:SetWeights(result)
                end
            end
        end)

        EmitAnnouncerSound("Announcer.SetupTeam")
        return TeamSelectionStage("stage_team", self.players, self:GetPlayersInTeam()), IsInToolsMode() and 10 or 15
    end

    if self.currentStage:Is("stage_team") then
        local teams = self.outputs.stage_team.teamBuilderTeams
        local currentTeam = 0

        for _, team in pairs(teams) do
            for _, playerId in pairs(team) do
                self.players[playerId]:SetTeam(self.teams[currentTeam])
            end

            currentTeam = currentTeam + 1
        end
    end

    if self.currentStage:Is("stage_team") and GameRules.GameMode.rankedMode ~= nil then
        EmitAnnouncerSound("Announcer.SetupBanStage")
        return BanStage("stage_bans", self.players, 1), IsInToolsMode() and 5 or 15
    end
end

function GameSetup:StageAdvance()
    if self.currentStage ~= nil then
        self.currentStage:Deactivate()
        self.currentStage:AssignDefaultInputs()

        local results = self.currentStage:FinalizeResults()

        print(self.currentStage:GetName(), "outputs")
        PrintTable(results)

        self.outputs[self.currentStage:GetName()] = results
    end

    self.nextStageTimer = 2
    self:UpdateNetworkState()
end

function GameSetup:UpdateNetworkState()
    CustomNetTables:SetTableValue("gameSetup", "state", {
        stage = self.currentStage and self.currentStage:GetName() or nil,
        outputs = self.outputs
    })
end

function GameSetup:FreeForAllTeams()
    local currentTeam = 0

    for _, player in pairs(self.players) do
        self.players[player.id]:SetTeam(self.teams[currentTeam])

        currentTeam = currentTeam + 1
    end
end

function GameSetup:End()
    if not self.outputs.stage_team then
        self:FreeForAllTeams()
    end

    statCollection:setFlags({ version = GAME_VERSION, mode = self:GetSelectedMode() })
    GameRules:FinishCustomGameSetup()
end

function GameSetup:SendTimeToPlayers()
    CustomGameEventManager:Send_ServerToAllClients("setup_timer_tick", { time = self.timer })
end

function GameSetup:Update()
    if self.nextStageTimer > 0 then
        self.nextStageTimer = math.max(self.nextStageTimer - 1, -1)

        if self.nextStageTimer == 0 then
            local stage, time = self:GetNextStageAndTime()

            self.currentStage = stage

            if self.currentStage ~= nil then
                self.currentStage:Activate()
                self.timer = time
                self:SendTimeToPlayers()
            else
                self.timer = 0
                self:SendTimeToPlayers()
            end

            self:UpdateNetworkState()
        end

        return
    end

    self.timer = math.max(self.timer - 1, -1)
    self:SendTimeToPlayers()

    if self.currentStage ~= nil and self.currentStage:HasEnded() then
        self:StageAdvance()
        return
    end

    if self.timer == 0 then
        self:StageAdvance()
    end

    if self.timer == -1 then
        self:End()
    end
end

-- Utility

function GameSetup:GetSelectedMode()
    if self.outputs.stage_mode == nil then
        return nil
    end

    return self.outputs.stage_mode.selectedMode
end

function GameSetup:GetPlayersInTeam()
    return self.outputs.stage_mode.playersInTeam
end

function GameSetup:GetSpawnPoints()
    return self.modes[self:GetSelectedMode()].spawns
end

function GameSetup:GetBannedHeroes()
    if self.outputs.stage_bans == nil then
        return nil
    end

    return self.outputs.stage_bans.bannedHeroes
end