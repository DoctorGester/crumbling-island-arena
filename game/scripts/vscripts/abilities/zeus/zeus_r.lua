zeus_r = class({})
LinkLuaModifier("modifier_zeus_r", "abilities/zeus/modifier_zeus_r", LUA_MODIFIER_MOTION_NONE)

function zeus_r:GetChannelTime()
    return 2.0
end

function zeus_r:OnAbilityPhaseStart()
    self.timePassed = 0
    self.hidden = false
    self.target = nil
    self.vo = false

    FX("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster(), {
        cp1 = self:GetCaster():GetAbsOrigin(),
        cp2 = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 2000),
        release = true
    })

    return true
end

function zeus_r:OnChannelThink(interval)
    local hero = self:GetCaster():GetParentEntity()
    local actualTarget = self:GetCursorPosition()
    local target = self.target or actualTarget

    local speed = 8

    if (target - actualTarget):Length2D() <= speed then
        target = actualTarget
    else
        target = target + (actualTarget - target):Normalized() * speed
    end

    self.target = target

    if not self.marker then
        self.marker = FX("particles/zeus_r/zeus_r_marker.vpcf", PATTACH_CUSTOMORIGIN, hero, {
            cp1 = Vector(300, 0, 0)
        })

        hero:EmitSound("Arena.Zeus.CastR")
    end

    if self.marker then
        ParticleManager:SetParticleControl(self.marker, 0, self.target)
    end

    self.timePassed = self.timePassed + interval

    if self.timePassed > 0.1 and not self.vo then
        self.vo = true
        hero:EmitSound("Arena.Zeus.CastR.Voice", self.target)
    end

    if self.timePassed >= 0.2 and not self.hidden then
        hero:SetHidden(true)
        hero:AddNewModifier(hero, self, "modifier_zeus_r", { duration = 2.3 })

        FX("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, hero, {
            cp0 = hero:GetPos() + Vector(0, 0, 2000),
            cp1 = hero:GetPos(),
            release = true
        })

        self.hidden = true
    end
end

function zeus_r:OnChannelFinish(interrupted)
    local hero = self:GetCaster():GetParentEntity()
    local target = self.target

    hero:SetHidden(false)
    hero:FindClearSpace(target, true)
    hero:EmitSound("Arena.Zeus.HitR")

    if self.marker then
        ParticleManager:DestroyParticle(self.marker, false)
        ParticleManager:ReleaseParticleIndex(self.marker)
    end

    self.marker = nil

    FX("particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf", PATTACH_CUSTOMORIGIN, hero, {
        cp0 = hero:GetPos() + Vector(0, 0, 2000),
        cp1 = hero:GetPos(),
        release = true
    })

    FX("particles/zeus_r/zeus_r.vpcf", PATTACH_CUSTOMORIGIN, hero, {
        cp0 = hero:GetPos(),
        cp1 = Vector(300, 0, 0),
        release = true
    })

    ScreenShake(hero:GetPos(), 5, 150, 0.35, 4000, 0, true)

    hero:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT_END, 1.5)

    hero:AreaEffect({
        filter = Filters.Area(target, 300),
        damage = self:GetDamage(),
        sound = "Arena.Zeus.HitE",
        modifier = { name = "modifier_zeus_a", duration = 1.6, ability = self }
    })
end

function zeus_r:GetPlaybackRateOverride()
    return 1.5
end

function zeus_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

if IsServer() then
    Wrappers.GuidedAbility(zeus_r, true)
end