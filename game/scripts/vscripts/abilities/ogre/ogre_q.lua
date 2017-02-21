ogre_q = class({})

LinkLuaModifier("modifier_ogre_1", "abilities/ogre/ogre_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ogre_2", "abilities/ogre/ogre_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ogre_3", "abilities/ogre/ogre_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ogre_4", "abilities/ogre/ogre_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ogre_5", "abilities/ogre/ogre_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ogre_6", "abilities/ogre/ogre_modifiers", LUA_MODIFIER_MOTION_NONE)

function ogre_q:RemoveParticle()
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function ogre_q:OnAbilityPhaseStart()
    local target = self:GetCaster()
    local hero = target.hero

    self.spell = hero:GetCurrentSpell()
    hero:SpendCurrentSpell()

    self.particle = ParticleManager:CreateParticle(self.spell.effectName, PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(self.particle, 0, target, PATTACH_POINT_FOLLOW, "attach_toss", target:GetAbsOrigin(), true)
    CreateAOEMarker(hero, self:GetCursorPosition(), 300, 1.0, Vector(255, 106, 0))

    return true
end

function ogre_q:OnAbilityPhaseInterrupted()
    self:RemoveParticle()
end

function ogre_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1500)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local projectile = ArcProjectile(self.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target,
        speed = 2500,
        arc = 600,
        hitParams = {
            filter = Filters.Area(target, 300),
            filterProjectiles = true,
            damage = self.spell.damage,
            hitAllies = true,
            modifier = {
                name = self.spell.modifier,
                duration = self.spell.duration,
                ability = self
            },
            action = function(target)
                if not self.spell.damage then
                    target:Heal()
                end
            end
        },
        hitScreenShake = true,
        hitFunction = function(projectile, hit)
            if self.spell.explosion then
                hero:ExplosionEffect(self.spell, projectile:GetPos())
            end

            projectile:EmitSound("Arena.Ogre.HitQ")
            projectile:EmitSound(self.spell.sound)
        end
    }):Activate()

    projectile.particle = self.particle
    ParticleManager:SetParticleControlEnt(self.particle, 0, projectile:GetUnit(), PATTACH_POINT_FOLLOW, nil, projectile:GetUnit():GetAbsOrigin(), true)

    hero:EmitSound("Arena.Ogre.CastQ")
end

function ogre_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function ogre_q:GetPlaybackRateOverride()
    return 1.05
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ogre_q)