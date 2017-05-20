ursa_a = class({})

LinkLuaModifier("modifier_ursa_frenzy", "abilities/ursa/modifier_ursa_frenzy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ursa_fury", "abilities/ursa/modifier_ursa_fury", LUA_MODIFIER_MOTION_NONE)

function ursa_a:OnAbilityPhaseStart()
    self:GetCaster():GetParentEntity():EmitSound("Arena.Ursa.PreA")

    return true
end

function ursa_a:GetCooldown(level)
    return self:GetCaster():HasModifier("modifier_ursa_w") and 0.1 or self.BaseClass.GetCooldown(self, level)
end

function ursa_a:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    local overpower = hero:HasModifier("modifier_ursa_w")
    local damage = self:GetDamage()

    if hero:HasModifier("modifier_ursa_frenzy") then
        damage = damage * 2
    end

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(hero:GetPos(), 300, direction, math.pi),
        sound = "Arena.Ursa.HitA",
        damage = damage,
        knockback = { force = 20, decrease = 3 },
        action = function(victim)
            if overpower and instanceof(victim, Hero) then
                hero:Heal(damage)

                local index = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit())
                ParticleManager:ReleaseParticleIndex(index)
            end
        end,
        isPhysical = true
    })
end

function ursa_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function ursa_a:GetPlaybackRateOverride()
    return 1.5
end

function ursa_a:GetIntrinsicModifierName()
    return "modifier_ursa_fury"
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(ursa_a, nil, "particles/melee_attack_blur.vpcf")