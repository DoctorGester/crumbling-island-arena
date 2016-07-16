PlayerBatch = class({})

function PlayerBatch:constructor()
    self.players = {}
    self.relations = {}
end

function PlayerBatch:Add(player)
    table.insert(self.players, player)
end

function PlayerBatch:Relate(batch)
    if batch ~= self then
        self.relations[batch] = true
    end
end

function PlayerBatch:Size()
    return #self.players
end

function PlayerBatch:Unrelate(batch)
    self.relations[batch] = nil
end

function PlayerBatch:Relates(batch)
    return self.relations[batch] ~= nil
end

function PlayerBatch:Relations()
    return self.relations
end

function PlayerBatch:Contains(player)
    return vlua.find(self.players, player)
end

function PlayerBatch:Merge(batch)
    for _, player in pairs(batch.players) do
        self:Add(player)
    end

    for relation, _ in pairs(batch.relations) do
        self:Relate(relation)
    end
end

TeamBuilder = class({})

function TeamBuilder:constructor(players, maxBatchSize)
    self.batches = {}

    for _, player in pairs(players) do
        local batch = PlayerBatch()
        batch:Add(player)

        table.insert(self.batches, batch)
    end

    self.players = players
    self.scoredPreferenced = {}
    self.maxBatchSize = maxBatchSize
end

function TeamBuilder:FindPlayerBatch(player)
    for _, batch in pairs(self.batches) do
        if batch:Contains(player) then
            return batch
        end
    end
end

function TeamBuilder:SetTeamPreference(playerFrom, playerTo)
    if playerFrom ~= playerTo then
        table.insert(self.scoredPreferenced, { from = playerFrom, to = playerTo })
        
        self:FindPlayerBatch(playerFrom):Relate(self:FindPlayerBatch(playerTo))
    end
end

function TeamBuilder:RemoveTeamPreference(playerFrom, playerTo)
    if playerFrom ~= playerTo then
        self:FindPlayerBatch(playerFrom):Unrelate(self:FindPlayerBatch(playerTo))
    end
end

function TeamBuilder:Score()
    local total = 0
    local success = 0

    for _, relation in pairs(self.scoredPreferenced) do
        if self:FindPlayerBatch(relation.from):Contains(relation.to) then
            success = success + 1
        end

        total = total + 1
    end

    return success / total
end

function TeamBuilder:ResolveTeams()
    local teams = {}

    local function mutualPredicate(batch, to)
        return to:Relates(batch)
    end

    local function singularPredicate()
        return true
    end

    while self:ResolveRelation(mutualPredicate) do end
    while self:ResolveRelation(singularPredicate) do end
    while self:ResolveRandomRelation() do end
end

function TeamBuilder:ResolveRelation(predicate)
    local toRemove = nil

    for index, batch in pairs(self.batches) do
        if batch:Size() < self.maxBatchSize then
            for to, _ in pairs(batch:Relations()) do
                to = self:FindPlayerBatch(to.players[1])
                if to:Size() < self.maxBatchSize then
                    if predicate(batch, to) then
                        batch:Unrelate(to)
                        to:Unrelate(batch)
                        to:Merge(batch)
                        
                        toRemove = index
                        break
                    end
                end
            end
        end

        if toRemove ~= nil then
            break
        end
    end

    if toRemove ~= nil then
        table.remove(self.batches, toRemove)

        return true
    end

    return false
end

function TeamBuilder:ResolveRandomRelation()
    local toRemove = nil

    for index, batch in pairs(self.batches) do
        if batch:Size() < self.maxBatchSize then
            for _, to in pairs(self.batches) do
                if to ~= batch and to:Size() < self.maxBatchSize then
                    to:Merge(batch)
                    
                    toRemove = index
                    break
                end
            end
        end

        if toRemove ~= nil then
            break
        end
    end

    if toRemove ~= nil then
        table.remove(self.batches, toRemove)

        return true
    end

    return false
end

function TeamBuilder:ResolveOneSidedRelations()
    for player, relations in pairs(self.relations) do
        if not self.processedTeams[from] then
            for _, to in pairs(relations) do
                self:PutIntoTeam(player, to)
            end
        end
    end
end

-- TODO fix teambuilder for teams of 4+ players
if IsInToolsMode() then
    local totalScore = 0
    local iterations = 1000

    for i = 1, iterations do
        local players = { "A", "B", "C", "D" }

        local tb = TeamBuilder(players, 2)

        for j = 1, RandomInt(1, 12) do
            local from = RandomInt(1, #players)
            local to = nil

            while to == nil or to == from do
                to = RandomInt(1, #players)
            end

            tb:SetTeamPreference(players[from], players[to])
        end

        tb:ResolveTeams()
        totalScore = totalScore + tb:Score()
    end

    print("[TEAM BUILDER] test score", totalScore / iterations)
end