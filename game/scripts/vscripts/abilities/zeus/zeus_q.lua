zeus_q = class({})

function zeus_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 800)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    ZeusQProjectile(self, hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1200,
        graphics = "particles/zeus_q/zeus_q.vpcf",
        distance = 800,
        hitSound = "Arena.Zeus.HitQ"
    }):Activate()

    hero:EmitSound("Arena.Zeus.CastQ")
end

function zeus_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

_G["ZeusQProjectile"] = ZeusQProjectile or class({}, nil, DistanceCappedProjectile)

function ZeusQProjectile:constructor(ability, ...)
    getbase(ZeusQProjectile).constructor(self, ...)

    self.ability = ability
    self.empowered = false
end

function ZeusQProjectile:Empower()
    self.distance = 3000
    self.empowered = true

    self.hitModifier = { name = "modifier_stunned_lua", duration = 1.0, ability = self.ability }
    self.hitSound = "Arena.Zeus.HitQ2"
    self:EmitSound("Arena.Zeus.EmpowerQ")
    self:SetGraphics("particles/zeus_q_emp/zeus_q_emp.vpcf")
end

function ZeusQProjectile:GetSpeed()
    if self.empowered then
        return 2500 * self.currentMultiplier
    end

    return 1200 * self.currentMultiplier
end