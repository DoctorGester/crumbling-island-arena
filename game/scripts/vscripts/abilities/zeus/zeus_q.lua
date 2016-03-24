zeus_q = class({})

function zeus_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    ZeusQProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1200,
        graphics = "particles/zeus_q/zeus_q.vpcf",
        distance = 800,
        hitSound = "Arena.Zeus.HitQ",
        hitFunction = function(projectile, target)
            target:Damage(hero)

            if projectile.empowered then
                if self:GetCooldownTimeRemaining() > 0.4 then
                    self:EndCooldown()
                    self:StartCooldown(0.4)
                end
            end
        end
    }):Activate()

    hero:EmitSound("Arena.Zeus.CastQ")
end

function zeus_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

ZeusQProjectile = ZeusQProjectile or class({}, nil, DistanceCappedProjectile)

function ZeusQProjectile:constructor(...)
    getbase(ZeusQProjectile).constructor(self, ...)

    self.empowered = false
end

function ZeusQProjectile:Update()
    local prev = self:GetPos()
    getbase(ZeusQProjectile).Update(self)
    local pos = self:GetPos()

    if not self.empowered and self.hero:WallIntersection(prev, pos) then
        self.distance = 3000
        self.empowered = true

        self:EmitSound("Arena.Zeus.EmpowerQ")
    end
end

function ZeusQProjectile:GetSpeed()
    if self.empowered then
        return 3000
    end

    return 1200
end