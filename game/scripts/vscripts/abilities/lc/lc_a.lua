lc_a = class({})

function lc_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.PL.PreQ")

    return true
end

function lc_a:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local damage = self:GetDamage()
    local force = 20

    if hero:GetUnit():GetIdealSpeed() > hero:GetUnit():GetBaseMoveSpeed() then
        damage = damage * 2
        force = 30
    end

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 300, forward, math.pi),
        sound = "Arena.LC.HitA",
        damage = damage,
        knockback = { force = force, decrease = 3 },
        isPhysical = true
    })
end

function lc_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function lc_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(lc_a, nil, "particles/melee_attack_blur.vpcf")