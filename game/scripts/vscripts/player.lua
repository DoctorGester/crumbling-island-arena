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
    self.player = PlayerResource:GetPlayer(id)
end

function Player:SetTeam(i)
    self.team = i
end