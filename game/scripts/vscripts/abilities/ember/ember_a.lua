ember_a = class({})

function ember_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Ember.CastA")

    return true
end

function ember_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300
    local damage = self:GetDamage()

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.Ember.HitA",
        action = function(target)
            if EmberUtil.IsBurning(target) then
                ability = hero:FindAbility("ember_a")
                ability:EndCooldown()
                ability:StartCooldown(0.3)
            end
            target:Damage(hero, damage, true)
        end,
        knockback = { force = 20, decrease = 3 },
        isPhysical = true,
        damagesTrees = true
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