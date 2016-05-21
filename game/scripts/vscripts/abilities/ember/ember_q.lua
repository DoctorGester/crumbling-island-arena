ember_q = class({})
LinkLuaModifier("modifier_ember_q", "abilities/ember/modifier_ember_q", LUA_MODIFIER_MOTION_NONE)

function ember_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 1250,
        graphics = "particles/ember_q/ember_q.vpcf",
        distance = 1300,
        hitSound = "Arena.Ember.HitQ",
        continueOnHit = true,
        hitFunction = function(projectile, target)
            target:Damage(hero)

            if hero:Burn(target, self) then
                target:AddNewModifier(hero, self, "modifier_ember_q", { duration = 2.5 })
            end
        end
    }):Activate()

    hero:EmitSound("Arena.Ember.CastQ")
end

function ember_q:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function ember_q:GetPlaybackRateOverride()
    return 2.0
end