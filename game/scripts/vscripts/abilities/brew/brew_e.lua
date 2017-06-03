brew_e = class({})

function brew_e:GetCooldown(level)
    if IsClient() then
        return self.BaseClass.GetCooldown(self, level) - (self:GetCaster().beerStacks or 0)
    end

    local hero = self:GetCaster().hero

    return self.BaseClass.GetCooldown(self, level) - hero:FindAbility("brew_q"):CountBeer(hero)
end

function brew_e:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:GetUnit():Purge(false, true, false, false, false)
    hero:Heal(2)

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