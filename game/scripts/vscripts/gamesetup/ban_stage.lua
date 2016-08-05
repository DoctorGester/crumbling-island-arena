BanStage = BanStage or class({}, nil, SetupStage)

function BanStage:constructor(name, players, amountOfBans)
    getbase(ModeSelectionStage).constructor(self, players, name, false)
end

function BanStage:ValidateInput(player, input)
    return type(input) == "string"
end

function BanStage:GetDefaultPlayerInput(player)
    return nil
end

function BanStage:FinalizeResults()
    local set = {}

    for _, input in pairs(self.inputs) do
        set[input] = true
    end

    local result = {}

    for key, _ in pairs(set) do
        table.insert(result, key)
    end

    return { bannedHeroes = result }
end