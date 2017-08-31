lycan_a = class({})

function lycan_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Pudge.CastA")

    return true
end

function lycan_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300
    local damage = self:GetDamage()

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.Lycan.HitA",
        damagesTrees = true,
        action = function(target)
            local dmg = damage

            if LycanUtil.IsTransformed(hero) and LycanUtil.IsBleeding(target) then
                dmg = dmg * 2
            end

            LycanUtil.MakeBleed(hero, target)

            target:Damage(hero, dmg, true)
        end,
        knockback = { force = 20, decrease = 3 },
        isPhysical = true
    })
end

function lycan_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function lycan_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(lycan_a, nil, "particles/melee_attack_blur.vpcf")