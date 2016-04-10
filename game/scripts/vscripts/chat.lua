Chat = Chat or class({})

function Chat:constructor(players, users, teamColors)
    self.players = players
    self.teamColors = teamColors
    self.users = users

    CustomGameEventManager:RegisterListener("custom_chat_say", function(id, ...) Dynamic_Wrap(self, "OnSay")(self, ...) end)
end

function Chat:OnSay(args)
    local id = args.PlayerID
    local message = args.message

    message = message:gsub("^%s*(.-)%s*$", "%1") -- Whitespace trim
    message = message:gsub("^(.{0,256})", "%1") -- Limit string length

    if message:len() == 0 then
        return
    end

    CustomGameEventManager:Send_ServerToAllClients("custom_chat_say", {
        hero = self.players[id].selectedHero,
        color = self.teamColors[PlayerResource:GetTeam(id)],
        player = id,
        message = args.message
    })
end