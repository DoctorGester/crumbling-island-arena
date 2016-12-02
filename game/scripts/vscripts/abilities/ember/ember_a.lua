ember_a = class({})

function ember_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Ember.CastA")

    return true
end

function ember_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 275)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 275
    local damage = self:GetDamage()

    hero:AreaEffect({
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.Ember.HitA",
        action = function(target)
            if EmberUtil.IsBurning(target) then
                target:Damage(hero, damage * 2, true)
            else
                target:Damage(hero, damage, true)
            end
        end,
        knockback = { force = 20, decrease = 3 },
        isPhysical = true
    })
end

function ember_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function ember_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(ember_a, nil, "particles/melee_attack_blur.vpcf")