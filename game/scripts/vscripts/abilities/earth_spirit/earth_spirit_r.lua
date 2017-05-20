earth_spirit_r = class({})
LinkLuaModifier("modifier_earth_spirit_remnant", "abilities/earth_spirit/modifier_earth_spirit_remnant", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_r:GetChannelAnimation()
    return ACT_DOTA_CAST_ABILITY_5
end

function earth_spirit_r:GetChannelTime()
    return 0.5
end

function earth_spirit_r:OnSpellStart()
    self:GetCaster().hero:EmitSound("Arena.Earth.CastR")
end

function earth_spirit_r:CastFilterResultLocation(location)
    if not IsServer() then return UF_SUCCESS end

    local hero = self:GetCaster():GetParentEntity()
    if not hero:FindNonEnemyStandRemnantCursor(self, location) then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function earth_spirit_r:GetCustomCastErrorLocation(location)
    if not IsServer() then return "" end

    local hero = self:GetCaster():GetParentEntity()
    if not hero:FindNonEnemyStandRemnantCursor(self, location) then
        return "#dota_hud_error_earth_spirit_cant_cast_no_remnant"
    end

    return ""
end

function earth_spirit_r:OnChannelFinish(interrupted)
    if interrupted then return end

    local hero = self:GetCaster().hero
    local remnant = hero:FindNonEnemyStandRemnantCursor(self)

    if not remnant then return end

    hero.round.spells:InterruptDashes(remnant)

    local particlePath = "particles/units/heroes/hero_earth_spirit/espirit_magnet_arclightning.vpcf"
    local particle = ImmediateEffect(particlePath, PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, hero:GetPos())
    ParticleManager:SetParticleControl(particle, 1, remnant:GetPos())

    local swapVars = { "wearables", "wearableParticles", "mappedParticles", "wearableSlots", "lastStatusFx" }

    for _, var in pairs(swapVars) do
        local temp = hero[var]
        hero[var] = remnant[var]
        remnant[var] = temp
    end

    local remnantUnit = remnant.unit
    remnantUnit:SetTeam(hero.owner.team)
    remnant:SetUnit(hero.unit, hero:HasRemnantStand())
    remnant:SetPos(hero:GetPos())

    if hero:HasRemnantStand() then
        local stand = hero:GetRemnantStand()
        hero:GetRemnantStand():SetStandingHero(nil)
        stand:Destroy()
    end

    hero:EmitSound("Arena.Earth.EndR")
    hero:EmitSound("Arena.Earth.EndR.Voice")
    hero:AddNewModifier(hero, self, "modifier_earth_spirit_remnant", {})
    FreezeAnimation(hero.unit)

    remnantUnit:RemoveModifierByName("modifier_earth_spirit_remnant")
    remnantUnit:FindAbilityByName(self:GetAbilityName()):StartCooldown(self:GetCooldown(1))
    hero:SetUnit(remnantUnit)
    hero:SetOwner(hero.owner) -- Just refreshing control
    hero:Setup()

    remnantUnit:SetHealth(remnant.health)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(earth_spirit_r)