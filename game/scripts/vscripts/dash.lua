Dash = Dash or class({})

function Dash:constructor(hero, to, speed, params)
    self.hero = hero
    self.to = to
    self.velocity = speed / 30

    self.from = hero:GetPos()
    self.zStart = hero:GetGroundHeight(self.from)

    self.findClearSpace = params.findClearSpace or true
    self.radius = params.radius or 128

    self.PositionFunction = params.positionFunction or self.PositionFunction
    self.HeightFunction = params.heightFunction or self.HeightFunction
    self.OnArrival = params.onArrival or self.OnArrival

    self.destroyed = false
end

function Dash:Update()
    local origin = self.hero:GetPos()
    local result = self:PositionFunction(origin)

    result.z = self.zStart + self:HeightFunction(origin)

    self.hero:SetPos(result)

    if (self.to - origin):Length2D() <= self.velocity then
        if self.findClearSpace then
            GridNav:DestroyTreesAroundPoint(result, self.radius, true)
            self.hero:FindClearSpace(result, false)
        end

        self:OnArrival()
        self.destroyed = true
    end
end

function Dash:PositionFunction(current)
    local diff = self.to - current
    return current + (diff:Normalized() * self.velocity)
end

function Dash:HeightFunction(current)
    return 0
end

function Dash:OnArrival() end