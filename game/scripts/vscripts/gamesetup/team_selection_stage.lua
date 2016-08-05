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

function TeamSelectionStage:FinalizeResults()
    local players = {}

    for _, player in pairs(self.players) do
        table.insert(players, player.id)
    end

    local builder = TeamBuilder(players, self.maxPlayersInTeam)

    for id, preferences in pairs(self.inputs) do
        for _, preference in pairs(preferences) do
            builder:SetTeamPreference(id, tonumber(preference))
        end
    end

    builder:ResolveTeams()

    local relationsResult = {}

    for _, batch in pairs(builder.batches) do
        table.insert(relationsResult, vlua.clone(batch.players))
    end
    
    return {
        teamBuilderTeams = relationsResult,
        teamBuilderScore = builder:Score()
    }
end