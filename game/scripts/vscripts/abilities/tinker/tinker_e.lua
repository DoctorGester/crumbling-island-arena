tinker_e = class({})

require("abilities/tinker/entity_tinker_e")

function tinker_e:RemoveParticle()
    if self.preParticle then
        ParticleManager:DestroyParticle(self.preParticle, false)
        ParticleManager:ReleaseParticleIndex(self.preParticle)
    end
end

function tinker_e:OnAbilityPhaseStart()
    self:RemoveParticle()

    self.preParticle = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_start_bots.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.preParticle, 0, self:GetCursorPosition())

    self:GetCaster():EmitSound("Arena.Tinker.PreE")
    return true
end

function tinker_e:OnAbilityPhaseInterrupted()
    self:RemoveParticle()
end

function tinker_e:CastFilterResultLocation(location)
    if not IsServer() then return UF_SUCCESS end

    local portal = self:GetCaster().hero:GetSecondPortal()

    if not portal then
        return UF_SUCCESS
    end

    local pos = portal:GetPos()
    if (pos - location):Length2D() <= 300 then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function tinker_e:GetCustomCastErrorLocation(location)
    local result = self:CastFilterResultLocation(location)

    if result == UF_FAIL_CUSTOM then
        return "#dota_hud_error_tinker_portal_too_close"
    end

    return ""
end

function tinker_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local first = hero:GetFirstPortal()

    self:RemoveParticle()

    hero:EmitSound("Arena.Tinker.CastE")

    if first then
        first:Destroy()
    end

    local portal = EntityTinkerE(
        hero.round,
        hero,
        target,
        "particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf",
        "particles/econ/items/tinker/boots_of_travel/teleport_end_bots_warp_b.vpcf"
    ):Activate()

    hero:SetFirstPortal(portal)

    local second = hero:GetSecondPortal()

    if second then
        second:LinkTo(portal)
        portal:LinkTo(second)
    end

    hero:SwapAbilities("tinker_e", "tinker_e_sub")
end

function tinker_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function tinker_e:GetPlaybackRateOverride()
    return 1.0
end