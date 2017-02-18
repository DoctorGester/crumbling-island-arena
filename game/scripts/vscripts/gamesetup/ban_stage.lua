BanStage = BanStage or class({}, nil, SetupStage)

function BanStage:constructor(name, players, amountOfBans)
    getbase(ModeSelectionStage).constructor(self, players, name, true)

    self.amountOfBans = amountOfBans or 1
    self.bans = {}
end

function BanStage:TransformInput(player, input)
    self.bans[player] = self.bans[player] or {}

    local remaining = self.amountOfBans
    for _, value in pairs(self.bans[player]) do
        if value then
            remaining = remaining - 1
        end
    end

    -- If banned or has bans
    if remaining > 0 or self.bans[player][input] then
        -- Reverse the ban value
        self.bans[player][input] = not self.bans[player][input]
    end

    return { remaining = remaining, bans = self.bans[player] }
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
        for hero, value in pairs(input.bans or {}) do
            if value then
                set[hero] = true
            end
        end
    end

    local result = {}

    for key, _ in pairs(set) do
        table.insert(result, key)
    end

    return { bannedHeroes = result }
end