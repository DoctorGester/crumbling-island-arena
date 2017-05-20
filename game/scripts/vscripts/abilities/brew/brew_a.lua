brew_a = class({})

function brew_a:OnAbilityPhaseStart()
    local hero = self:GetCaster():GetParentEntity()
    local stacks = hero:FindAbility("brew_q"):CountBeer(hero)

    hero:EmitSound(stacks >= 2 and "Arena.Brew.CastA2" or "Arena.Brew.CastA")

    return true
end

function brew_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300
    local damage = self:GetDamage()
    local force = 20
    local stacks = hero:FindAbility("brew_q"):CountBeer(hero)

    if stacks >= 2 then
        damage = damage * 2
        force = force * 1.5
    end

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.Brew.HitA",
        damage = damage,
        knockback = { force = force, decrease = 3 },
        isPhysical = true
    })
end

function brew_a:GetCastAnimation()
    local hero = self:GetCaster():GetParentEntity()
    local stacks = hero:FindAbility("brew_q"):CountBeer(hero)

    if stacks >= 2 then
        return ACT_DOTA_ATTACK_EVENT
    end

    return ACT_DOTA_ATTACK
end

function brew_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(brew_a, nil, "particles/melee_attack_blur.vpcf")