LycanUtil = {}

function LycanUtil.IsTransformed(hero)
    return hero:FindModifier("modifier_lycan_r")
end

function LycanUtil.IsBleeding(target)
    return target:FindModifier("modifier_lycan_bleed")
end

function LycanUtil.MakeBleed(hero, target, ability)
    target:AddNewModifier(hero, ability, "modifier_lycan_bleed", { duration = 4 })

    local fear = target:FindModifier("modifier_lycan_e")

    if fear then
        fear.bleedingOccured = true
    end
end

EmberUtil = {}

function EmberUtil.IsBurning(target)
    return target:HasModifier("modifier_ember_burning")
end

function EmberUtil.Burn(hero, target, ability)
    if EmberUtil.IsBurning(target) then
        target:RemoveModifier("modifier_ember_burning")
        target:EmitSound("Arena.Ember.HitCombo")
        return true
    end

    target:AddNewModifier(hero, ability, "modifier_ember_burning", { duration = 2.0 })
    return false
end

SvenUtil = {}

function SvenUtil.IsEnraged(hero)
    return hero:FindModifier("modifier_sven_r")
end

TinkerUtil = {}

function TinkerUtil.PortalAbility(ability, isPrimary, swapTo, startEffect, effect, warpEffect)
    local function FindPortal(hero, primary)
        return hero.round.spells:FilterEntities(function(ent)
            return instanceof(ent, EntityTinkerE) and ent.primary == primary and ent:Alive() and ent.hero == hero
        end)[1]
    end

    function ability:RemoveParticle()
        if self.preParticle then
            ParticleManager:DestroyParticle(self.preParticle, false)
            ParticleManager:ReleaseParticleIndex(self.preParticle)
        end
    end

    function ability:OnAbilityPhaseStart()
        self:RemoveParticle()

        self.preParticle = ParticleManager:CreateParticle(startEffect, PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(self.preParticle, 0, self:GetCursorPosition())

        self:GetCaster():EmitSound("Arena.Tinker.PreE")
        return true
    end

    function ability:OnAbilityPhaseInterrupted()
        self:RemoveParticle()
    end

    function ability:CastFilterResultLocation(location)
        if not IsServer() then return UF_SUCCESS end

        if not Spells.TestPoint(location) then
            return UF_FAIL_CUSTOM
        end

        local portal = FindPortal(self:GetCaster().hero, not isPrimary)

        if not portal then
            return UF_SUCCESS
        end

        local pos = portal:GetPos()
        if (pos - location):Length2D() <= 300 then
            return UF_FAIL_CUSTOM
        end

        return UF_SUCCESS
    end

    function ability:GetCustomCastErrorLocation(location)
        if not Spells.TestPoint(location) then
            return "#dota_hud_error_tinker_portal_outside"
        end

        local result = self:CastFilterResultLocation(location)

        if result == UF_FAIL_CUSTOM then
            return "#dota_hud_error_tinker_portal_too_close"
        end

        return ""
    end

    function ability:OnSpellStart()
        local hero = self:GetCaster().hero
        local target = self:GetCursorPosition()
        local first = FindPortal(self:GetCaster().hero, isPrimary)

        self:RemoveParticle()

        hero:EmitSound("Arena.Tinker.CastE")

        if first then
            first:Destroy()
        end

        local portal = EntityTinkerE(
            hero.round,
            hero,
            target,
            effect,
            warpEffect,
            isPrimary
        ):Activate()

        local second = FindPortal(self:GetCaster().hero, not isPrimary)

        if second then
            second:LinkTo(portal)
            portal:LinkTo(second)
        end

        hero:SwapAbilities(self:GetName(), swapTo)
    end

    function ability:GetCastAnimation()
        return ACT_DOTA_CAST_ABILITY_3
    end

    function ability:GetPlaybackRateOverride()
        return 2.0
    end
end

CMUtil = {}

function CMUtil.IsFrozen(target)
    return target:FindModifier("modifier_cm_frozen") or target:FindModifier("modifier_cm_r_slow")
end

function CMUtil.Freeze(hero, target, ability)
    target:AddNewModifier(hero, ability, "modifier_cm_frozen", { duration = 1.65 })
end

PhoenixUtil = {}

PhoenixUtil.EGG_MODIFIER = "modifier_phoenix_egg"

function PhoenixUtil.CastFitersLocation(ability)
    function ability:CastFilterResultLocation()
        return (self:GetCaster():HasModifier(EGG_MODIFIER) and UF_FAIL_CUSTOM or UF_SUCCESS)
    end

    function ability:GetCustomCastErrorLocation()
        return (self:GetCaster():HasModifier(EGG_MODIFIER) and "#dota_hud_error_cant_cast_in_egg" or "")
    end
end