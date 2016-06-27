ursa_q = class({})

function ursa_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()
    local overpower = hero:HasModifier("modifier_ursa_e")

    hero:AreaEffect({
        filter = Filters.Cone(hero:GetPos(), 300, direction, math.pi),
        sound = "Arena.Ursa.HitQ",
        damage = true,
        action = function(victim)
            if overpower and instanceof(victim, Hero) then
                hero:Heal()

                local index = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit())
                ParticleManager:ReleaseParticleIndex(index)
            end
        end
    })

    if overpower then
        self:EndCooldown()
        self:StartCooldown(0.35)
    end
end

function ursa_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function ursa_q:GetPlaybackRateOverride()
    return 1.5
end