Bomb = Bomb or class({}, nil, UnitEntity)

function Bomb:constructor(round, position)
    getbase(Bomb).constructor(self, round, DUMMY_UNIT, position)

    self.owner = { team = 0 }
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER

    local unit = self:GetUnit()
    unit:SetModel("models/heroes/techies/fx_techies_remotebomb.vmdl")
    unit:SetOriginalModel("models/heroes/techies/fx_techies_remotebomb.vmdl")
    unit:StartGesture(ACT_DOTA_IDLE)
    unit:SetForwardVector(RandomVector(1))
    unit:SetModelScale(1.5)

    self:AddComponent(HealthComponent())
    self:SetCustomHealth(2)
    self:EnableHealthBar()
    self:AddNewModifier(self, nil, "modifier_custom_healthbar", {})
end

function Bomb:OnDeath(source)
    FX("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(),
    {
        cp0 = self:GetPos() + Vector(0, 0, 64),
        cp1 = Vector(300, 1, 1),
        release = true
    })

    ScreenShake(self:GetPos(), 5, 150, 0.45, 3000, 0, true)

    self:EmitSound("Arena.Bomb", self:GetPos())

    if self.falling then
        return
    end

    source:AreaEffect({
        filter = Filters.Area(self:GetPos(), 300),
        damage = 3,
        hitSelf = true,
        hitAllies = true,
        knockback = {
            force = 90
        }
    })
end

function Bomb:CollidesWith(source)
    return true
end

function Bomb:CanFall()
    return true
end