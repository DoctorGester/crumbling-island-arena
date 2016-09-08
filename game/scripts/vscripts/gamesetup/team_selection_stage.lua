TeamSelectionStage = TeamSelectionStage or class({}, nil, SetupStage)

function TeamSelectionStage:constructor(name, players, maxPlayersInTeam)
    getbase(TeamSelectionStage).constructor(self, players, name, true)

    self.maxPlayersInTeam = maxPlayersInTeam
end

function TeamSelectionStage:ValidateInput(player, input)
    local set = {}
    local amount = 0

    for _, _ in pairs(input) do
        amount = amount + 1
    end

    if amount >= self.maxPlayersInTeam then
        return false
    end

    for _, id in pairs(input) do
        if player.id == input then
            return false
        end

        if set[id] then
            return false
        else
            set[id] = true
        end
    end

    return true
end

function TeamSelectionStage:GetDefaultPlayerInput(player)
    return {}
end

function TeamSelectionStage:SetWeights(weights)
    self.weights = weights
end

function TeamSelectionStage:FinalizeResults()
    local players = {}

    for _, player in pairs(self.players) do
        table.insert(players, player.id)
    end

    local builder = TeamBuilderAlt(players, self.maxPlayersInTeam)

    for id, preferences in pairs(self.inputs) do
        for _, preference in pairs(preferences) do
            builder:SetTeamPreference(id, tonumber(preference))
        end
    end

    if self.weights then
        builder:SetAdditionalWeightSupplier(function(player)
            return self.weights[player]
        end)
    end

    builder:ResolveTeams()

    local relationsResult = {}

    for _, team in pairs(builder.bestModel) do
        table.insert(relationsResult, vlua.clone(team))
    end
    
    return {
        teamBuilderTeams = relationsResult,
        teamBuilderScore = builder:Score()
    }
end