TinyQ = class({}, nil, DynamicEntity)

function TinyQ:constructor(owner, ability, target, stun)
    DynamicEntity.constructor(self)

    local start = owner:GetPos() + Vector(0, 0, 64)

    self.owner = owner.owner
    self.hero = owner
    self.ability = ability
    self.dir = ((target - start) * Vector(1, 1, 0)):Normalized()
    self.size = 64
    self.speed = 60
    self.heightVel = 4
    self.fell = false
    self.stun = stun
    self.picked = false
    self.enemiesHit = {}

    self.unit = CreateUnitByName(DUMMY_UNIT, start, false, nil, nil, DOTA_TEAM_NOTEAM)
    self.unit:SetForwardVector(self.dir)
    self.unit:SetNeverMoveToClearSpace(true)

    self.particle = ParticleManager:CreateParticle("particles/tiny_q/tiny_q.vpcf", PATTACH_ABSORIGIN_FOLLOW , self.unit)
    self.flyParticle = ParticleManager:CreateParticle("particles/tiny_q/tiny_q_fly_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW , self.unit)

    self:SetPos(start)
end

function TinyQ:FilterTarget(prev, pos, source, target)
    if target == self or target == self.hero then return false end
    if self.enemiesHit[target] then return false end

    if SegmentCircleIntersection(prev, pos, target:GetPos(), self:GetRad() + target:GetRad()) then
        if target:__instanceof__(TinyQ) then
            self:Destroy()
            target:Destroy()
            return false
        end

        self.enemiesHit[target] = true

        target:AddNewModifier(self.hero, self.ability, "modifier_tiny_q", { hidden = self.stun, duration = 1.5 })
        if self.stun then
            target:AddNewModifier(self.hero, self.ability, "modifier_stunned", { duration = 1.5 })
        end

        target:EmitSound("Arena.Tiny.HitQ")

        return true
    end
end

function TinyQ:Update()
    local pos = self:GetPos()
    local oldPos = pos

    if self.speed > 0 then
        pos = pos + self.dir * self.speed

        local ground = GetGroundHeight(pos, nil)

        if ground > pos.z then
            self.speed = 0
            self.fell = true
            self.hero:EmitSound("Arena.Tiny.LandQ", pos)

            if not self.secondParticle then
                self.secondParticle = ParticleManager:CreateParticle("particles/tiny_q/tiny_q_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW , self.unit)
            end

            local newPos = self:GetPos()
            newPos.z = GetGroundHeight(newPos, nil)

            self:SetPos(newPos)
            self.unit:SetAbsOrigin(self:GetPos())
            self:RemoveSmoke()
        else
            pos.z = math.max(pos.z + self.heightVel, ground)

            self.heightVel = self.heightVel - 1

            local decay = 1

            if pos.z == ground then
                decay = 3

                if not self.fell then
                    self.fell = true

                    self.secondParticle = ParticleManager:CreateParticle("particles/tiny_q/tiny_q_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW , self.unit)
                    self.hero:EmitSound("Arena.Tiny.LandQ", pos)
                    self:RemoveSmoke()
                end
            end

            self.speed = math.max(self.speed - decay, 0)

            self:SetPos(pos)
            self.unit:SetAbsOrigin(self:GetPos())

            Spells:MultipleHeroesDamage(self,
                function (attacker, target)
                    return self:FilterTarget(oldPos, pos, attacker, target)
                end
            )
        end
    else
        if (self.hero:GetPos() - self:GetPos()):Length2D() <= self.hero:GetRad() + self:GetRad() then
            self.picked = true
            self.hero:EmitSound("Arena.Tiny.PickQ")
            self.ability:EndCooldown()
        end

        if self.secondParticle then
            ParticleManager:DestroyParticle(self.secondParticle, false)
            ParticleManager:ReleaseParticleIndex(self.secondParticle)
            self.secondParticle = nil
        end
    end

    if self.ability:IsCooldownReady() or self.owner.destroyed then
        self:Destroy()
    end
end

function TinyQ:RemoveSmoke()
    if self.flyParticle then
        ParticleManager:DestroyParticle(self.flyParticle, true)
        ParticleManager:ReleaseParticleIndex(self.flyParticle)

        self.flyParticle = nil
    end
end

function TinyQ:Remove()
    if not self.picked then
        self.hero:EmitSound("Arena.Tiny.EndQ", self:GetPos())
    end

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    if self.secondParticle then
        ParticleManager:DestroyParticle(self.secondParticle, false)
        ParticleManager:ReleaseParticleIndex(self.secondParticle)
    end

    self:RemoveSmoke()
    self.unit:RemoveSelf()
end
