zeus_w = class({})
LinkLuaModifier("modifier_zeus_w", "abilities/zeus/modifier_zeus_w", LUA_MODIFIER_MOTION_NONE)

function zeus_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300, 300)

    local hero = self:GetCaster().hero
    local casterPos = hero:GetPos()
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()

    casterPos.z = 0
    direction.z = 0

    local offset = Vector(-direction.y, direction.x, 0)
    local wallStart = target + offset * 250
    local wallEnd = target - offset * 250

    wallStart.z =  GetGroundHeight(wallStart, nil) + 32
    wallEnd.z = GetGroundHeight(wallEnd, nil) + 32

    EntityZeusW(hero, self, target, wallStart, wallEnd):Activate()
end

function zeus_w:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(zeus_w)

_G["EntityZeusW"] = EntityZeusW or class({}, nil, DynamicEntity)

function EntityZeusW:constructor(hero, ability, target, from, to)
    getbase(EntityZeusW).constructor(self, hero.round)

    self.from = from
    self.to = to

    self.hero = hero
    self.owner = hero.owner
    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.size = 500
    self.ability = ability

    self:SetInvulnerable(true)
    self.spawnTime = GameRules:GetGameTime()

    self.particle = ParticleManager:CreateParticle("particles/zeus_w2/zeus_w2.vpcf", PATTACH_CUSTOMORIGIN, hero.unit)
    ParticleManager:SetParticleControl(self.particle, 0, from)
    ParticleManager:SetParticleControl(self.particle, 1, to)

    self.specialAlly = true

    self:EmitSound("Arena.Zeus.CastW")
    self:SetPos(target)
end

function EntityZeusW:CanFall()
    return false
end

function EntityZeusW:Update()
    if GameRules:GetGameTime() - self.spawnTime > 3.5 then
        self:Destroy()
    end
end

function EntityZeusW:Remove()
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    self:EmitSound("Arena.Zeus.EndW")
end

function EntityZeusW:CollidesWith(target)
    return target.owner.team == self.owner.team and SegmentCircleIntersection(self.from, self.to, target:GetPos(), target:GetRad())
end

function EntityZeusW:CollideWith(target)
    if instanceof(target, Hero) then
        target:AddNewModifier(self.hero, self.ability, "modifier_zeus_w", { duration = 1.5 })
    end
end

function EntityZeusW:IntersectsWith(from, to)
    local s = self.from
    local f = self.to
    return SegmentsIntersect2(from.x, from.y, to.x, to.y, s.x, s.y, f.x, f.y)
end