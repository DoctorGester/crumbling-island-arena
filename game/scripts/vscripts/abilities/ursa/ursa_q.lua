ursa_q = class({})

function ursa_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 250)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()
    local overpower = hero:HasModifier("modifier_ursa_e")

    local hit = hero:AreaEffect({
        filter = Filters.Cone(hero:GetPos(), 250, direction, math.pi),
        sound = "Arena.Ursa.HitQ",
        damage = true
    })

    if overpower then
        self:EndCooldown()
        self:StartCooldown(0.35)

        if hit then
            hero:Heal()

            local index = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit())
            ParticleManager:ReleaseParticleIndex(index)
        end
    end
end

function ursa_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function ursa_q:GetPlaybackRateOverride()
    return 1.5
end