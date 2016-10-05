ModeSelectionStage = class({}, nil, SetupStage)

function ModeSelectionStage:constructor(name, players, modes)
    getbase(ModeSelectionStage).constructor(self, players, name, false)

    self.modes = modes
end

function ModeSelectionStage:CountTeams(mode)
    local players = self:CountPlayers()
    local result = players / mode.playersInTeam

    if result - math.floor(result) < 0.5 then
        return math.floor(result)
    else
        return math.ceil(result)
    end
end

function ModeSelectionStage:FindMostVotedMode()
    local count = -1
    local mostVoted = nil

    for mode, _ in pairs(self.modes) do
        local votes = self:CountInput(mode)

        if votes >= count then
            count = votes
            mostVoted = mode
        end
    end

    return mostVoted
end

function ModeSelectionStage:UpdateModes()
    local result = {}

    for mode, params in pairs(self.modes) do
        local teamNumber = self:CountTeams(params)

        if teamNumber > 1 then
            table.insert(result, mode)
        end
    end

    table.sort(result, function(mode1, mode2)
        return self.modes[mode1].playersInTeam < self.modes[mode2].playersInTeam
    end)

    CustomNetTables:SetTableValue("gameSetup", "modes", result)
end

function ModeSelectionStage:FindSelectedMode()
    local players = self:CountPlayers()

    for mode, params in pairs(self.modes) do
        local votes = self:CountInput(mode)

        if votes >= players / 2 then
            return mode
        end
    end

    return nil
end

function ModeSelectionStage:Activate()
    getbase(ModeSelectionStage).Activate(self)

    self:UpdateModes()
end

function ModeSelectionStage:HasEnded()
    return self:FindSelectedMode() ~= nil or getbase(ModeSelectionStage).HasEnded(self)
end

function ModeSelectionStage:ValidateInput(player, input)
    return self.modes[input] ~= nil
end

function ModeSelectionStage:GetDefaultPlayerInput(player)
    return "dm"
end

function ModeSelectionStage:FinalizeResults()
    local mode = self:FindSelectedMode()

    if mode == nil then
        mode = self:FindMostVotedMode()
    end

    if mode == nil then
        mode = self:GetDefaultPlayerInput()
    end

    EmitAnnouncerSound(self.modes[mode].announce)

    return {
        selectedMode = mode,
        playersInTeam = self.modes[mode].playersInTeam
    }
end