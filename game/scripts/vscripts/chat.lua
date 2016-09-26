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
        color = self.teamColors[self.players[id].team],
        player = id,
        message = args.message,
        wasTopPlayer = self.players[id].wasTopPlayer,
        hasPass = PlayerResource:HasCustomGameTicketForPlayerID(id)
    })
end

function Chat:PlayerRandomed(id, hero, teamLocal)
    if teamLocal then
        CustomGameEventManager:Send_ServerToTeam(self.players[id].team, "custom_randomed_message", {
            color = self.teamColors[self.players[id].team],
            player = id,
            hero = hero,
            wasTopPlayer = self.players[id].wasTopPlayer
        })
    else
        CustomGameEventManager:Send_ServerToAllClients("custom_randomed_message", {
            color = self.teamColors[self.players[id].team],
            player = id,
            hero = hero,
            wasTopPlayer = self.players[id].wasTopPlayer
        })
    end
end