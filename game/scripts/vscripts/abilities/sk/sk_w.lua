sk_w = class({})

function sk_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.SK.CastW")
    SKWProjectile(hero.round, hero, target, self):Activate()
end

function sk_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

SKWProjectile = SKWProjectile or class({}, nil, DistanceCappedProjectile)

SKWProjectile.EFFECT = "particles/sk_w/sk_w_eruption.vpcf"

function SKWProjectile:constructor(round, hero, target, ability)
	getbase(SKWProjectile).constructor(self, round, {
        ability = ability,
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 900,
        distance = 2000,
        damagesTrees = true,
        continueOnHit = true,
        considersGround = true,
        goesThroughTrees = true,
        ignoreProjectiles = true,
        hitFunction = function(projectile, target)
            target:Damage(projectile, ability:GetDamage())
            SKUtil.AbilityHit(projectile:GetTrueHero(), target)
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

    self.tick = self.tick + 1
end

function SKWProjectile:CollidesWith(target)
	return getbase(SKWProjectile).CollidesWith(self, target) and not target:IsAirborne()
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

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(sk_w)