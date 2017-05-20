PlayerCircleSystem = PlayerCircleSystem or System("playerCircleParticle")

function PlayerCircleSystem:Remove()
    DFX(self.playerCircleParticle)
end