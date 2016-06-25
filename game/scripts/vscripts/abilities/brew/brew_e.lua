brew_e = class({})

function brew_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:GetUnit():Purge(false, true, false, false, false)
    hero:Heal()

    local effect = ParticleManager:CreateParticle("particles/items3_fx/mango_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit())
    ParticleManager:ReleaseParticleIndex(effect)

    hero:EmitSound("Arena.Brew.CastE")
    hero:EmitSound("Arena.Brew.CastE2")
end

function brew_e:GetCastAnimation()
    return ACT_DOTA_SPAWN
end

function brew_e:GetPlaybackRateOverride()
    return 2
end