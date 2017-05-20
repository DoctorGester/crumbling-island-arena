lycan_r = class({})

LinkLuaModifier("modifier_lycan_r", "abilities/lycan/modifier_lycan_r", LUA_MODIFIER_MOTION_NONE)

function lycan_r:GetChannelAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_4
end

function lycan_r:GetChannelTime()
    return 1.2
end

function lycan_r:OnSpellStart()
    local hero = self:GetCaster().hero
    ImmediateEffect("particles/units/heroes/hero_lycan/lycan_loadout.vpcf", PATTACH_ABSORIGIN, hero)
    hero:EmitSound("Arena.Lycan.CastR")
end

function lycan_r:OnChannelFinish(interrupted)
    local hero = self:GetCaster().hero
    
    if interrupted then
        hero:StopSound("Arena.Lycan.CastR")
        return
    end

    hero:AddNewModifier(hero, self, "modifier_lycan_r", { duration = 6 })
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(lycan_r)