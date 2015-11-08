Player = class({
    id = 0,
    hero = nil,
    player = nil,
    score = 0,
    team = 0,
    fow,
    selectionLocked = false,
    selectedHero = nil
})

function Player:SetPlayerID(id)
    self.id = id
    self.player = PlayerResource:GetPlayer(id)

    self.fow = CreateUnitByName("npc_dummy_unit", Vector(0, 0), false, nil, nil, PlayerResource:GetTeam(id))
    self.fow:SetDayTimeVisionRange(8000)
    self.fow:SetNightTimeVisionRange(8000)
end

function Player:SetTeam(i)
    self.team = i
end

function Player:Blind(duration)
    self.fow:AddNewModifier(self.fow, nil, "modifier_blind", { duration = duration })
end

function Player:ReturnVision()
    self.fow:RemoveModifierByName("modifier_blind")
end