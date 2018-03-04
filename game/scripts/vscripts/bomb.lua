Bomb = Bomb or class({}, nil, UnitEntity)

local EXPLOSION_DELAY = 1.4
local EXPLOSION_RADIUS = 350

function Bomb:constructor(round, position)
    getbase(Bomb).constructor(self, round, DUMMY_UNIT, position)

    self.owner = { team = 0 }
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.gotDamagedAt = 0
    self.nextTickSoundAt = 0
    self.resetColorAt = 0
    self.isGoingToExplode = false
    self.damageSource = nil

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

function Bomb:Update()
    getbase(Bomb).Update(self)

    if self.isGoingToExplode and not self.destroyed then
        local currentTime = GameRules:GetGameTime()

        if currentTime >= self.nextTickSoundAt then
            self:EmitSound("Arena.BombTick", self:GetPos())
            self.unit:SetRenderColor(255, 100, 100)
            self:ScheduleNextTick()
            self.resetColorAt = currentTime + 0.09
        end

        if currentTime >= self.resetColorAt then
            self.unit:SetRenderColor(255, 255, 255)
        end

        if currentTime >= self.gotDamagedAt + EXPLOSION_DELAY then
            self:Destroy()
            self:OnDeath(self.damageSource)
        end
    end
end

function Bomb:OnDeath(source)
    FX("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(),
    {
        cp0 = self:GetPos() + Vector(0, 0, 64),
        cp1 = Vector(EXPLOSION_RADIUS, 1, 1),
        release = true
    })

    ScreenShake(self:GetPos(), 5, 150, 0.45, 3000, 0, true)

    self:EmitSound("Arena.Bomb", self:GetPos())

    if self.falling then
        return
    end

    source:AreaEffect({
        filter = Filters.Area(self:GetPos(), EXPLOSION_RADIUS),
        damage = 3,
        hitSelf = true,
        hitAllies = true,
        knockback = {
            force = 90,
            direction = function(v) return v:GetPos() - self:GetPos() end
        }
    })
end

function Bomb:ScheduleNextTick()
    local deltaTime = GameRules:GetGameTime() - self.gotDamagedAt
    local explosionProgress = deltaTime / (EXPLOSION_DELAY * 1.15)

    self.nextTickSoundAt = GameRules:GetGameTime() + math.cos(explosionProgress * (math.pi / 2.0)) * 0.3
end

function Bomb:OnDamageReceived(damageSource)
    self.isGoingToExplode = true
    self.gotDamagedAt = GameRules:GetGameTime()
    self.damageSource = damageSource
    self.nextTickSoundAt = self.gotDamagedAt

    self:AddComponent(PlayerCircleComponent(EXPLOSION_RADIUS, true, 0.25, { 165, 20, 40 }))

    return 1
end

function Bomb:CollidesWith(source)
    return true
end

function Bomb:CanFall()
    return true
end