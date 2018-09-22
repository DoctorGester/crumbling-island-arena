timber_a = class({})

function timber_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.Timber.CastA")

    return true
end

function timber_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300
    local damage = self:GetDamage()

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.Timber.HitA",
        damagesTreesx2 = true,
        action = function(target)
            if not instanceof(target, Obstacle) then
                target:Damage(hero, damage, true)
            end
        end,
        knockback = { force = 20, decrease = 3 },
        isPhysical = true
    })
end

function timber_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function timber_a:GetPlaybackRateOverride()
    return 2.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(timber_a, nil, "particles/melee_attack_blur.vpcf")
