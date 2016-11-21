TinyQ = TinyQ or class({}, nil, Projectile)

function TinyQ:constructor(round, owner, ability, target, stun, damage)
    local modifierName = (stun and "modifier_stunned_lua" or "modifier_tiny_q")

    self.groundHeight = GetGroundHeight(target, nil)

    getbase(TinyQ).constructor(self, round, {
        owner = owner,
        from = owner:GetPos() * Vector(1, 1, 0) + Vector(0, 0, 64) + self.groundHeight,
        to = target,
        hitModifier = { name = modifierName, duration = 1.5, ability = ability },
        hitSound = "Arena.Tiny.HitQ",
        graphics = "particles/tiny_q/tiny_q.vpcf",
        speed = 1800,
        continueOnHit = true,
        disablePrediction = true,
        damage = damage
    })

    self.fell = false
    self.fallingDirection = nil
    self.picked = false
    self.heightVel = 4
    self.removeOnDeath = true
    self.ability = ability
    self.flyParticle = ParticleManager:CreateParticle("particles/tiny_q/tiny_q_fly_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW , self:GetUnit())
end

function TinyQ:CanFall()
    return self.fell
end

function TinyQ:CollideWith(target)
    if self:GetSpeed() == 0 and target == self.hero then
        self.picked = true
        self.hero:EmitSound("Arena.Tiny.PickQ")
        self.ability:EndCooldown()
    else
        getbase(TinyQ).CollideWith(self, target)
    end
end

function TinyQ:CollidesWith(target)
    if self:GetSpeed() == 0 then
        return target == self.hero
    else
        return getbase(TinyQ).CollidesWith(self, target)
    end
end

function TinyQ:MakeFall()
    getbase(TinyQ).MakeFall(self)

    self.fallingDirection = self:GetNextPosition(self:GetPos()) - self:GetPos()
    
    self:RemoveGroundEffect()
end

function TinyQ:Damage() end

function TinyQ:GetNextPosition(pos)
    local position = getbase(TinyQ).GetNextPosition(self, pos)

    position.z = math.max(position.z + self.heightVel, self.groundHeight)

    return position
end

function TinyQ:Update()
    getbase(TinyQ).Update(self)

    if self.falling then
        self:SetPos(self:GetPos() + self.fallingDirection)
        return
    end

    local speed = self:GetSpeed()

    if speed > 0 then
        local decay = 30

        if self:GetPos().z == self.groundHeight then
            decay = 90

            if not self.fell then
                self.fell = true

                if self:TestFalling() then
                    self.secondParticle = ParticleManager:CreateParticle("particles/tiny_q/tiny_q_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW , self.unit)
                    self:EmitSound("Arena.Tiny.LandQ", pos)

                    Spells:GroundDamage(self:GetPos(), 128, self.hero)
                end

                self:RemoveSmoke()
            end
        end

        self.heightVel = self.heightVel - 1
        speed = math.max(self.speed - decay, 0)
        self:SetSpeed(speed)
    else
        self:RemoveGroundEffect()
    end

    if self.ability:IsCooldownReady() or self.hero.destroyed then
        self:Destroy()
    end
end

function TinyQ:RemoveGroundEffect()
    if self.secondParticle then
        ParticleManager:DestroyParticle(self.secondParticle, false)
        ParticleManager:ReleaseParticleIndex(self.secondParticle)

        self.secondParticle = nil
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

    local speed = self.hero:FindModifier("modifier_tiny_q_speed")

    if speed then
        speed:SetStackCount(0)
    end

    self:RemoveGroundEffect()
    self:RemoveSmoke()
    
    getbase(TinyQ).Remove(self)
end
