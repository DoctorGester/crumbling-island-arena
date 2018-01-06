nevermore_q = class({})

LinkLuaModifier("modifier_nevermore_q", "abilities/nevermore/modifier_nevermore_q", LUA_MODIFIER_MOTION_NONE)

function nevermore_q:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.Nevermore.CastQ.Voice")
    return true
end

function nevermore_q:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()
    local recastModifier = hero:FindModifier("modifier_nevermore_q")
    local isAllowedToBeRecast = true
    local stacks = 0

    if recastModifier then
        stacks = recastModifier:GetStackCount()

        if recastModifier:GetStackCount() == 2 then
            recastModifier:Destroy()
            isAllowedToBeRecast = false
        else
            recastModifier:IncrementStackCount()
            recastModifier:SetDuration(3.0, true)
        end
    else
        hero:AddNewModifier(hero, self, "modifier_nevermore_q", { duration = 3.0 }):SetStackCount(1)
    end

    if isAllowedToBeRecast then
        self:EndCooldown()
    end

    local target = hero:GetPos() + (hero:GetFacing() * Vector(1, 1, 0)):Normalized() * (200 + 250 * stacks)

    local effect = hero:GetMappedParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf")
    FX(effect, PATTACH_WORLDORIGIN, GameRules:GetGameModeEntity(), {
        cp0 = target,
        release = true
    })

    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(target, 250),
        filterProjectiles = true,
        damage = self:GetDamage()
    })

    ScreenShake(target, 5, 150, 0.15, 3000, 0, true)

    hero:EmitSound("Arena.Nevermore.CastQ")
end

function nevermore_q:GetCastAnimation()
    local stackCount = self:GetCaster():GetModifierStackCount("modifier_nevermore_q", self:GetCaster())

    return ({
        ACT_DOTA_RAZE_1,
        ACT_DOTA_RAZE_2,
        ACT_DOTA_RAZE_3
    })[stackCount + 1]
end

function nevermore_q:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(nevermore_q)