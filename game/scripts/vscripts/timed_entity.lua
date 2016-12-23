TimedEntity = TimedEntity or class({}, nil, DynamicEntity)

function TimedEntity:constructor(time, onDestroy)
    getbase(TimedEntity).constructor(self)

    self.collisionType = COLLISION_TYPE_NONE
    self.invulnerable = true

    self.timeStart = GameRules:GetGameTime()
    self.time = time

    self.onDestroy = onDestroy
end

function TimedEntity:Update()
    getbase(TimedEntity).Update(self)

    if GameRules:GetGameTime() - self.timeStart >= self.time then
        self:Destroy()
    elseif self.onUpdate then
        Spells.WrapException(self.onUpdate, self)
    end
end

function TimedEntity:SetOnActivate(onActivate)
    self.onActivate = onActivate

    return self
end

function TimedEntity:SetOnUpdate(onUpdate)
    self.onUpdate = onUpdate

    return self
end

function TimedEntity:Activate()
    if self.onActivate then
        Spells.WrapException(self.onActivate, self)
    end

    return getbase(TimedEntity).Activate(self)
end

function TimedEntity:Remove()
    if self.onDestroy then
        Spells.WrapException(self.onDestroy, self)
    end

    getbase(TimedEntity).Remove(self)
end
