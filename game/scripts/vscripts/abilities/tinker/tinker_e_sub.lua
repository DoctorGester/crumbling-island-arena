tinker_e_sub = class({})

function tinker_e_sub:RemoveParticle()
    if self.preParticle then
        ParticleManager:DestroyParticle(self.preParticle, false)
        ParticleManager:ReleaseParticleIndex(self.preParticle)
    end
end

function tinker_e_sub:OnAbilityPhaseInterrupted()
    self:RemoveParticle()
end

function tinker_e_sub:OnAbilityPhaseStart()
    self:RemoveParticle()

    self.preParticle = ParticleManager:CreateParticle("particles/tinker_e/tinker_e_second_pre.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.preParticle, 0, self:GetCursorPosition())

    self:GetCaster():EmitSound("Arena.Tinker.PreE")
    return true
end

function tinker_e_sub:CastFilterResultLocation(location)
    if not IsServer() then return UF_SUCCESS end

    local portal = self:GetCaster().hero:GetFirstPortal()

    if not portal then
        return UF_SUCCESS
    end
    
    local pos = portal:GetPos()
    if (pos - location):Length2D() <= 300 then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function tinker_e_sub:GetCustomCastErrorLocation(location)
    local result = self:CastFilterResultLocation(location)

    if result == UF_FAIL_CUSTOM then
        return "#dota_hud_error_tinker_portal_too_close"
    end

    return ""
end

function tinker_e_sub:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local second = hero:GetSecondPortal()

    self:RemoveParticle()
    
    hero:EmitSound("Arena.Tinker.CastE")

    if second then
        second:Destroy()
    end

    local portal = EntityTinkerE(
        hero.round,
        hero,
        target,
        "particles/tinker_e/tinker_e_second.vpcf", "particles/tinker_e/tinker_e_second_warp_b.vpcf"
    ):Activate()
    
    hero:SetSecondPortal(portal)

    local first = hero:GetFirstPortal()

    if first then
        first:LinkTo(portal)
        portal:LinkTo(first)
    end

    hero:SwapAbilities("tinker_e_sub", "tinker_e")
end

function tinker_e_sub:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function tinker_e_sub:GetPlaybackRateOverride()
    return 1.0
end