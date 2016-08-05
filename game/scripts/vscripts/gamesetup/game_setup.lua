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

    if forcedMode then
        self.outputs["stage_mode"] = {}
        self.outputs["stage_mode"].selectedMode = forcedMode
        self.outputs["stage_mode"].playersInTeam = self.modes[forcedMode].playersInTeam
    end
end

function GameSetup:Start()
    self:StageAdvance()
end

function GameSetup:AddPlayer( ... )
    if self.currentStage ~= nil then
        self.currentStage:NetworkInputs()
    end
end

function GameSetup:GetNextStageAndTime()
    if self.currentStage == nil and self:GetSelectedMode() == nil then
        EmitAnnouncerSound("announcer_ann_custom_vote_begun")
        return ModeSelectionStage("stage_mode", self.players, self.modes), IsInToolsMode() and 5 or 15
    end

    if (self:GetSelectedMode() ~= nil and self.currentStage == nil) or self.currentStage:Is("stage_mode") then
        if self:GetSelectedMode() == "ffa" then
            return nil
        end

        local gameMode = GameRules.GameMode
        Stats.SubmitMatchInfo(gameMode.Players, self:GetSelectedMode(), GAME_VERSION, function(data)
            if data.ranks then
                gameMode:OnRanksReceived(data.ranks)
            end
        end)

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

    if self.currentStage:Is("stage_team") and self:GetSelectedMode() == "3v3" then
        EmitAnnouncerSound("Announcer.BanMode")
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

function GameSetup:UpdateNetworkState()
    CustomNetTables:SetTableValue("gameSetup", "state", {
        stage = self.currentStage and self.currentStage:GetName() or nil,
        outputs = self.outputs
    })
end

function GameSetup:End()
    if not self.outputs.stage_team then
        local currentTeam = 0

        for _, player in pairs(self.players) do
            self.players[player.id]:SetTeam(self.teams[currentTeam])

            currentTeam = currentTeam + 1
        end
    end

    statCollection:setFlags({ version = GAME_VERSION, mode = self:GetSelectedMode() })
    GameRules:FinishCustomGameSetup()
end

function GameSetup:SendTimeToPlayers()
    CustomGameEventManager:Send_ServerToAllClients("setup_timer_tick", { time = self.timer })
end

function GameSetup:Update()
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