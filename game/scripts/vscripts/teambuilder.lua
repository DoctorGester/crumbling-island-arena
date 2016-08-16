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
    return vlua.find(self.players, player) ~= nil
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
                if to:Size() + batch:Size() <= self.maxBatchSize then
                    if predicate(batch, to) then
                        batch:Unrelate(to)
                        to:Unrelate(batch)
                        to:Merge(batch)
                        
                        toRemove = index
                        break
                    end
                else
                    batch:Unrelate(to)
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
                if to ~= batch and to:Size() + batch:Size() <= self.maxBatchSize then
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

TeamBuilderAlt = class({})

function TeamBuilderAlt:constructor(players, maxPlayers, permutations)
    self.players = players
    self.prefs = {}
    self.maxPlayers = maxPlayers

    self.numPlayers = #self.players
    self.bestModel = nil

    self.permutations = permutations
end

function TeamBuilderAlt:SetTeamPreference(playerFrom, playerTo)
    if playerFrom ~= playerTo then
        table.insert(self.prefs, { from = playerFrom, to = playerTo })
    end
end

function TeamBuilderAlt:Permutate(current, index)
    if index == self.numPlayers + 1 then
        table.insert(self.permutations, current)
        return
    end

    for i = 1, self.numPlayers do
        local player = self.players[i]

        if vlua.find(current, player) == nil then
            local clone = vlua.clone(current)
            table.insert(clone, player)
            self:Permutate(clone, index + 1)
        end
    end
end

function TeamBuilderAlt:ComputePermutations()
    self.permutations = {}
    self:Permutate({}, 1)
end

function TeamBuilderAlt:ResolveTeams()
    if self.permutations == nil then
        self:ComputePermutations()
    end

    self.models = {}

    for offset = 0, self.numPlayers % self.maxPlayers do
        for _, permutation in ipairs(self.permutations) do
            local model = {}

            for i = offset, self.numPlayers - 1, self.maxPlayers do
                local currentTeam = nil

                for id = i + 1, i + self.maxPlayers do
                    if permutation[id] then
                        if currentTeam == nil then
                            currentTeam = {}
                            table.insert(model, currentTeam)
                        end

                        table.insert(currentTeam, permutation[id])
                    end
                end
            end

            table.insert(self.models, model)
        end
    end

    local maxScore = -1
    local bestModels = {}

    for _, model in ipairs(self.models) do
        local score = self:ScoreModel(model)

        if score > maxScore then
            bestModels = {}
            maxScore = score
        end

        if score == maxScore then
            table.insert(bestModels, model)
        end
    end

    self.bestModel = bestModels[RandomInt(1, #bestModels)]
end

function TeamBuilderAlt:ScoreModel(model)
    local total = 0
    local success = 0

    for _, relation in ipairs(self.prefs) do
        for _, team in ipairs(model) do
            local frFound = false
            local toFound = false

            for _, player in ipairs(team) do
                if player == relation.from then
                    frFound = true
                end

                if player == relation.to then
                    toFound = true
                end

                if frFound and toFound then
                    success = success + 1
                    break
                end
            end
        end

        total = total + 1
    end

    if total == 0 then
        return 0
    end

    return success / total
end

function TeamBuilderAlt:Score()
    return self:ScoreModel(self.bestModel)
end

if IsInToolsMode() then
    local totalScore = 0
    local totalScoreAlt = 0
    local numPlayers = 3
    local iterations = 100
    local players = { "A", "B", "C", "D", "E" }

    local baker = TeamBuilderAlt(players, numPlayers)
    baker:ComputePermutations()

    print("[TEAM BUILDER] test started")

    for i = 1, iterations do
        players = vlua.clone(players)

        local tb = TeamBuilder(players, numPlayers)
        local tba = TeamBuilderAlt(players, numPlayers, baker.permutations)

        for j = 1, RandomInt(1, 12) do
            local from = RandomInt(1, #players)
            local to = nil

            while to == nil or to == from do
                to = RandomInt(1, #players)
            end

            tb:SetTeamPreference(players[from], players[to])
            tba:SetTeamPreference(players[from], players[to])
        end

        tb:ResolveTeams()
        totalScore = totalScore + tb:Score()

        tba:ResolveTeams()
        totalScoreAlt = totalScoreAlt + tba:Score()

        if i % 100 == 0 then
            print("[TEAM BUILDER] test progress", i / iterations)
        end
    end

    print("[TEAM BUILDER] test score", totalScore / iterations)
    print("[TEAM BUILDER] test score alt", totalScoreAlt / iterations)

    tb = TeamBuilderAlt({ "A", "B", "C", "D", "E", "F" }, 3)
    tb:SetTeamPreference("A", "B")
    tb:SetTeamPreference("B", "A")
    tb:SetTeamPreference("C", "D")
    tb:SetTeamPreference("D", "C")
    tb:SetTeamPreference("B", "C")

    tb:ResolveTeams()
end