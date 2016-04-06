Player = class({
    id = 0,
    hero = nil,
    player = nil,
    score = 0,
    team = 0,
    selectionLocked = false,
    selectedHero = nil
})

function Player:SetPlayerID(id)
    self.id = id
end

function Player:SetTeam(i)
    self.team = i

    if PlayerResource:GetCustomTeamAssignment(self.id) == 0 and i then
        PlayerResource:SetCustomTeamAssignment(self.id, i)
    end
end

function Player:IsConnected()
    return PlayerResource:GetConnectionState(self.id) == DOTA_CONNECTION_STATE_CONNECTED or IsInToolsMode()
end