wk_a = class({})

function wk_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Sven.CastA")

    return true
end

function wk_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300

    hero:AreaEffect({
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.WK.HitA",
        action = function(victim)
            hero:Heal(1)

            FX("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, {
                cp1 = { ent = victim, attach = PATTACH_ABSORIGIN_FOLLOW },
                release = true
            })

            FX("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, { release = true })
        end,
        knockback = { force = 20, decrease = 3 },
        damage = self:GetDamage(),
        isPhysical = true
    })
end

function wk_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function wk_a:GetPlaybackRateOverride()
    return 4
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(wk_a, nil, "particles/melee_attack_blur.vpcf")