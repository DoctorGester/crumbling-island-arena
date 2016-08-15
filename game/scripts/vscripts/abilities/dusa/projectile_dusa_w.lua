ProjectileDusaW = ProjectileDusaW or class({}, nil, DistanceCappedProjectile)
local self = ProjectileDusaW

function self:constructor(round, hero, target)
    getbase(ProjectileDusaW).constructor(self, round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1200,
        graphics = "particles/dusa_w/dusa_w.vpcf",
        distance = 3000,
        continueOnHit = true,
        disablePrediction = true,
        hitFunction = function(projectile, target)
            target:Damage(hero)
            target:EmitSound("Arena.Medusa.HitW")

            if instanceof(target, Hero) then
                hero:RestoreMana()
                hero:EmitSound("Arena.Medusa.HitW2")
            end
        end
    })

    self.tick = 0
end

function self:GetNextPosition(pos)
    local side = Vector(self.vel.y, -self.vel.x, 0)
    local offset = (math.cos(self.tick / 15) - 1.0) * 400
    local localFrom = Vector()
    local localTo = self.vel * 2000

    local p1 = self.vel * 400 + side * 1200
    local p2 = self.vel * 2000 - self.vel * 400 - side * 1200

    return self.from + Bezier(self.tick / 60, localFrom, p1, p2, localTo)
end

function self:Update()
    local prev = self:GetPos()
    getbase(ProjectileDusaW).Update(self)
    self:SetFacing(self:GetPos() - prev)
    self.tick = self.tick + 1
end