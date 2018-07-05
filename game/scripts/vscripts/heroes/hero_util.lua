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

function TinkerUtil.FindPortal(hero, primary)
    return hero.round.spells:FilterEntities(function(ent)
        return instanceof(ent, EntityTinkerE) and ent.primary == primary and ent:Alive() and ent.hero == hero
    end)[1]
end

function TinkerUtil.PortalAbility(ability, isPrimary, swapTo, startEffect, effect, warpEffect)
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

        local portal = TinkerUtil.FindPortal(self:GetCaster().hero, not isPrimary)

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
        local first = TinkerUtil.FindPortal(self:GetCaster().hero, isPrimary)

        ScreenShake(target, 5, 150, 0.25, 3000, 0, true)

        self:RemoveParticle()

        hero:EmitSound("Arena.Tinker.CastE")
        hero:SwapAbilities(self:GetName(), swapTo)

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

        local second = TinkerUtil.FindPortal(self:GetCaster().hero, not isPrimary)

        if second then
            second:LinkTo(portal)
            portal:LinkTo(second)
        end
    end

    function ability:GetCastAnimation()
        return ACT_DOTA_CAST_ABILITY_3
    end

    function ability:GetPlaybackRateOverride()
        return 2.0
    end

    if IsClient() then
        require("wrappers")
    end

    Wrappers.NormalAbility(ability)
end

function TinkerUtil.PortalCancelAbility(ability, isPrimary, swapTo)
    function ability:OnSpellStart()
        local hero = self:GetCaster():GetParentEntity()
        local portal = TinkerUtil.FindPortal(hero, isPrimary)

        if portal then
            portal:Destroy()
        end
    end

    if IsClient() then
        require("wrappers")
    end

    Wrappers.NormalAbility(ability)
end

CMUtil = {}

function CMUtil.IsFrozen(target)
    return target:FindModifier("modifier_cm_frozen")
end

function CMUtil.Stun(hero, target, ability)
    target:AddNewModifier(hero, ability, "modifier_cm_stun", { duration = 0.9 })
end

function CMUtil.Freeze(hero, target, ability)
    target:AddNewModifier(hero, ability, "modifier_cm_frozen", { duration = 1.65 })
end

function CMUtil.AbilityHit(hero, target, ability)
    target:Damage(hero, ability:GetDamage())

    if CMUtil.IsFrozen(target) then
        CMUtil.Stun(hero, target, ability)
    end

    CMUtil.Freeze(hero, target, ability)

    if instanceof(target, Hero) then

    local mod = hero:FindModifier("modifier_cm_a")
        if mod then
            if mod:GetStackCount() < 3 then
                mod:Inc()
            end
        else
            mod = hero:AddNewModifier(hero, hero:FindAbility("cm_a"), "modifier_cm_a")

            if mod then
                mod:SetStackCount(1)
            end
        end
    end
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

TinyUtil = {}

function TinyUtil.ChangeModelLevel(hero, previous, level)
    local model = hero:GetUnit():FirstMoveChild()

    local function GenerateModelNames(suffix)
        return {
            string.format("models/heroes/tiny_0%s/tiny_0%s_" .. suffix .. ".vmdl", 1, 1),
            string.format("models/heroes/tiny_0%s/tiny_0%s_" .. suffix .. ".vmdl", 2, 2),
            string.format("models/heroes/tiny_0%s/tiny_0%s_" .. suffix .. ".vmdl", 3, 3),
            string.format("models/heroes/tiny_0%s/tiny_0%s_" .. suffix .. ".vmdl", 4, 4)
        }
    end

    local standardModels = {
        GenerateModelNames("body"),
        GenerateModelNames("head"),
        GenerateModelNames("left_arm"),
        GenerateModelNames("right_arm")
    }

    local awardPrefix = "models/items/tiny/burning_stone_giant_"

    local awardModels = {
        {
            awardPrefix .. "body/burning_stone_giant_body.vmdl",
            awardPrefix .. "body_level_2/burning_stone_giant_body_level_2.vmdl",
            awardPrefix .. "body_level_3/burning_stone_giant_body_level_3.vmdl",
            awardPrefix .. "body_level_4/burning_stone_giant_body_level_4.vmdl",
        },
        {
            awardPrefix .. "head/burning_stone_giant_head.vmdl",
            awardPrefix .. "head_level_2/burning_stone_giant_head_level_2.vmdl",
            awardPrefix .. "head_level_3/burning_stone_giant_head_level_3.vmdl",
            awardPrefix .. "head_level_4/burning_stone_giant_head_level_4.vmdl",
        },
        {
            awardPrefix .. "left_arm/burning_stone_giant_left_arm.vmdl",
            awardPrefix .. "left_arm_level_2/burning_stone_giant_left_arm_level_2.vmdl",
            awardPrefix .. "left_arm_level_3/burning_stone_giant_left_arm_level_3.vmdl",
            awardPrefix .. "left_arm_level_4/burning_stone_giant_left_arm_level_4.vmdl",
        },
        {
            awardPrefix .. "right_arm/burning_stone_giant_right_arm.vmdl",
            awardPrefix .. "right_arm_level_2/burning_stone_giant_right_arm_level_2.vmdl",
            awardPrefix .. "right_arm_level_3/burning_stone_giant_right_arm_level_3.vmdl",
            awardPrefix .. "right_arm_level_4/burning_stone_giant_right_arm_level_4.vmdl",
        }
    }

    local function ReplaceModel(whichModel, withWhat)
        print("replacing", whichModel, "with", withWhat)
        while model ~= nil do
            if model:GetClassname() == "npc_dota_creature" and model:GetModelName() == whichModel then
                model:SetModel(withWhat)
                break
            end

            model = model:NextMovePeer()
        end
    end

    local models = hero:IsAwardEnabled() and awardModels or standardModels

    for _, modelsByLevel in pairs(models) do
        ReplaceModel(modelsByLevel[previous], modelsByLevel[level])
    end
end

SKUtil = {}

function SKUtil.AbilityHit(hero, target)
    local mod = target:FindModifier("modifier_sk_a")

    if mod then
        mod:Destroy()

        target:EmitSound("Arena.SK.HitA2")
        hero:AreaEffect({
            filter = Filters.Area(target:GetPos(), 300),
            damage = 1
        })

        FX("particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_ABSORIGIN, target, {
            release = true
        })
    end
end

ZeusUtil = {}

function ZeusUtil.AbilityHit(hero, ability, victim)
    local mod = victim:FindModifier("modifier_zeus_a")

    if mod then
        victim:AddNewModifier(hero, ability, "modifier_stunned_lua", { duration = 0.85 })
        mod:Destroy()
    end
end