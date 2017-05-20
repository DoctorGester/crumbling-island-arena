phoenix_e = class({})

function phoenix_e:GetChannelTime()
    return 1.2
end

function phoenix_e:OnSpellStart()
    self:GetCaster().hero:EmitSound("Arena.Phoenix.CastE")
end

function phoenix_e:GetChannelAnimation()
    return ACT_DOTA_TELEPORT
end

function phoenix_e:OnChannelFinish(interrupted)
    local hero = self:GetCaster().hero

    hero:StopSound("Arena.Phoenix.CastE")
    
    if interrupted then return end

    hero:EmitSound("Arena.Phoenix.EndE")

    if hero:FindModifier(EGG_MODIFIER) then
        hero:RemoveModifier(EGG_MODIFIER)
    else
        hero:Heal()
    end

    local up = hero:GetPos() + Vector(0, 0, 500)

    local effect = ImmediateEffect("particles/units/heroes/hero_phoenix/phoenix_supernova_scepter.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(effect, 1, up)
    ParticleManager:SetParticleControl(effect, 4, up)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(phoenix_e)