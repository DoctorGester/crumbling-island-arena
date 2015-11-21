sk_r = class({})

function sk_r:GetChannelTime()
    return 2.8
end

function sk_r:GetPlaybackRateOverride()
    return 0.7
end

function sk_r:Pulse()
    local hero = self:GetCaster().hero
    local index = ImmediateEffect("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    Spells:AreaDamage(hero, hero:GetPos(), 500)
    GridNav:DestroyTreesAroundPoint(hero:GetPos(), 500, true)
    hero:EmitSound("Arena.SK.TickR")

    ParticleManager:SetParticleControl(index, 1, Vector(500, 500, 500))
end

function sk_r:OnChannelThink(interval)
    if IsServer() then
        self.timePassed = self.timePassed or 0
        self.firstPulsePerformed = self.firstPulsePerformed or false

        if self.timePassed == 0 then
            self:GetCaster().hero:EmitSound("Arena.SK.CastR")
        end

        self.timePassed = self.timePassed + interval

        if not self.firstPulsePerformed and self.timePassed >= self:GetChannelTime() / 2 - 0.25 then
            self.firstPulsePerformed = true
            self:Pulse()
        end

        self.secondPulsePerformed = self.secondPulsePerformed or false
        if not self.secondPulsePerformed and self.timePassed >= self:GetChannelTime() - 0.25 then
            self.secondPulsePerformed = true
            self:Pulse()
        end
    end
end

function sk_r:OnChannelFinish(interrupted)
    self.firstPulsePerformed = false
    self.secondPulsePerformed = false
    self.timePassed = 0
end

function sk_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end