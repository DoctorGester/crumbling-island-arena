ember_q = class({})
LinkLuaModifier("modifier_ember_q", "abilities/ember/modifier_ember_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_burning", "abilities/ember/modifier_ember_burning", LUA_MODIFIER_MOTION_NONE)

function ember_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local trueHero = hero.hero or hero
    local ability = trueHero:FindAbility("ember_q")
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = ability,
        owner = trueHero,
        from = hero:GetPos(),
        to = target,
        speed = 1250,
        graphics = "particles/ember_q/ember_q.vpcf",
        distance = 1100,
        hitSound = "Arena.Ember.HitQ",
        continueOnHit = true,
        damagesTrees = true,
        hitFunction = function(projectile, target)
            target:Damage(projectile, ability:GetDamage())

            if EmberUtil.Burn(projectile:GetTrueHero(), target, ability) then
                target:AddNewModifier(projectile:GetTrueHero(), ability, "modifier_ember_q", { duration = 2.5 })
            end
        end
    }):Activate()

    hero:EmitSound("Arena.Ember.CastQ")
end

function ember_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function ember_q:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ember_q)