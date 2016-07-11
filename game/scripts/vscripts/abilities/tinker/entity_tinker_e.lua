EntityTinkerE = EntityTinkerE or class({}, nil, DynamicEntity)

function EntityTinkerE:constructor(round, owner, position, effect, warpEffect)
    getbase(EntityTinkerE).constructor(self, round, nil, position, owner:GetUnit():GetTeamNumber())

    self.hero = owner
    self.owner = { team = 0 } -- A hack to make everyone being able to think they can collide with it
    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.invulnerable = true
    self.removeOnDeath = false
    self.particle = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN, owner:GetUnit())
    ParticleManager:SetParticleControl(self.particle, 0, position)
    ParticleManager:SetParticleControl(self.particle, 1, position)
    ParticleManager:SetParticleControl(self.particle, 3, position)

    self.warpEffect = warpEffect

    self.size = 16
    self:SetPos(position)

    self.arrived = {}
end

function EntityTinkerE:CollidesWith(target)
    return true
end

function EntityTinkerE:LinkTo(target)
    self.link = target
end

function EntityTinkerE:CollideWith(target)
    if self.link and not self.arrived[target] then
        local old = target:GetPos()
        local diff = old - self:GetPos()

        self.hero:EmitSound("Arena.Tinker.HitE", old)
        self.hero:EmitSound("Arena.Tinker.HitE2", self.link:GetPos())

        target:FindClearSpace((self.link:GetPos() + diff) * Vector(1, 1, 0) + Vector(0, 0, old.z), true)
        self.link:AddArrived(target)

        local selfPos = self:GetPos()
        local index = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_start.vpcf", PATTACH_ABSORIGIN, target.unit)
        ParticleManager:SetParticleControl(index, 0, selfPos)
        ParticleManager:SetParticleControl(index, 1, selfPos)
        ParticleManager:SetParticleControl(index, 2, selfPos)
        ParticleManager:ReleaseParticleIndex(index)

        local linkPos = self.link:GetPos()
        index = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_end.vpcf", PATTACH_ABSORIGIN, target.unit)
        ParticleManager:SetParticleControl(index, 0, linkPos)
        ParticleManager:SetParticleControl(index, 1, linkPos)
        ParticleManager:SetParticleControl(index, 2, linkPos)
        ParticleManager:ReleaseParticleIndex(index)

        target.round.spells:InterruptDashes(target)
    end
end

function EntityTinkerE:AddArrived(target)
    self.arrived[target] = true
end

function EntityTinkerE:Arrived(target)
    return self.arrived[target]
end

function EntityTinkerE:Update()
    getbase(EntityTinkerE).Update(self)

    for target, _ in pairs(self.arrived) do
        if not target:Alive() or (self:GetPos() - target:GetPos()):Length2D() > 160 then
            self.arrived[target] = nil
        end
    end
end

function EntityTinkerE:MakeFall()
    self:Destroy()
end

function EntityTinkerE:CanFall()
    return true
end

function EntityTinkerE:Remove()
    getbase(EntityTinkerE).Remove(self)

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end