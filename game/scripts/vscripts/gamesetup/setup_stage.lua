SetupStage = SetupStage or class({})

function SetupStage:constructor(players, name, needsInputConfirmation)
    self.players = players
    self.name = name
    self.needsInputConfirmation = needsInputConfirmation

    self.inputs = {}
end

function SetupStage:Is(name)
    return self.name == name
end

function SetupStage:GetName()
    return self.name
end

function SetupStage:Activate()
    self:NetworkInputs()

    self.listener = CustomGameEventManager:RegisterListener(self.name,
        function(_, ...)
            self:ReceiveInput(...)
            self:NetworkInputs()
        end
    )

    if self.needsInputConfirmation then
        self.confirmedPlayers = {}
        self.confirmListener = CustomGameEventManager:RegisterListener(self.name.."_confirm", function(_, ...)
            self:ConfirmInput(...)
        end)
    end
end

function SetupStage:ConfirmInput(args)
    if not self.needsInputConfirmation then
        return
    end

    self.confirmedPlayers[args.PlayerID] = true
end

function SetupStage:TransformInput(player, input)
    return input
end

function SetupStage:Deactivate()
    CustomGameEventManager:UnregisterListener(self.listener)

    if self.confirmListener then
        CustomGameEventManager:UnregisterListener(self.confirmListener)
    end
end

function SetupStage:NetworkInputs()
    local result = {}

    for _, player in pairs(self.players) do
        table.insert(result, { id = player.id, input = self.inputs[player.id] })
    end

    CustomNetTables:SetTableValue("gameSetup", self.name, { inputs = result, u = tostring(result) }) -- force update
end

function SetupStage:ReceiveInput(args)
    local player = self.players[args.PlayerID]

    if not player:IsConnected() then
        return
    end

    if not self.needsInputConfirmation and self.inputs[player.id] then
        return
    end

    if self.needsInputConfirmation and self.confirmedPlayers[player.id] then
        return
    end

    if not self:ValidateInput(player, args.input) then
        return
    end

    self.inputs[player.id] = self:TransformInput(player.id, args.input)
end

function SetupStage:AssignDefaultInputs()
    for _, player in pairs(self.players) do
        if self.inputs[player.id] == nil then
            self.inputs[player.id] = self:GetDefaultPlayerInput(player)
        end
    end

    self:NetworkInputs()
end

function SetupStage:HasEnded()
    if self.needsInputConfirmation then
        for _, player in pairs(self.players) do
            if not self.confirmedPlayers[player.id] then
                return false
            end
        end

        return true
    end

    for _, player in pairs(self.players) do
        if self.inputs[player.id] == nil then
            return false
        end
    end

    return true
end

function SetupStage:CountInput(compareTo)
    local count = 0

    for _, input in pairs(self.inputs) do
        if input == compareTo then
            count = count + 1
        end
    end

    return count
end

function SetupStage:CountPlayers()
    local count = 0

    for _, _ in pairs(self.players) do
        count = count + 1
    end

    return count
end

-- Abstract
function SetupStage:ValidateInput(input)
    return true
end

function SetupStage:GetDefaultPlayerInput(player)
    return nil
end

function SetupStage:FinalizeResults()
    return {}
end