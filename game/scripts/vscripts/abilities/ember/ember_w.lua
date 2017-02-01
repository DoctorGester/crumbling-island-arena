ember_w = class({})
LinkLuaModifier("modifier_ember_w", "abilities/ember/modifier_ember_w", LUA_MODIFIER_MOTION_NONE)

function ember_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/ember_w/ember_w.vpcf",
        distance = 1050,
        hitModifier = { name = "modifier_ember_w", duration = 1.0, ability = self },
        hitSound = "Arena.Ember.HitW",
        hitFunction = function(projectile, target)
            if EmberUtil.Burn(hero, target, self) then
                target:Damage(hero, self:GetDamage())
            end
        end,
        destroyFunction = function()
            hero:StopSound("Arena.Ember.CastW")
        end
    }):Activate()

    hero:EmitSound("Arena.Ember.CastW")
end

function ember_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function ember_w:GetPlaybackRateOverride()
    return 1.5
end