sk_w = class({})

function sk_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.SK.CastW")
    SKWProjectile(hero.round, hero, target, self:GetDamage()):Activate()
end

function sk_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

SKWProjectile = SKWProjectile or class({}, nil, DistanceCappedProjectile)

SKWProjectile.EFFECT = "particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf"

function SKWProjectile:constructor(round, hero, target, damage)
	getbase(SKWProjectile).constructor(self, round, {
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 900,
        distance = 2000,
        continueOnHit = true,
        hitFunction = function(_, target)
            target:Damage(hero, damage)
            SKUtil.AbilityHit(hero, target)
        end
    })

    self.tick = 0
    self.effectPrev = self.from

    self:EmitSound("Arena.SK.LoopW")
end

function SKWProjectile:Update()
	getbase(SKWProjectile).Update(self)

	if self.tick % 5 == 0 then
        local effect = ImmediateEffect(SKWProjectile.EFFECT, PATTACH_POINT, self.hero)
    	ParticleManager:SetParticleControl(effect, 0, self.effectPrev)
    	ParticleManager:SetParticleControl(effect, 1, self:GetPos())

        self.effectPrev = self:GetPos()
    end

    if not Spells.TestCircle(self:GetNextPosition(self:GetPos()), 64) then
    	self:Destroy()
    end

    self.tick = self.tick + 1
end

function SKWProjectile:CollidesWith(target)
	return getbase(SKWProjectile).CollidesWith(self, target) and target:CanFall()
end

function SKWProjectile:CanFall()
	return true
end

function SKWProjectile:MakeFall()
	self:Destroy()
end

function SKWProjectile:Remove()
	self:StopSound("Arena.SK.LoopW")

	getbase(SKWProjectile).Remove(self)
end