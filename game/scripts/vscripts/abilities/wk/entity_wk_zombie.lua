WKZombie = WKZombie or class({}, nil, UnitEntity)

function WKZombie:constructor(round, owner, position, direction)
    getbase(WKZombie).constructor(self, round, "wk_zombie", position, owner.unit:GetTeamNumber())

    self.ability = ability
    self.owner = owner.owner
    self.hero = owner
    self.size = 64
    self.start = position
    self.direction = direction
    self.removeOnDeath = false
    self.collisionType = COLLISION_TYPE_RECEIVER

    self:SetFacing(direction)
    self:AddNewModifier(self.hero, nil, "modifier_wk_zombie", { duration = 5 })

    if owner.owner then
        self:GetUnit():SetControllableByPlayer(owner.owner.id, true)
    end

    if RandomInt(0, 1) == 1 then
        self:EmitSound("Arena.WK.CastE")
    end
end

function WKZombie:GetPos()
    return self:GetUnit():GetAbsOrigin()
end

function WKZombie:Update()
    getbase(WKZombie).Update(self)

    if self.falling then
        return
    end

    if self:FindModifier("modifier_wk_zombie"):GetRemainingTime() <= 0 then
        self:Destroy()
        return
    end

    self.i = (self.i or 0) + 1

    if (self:GetPos() - self.start):Length2D() > 128 then
        if self.i % 10 == 0 then
            ExecuteOrderFromTable({ UnitIndex = self:GetUnit():GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, Position = self.start })
        end
    end
end

function WKZombie:TestFalling(source)
    return Spells.TestPoint(self:GetPos(), self:GetUnit())
end