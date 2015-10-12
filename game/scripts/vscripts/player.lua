Player = class({
	id = 0,
	hero = nil,
	player = nil,
	score = 0,
	selectionLocked = false,
	selectedHero = nil
})

function Player:SetPlayerID(id)
	self.id = id
	self.player = PlayerResource:GetPlayer(id)
	self.hero = Hero()
	self.hero:SetUnit(self.player:GetAssignedHero())
	self.hero:SetOwner(self)
end