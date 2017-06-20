LevelPiece = LevelPiece or class({})

function LevelPiece:constructor(prop)
    self.position = prop:GetAbsOrigin()
    self.defaultZ = self.position.z
    self.velocity = 0
    self.angles = prop:GetAnglesAsVector()
    self.angleVel = Vector(0, 0, 0)
    self.health = 100
    self.offset = Vector(0, 0, 0)
end

function LevelPiece:Reset()
    self:SetAbsOrigin(Vector(self.x, self.y, self.defaultZ))
    self:SetAngles(0, 0, 0)
    self.velocity = 0
    self.health = 100
    self.z = self.defaultZ
    self.offsetX = 0
    self.offsetY = 0
    self.offsetZ = 0
    self.angles = Vector(0, 0, 0)
    self.angleVel = Vector(0, 0, 0)
    self.launched = false
    self.launchedBy = nil
    self.launchedAt = 0
    self.regeneratesAt = nil
    self:SetRenderColor(255, 255, 255)
    self:RemoveEffects(EF_NODRAW)
end


function LevelPiece:Launch(by, sourcePosition)
    table.insert(self.fallingParts, part)
    part.angleVel = Vector(RandomFloat(0, 2), RandomFloat(0, 2), 0)
    self.launched = true
    self.launchedBy = by
    self.launchedAt = GameRules:GetGameTime()

    if by and self.enableRegeneration then
        table.insert(self.regeneratingParts, part)
    end
end
