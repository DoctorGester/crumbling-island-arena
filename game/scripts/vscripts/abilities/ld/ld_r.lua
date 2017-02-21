ld_r = class({})

LinkLuaModifier("modifier_ld_r", "abilities/ld/modifier_ld_r", LUA_MODIFIER_MOTION_NONE)

function ld_r:GetPlaybackRateOverride()
    return 5.0
end

function ld_r:GetChannelAnimation()
    if self:GetCaster():HasModifier("modifier_ld_r") then
        return ACT_DOTA_OVERRIDE_ABILITY_4
    end

    return ACT_DOTA_OVERRIDE_ABILITY_3
end

function ld_r:GetChannelTime()
    return 0.3
end

function ld_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local effect = ParticleManager:CreateParticle("particles/ld_r/ld_r.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(effect)

    if hero:HasModifier("modifier_ld_r") then
        hero:EmitSound("Arena.LD.CastR")
    else
        hero:EmitSound("Arena.LD.CastR2")
    end
end

function ld_r:OnChannelFinish(interrupted)
    local hero = self:GetCaster().hero
    
    if interrupted then
        hero:StopSound("Arena.Lycan.CastR")
        return
    end

    if hero:HasModifier("modifier_ld_r") then
        hero:RemoveModifier("modifier_ld_r")
    else
        hero:AddNewModifier(hero, self, "modifier_ld_r", {})
    end
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ld_r)