sven_e = class({})
LinkLuaModifier("modifier_sven_e", "abilities/sven/modifier_sven_e", LUA_MODIFIER_MOTION_NONE)

function sven_e:GetChannelTime()
    local enraged = self:GetCaster():HasModifier("modifier_sven_r") -- Can't use IsEnraged on the client

    if enraged then
        return nil
    end

    return 0.4
end

function sven_e:GetBehavior()
    local default = bit.bor(DOTA_ABILITY_BEHAVIOR_POINT, DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES)

    if self:GetCaster():HasModifier("modifier_sven_r") then
        return bit.bor(default, DOTA_ABILITY_BEHAVIOR_IMMEDIATE)
    end

    return default
end

function sven_e:OnSpellStart()
    self:GetCaster().hero:EmitSound("Arena.Sven.CastE")

    if self:GetCaster():HasModifier("modifier_sven_r") then
        self:Cast(self.BaseClass.GetCursorPosition(self))
    end
end

function sven_e:GetChannelAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_3
end

function sven_e:OnChannelFinish(interrupted)
    if interrupted then return end

    self:Cast(self:GetCursorPosition())
end

function sven_e:Cast(target)
    local hero = self:GetCaster():GetParentEntity()
    local direction = target - hero:GetPos()
    local from = hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    if direction:Length2D() > 800 then
        target = hero:GetPos() + direction:Normalized() * 800
    end

    direction = direction:Normalized()

    local effect = ImmediateEffectPoint("particles/econ/items/sven/sven_warcry_ti5/sven_spell_warcry_ti_5.vpcf", PATTACH_ABSORIGIN, hero, hero:GetPos())
    ParticleManager:SetParticleControl(effect, 2, hero:GetPos())

    hero:GetUnit():Interrupt()

    local function knockDirection(victim)
        local pos = hero:GetPos()
        local tp = victim:GetPos()
        local between = ClosestPointToSegment(from, pos, tp)
        return (tp - between):Normalized()
    end

    TimedEntity(0.05, function()
        SvenDash(hero, target, 1200, {
            modifier = { name = "modifier_sven_e", ability = self },
            forceFacing = true,
            gesture = ACT_DOTA_RUN,
            gestureRate = 1.8,
            hitParams = {
                ability = self,
                sound = "Arena.Sven.HitE",
                damage = self:GetDamage(),
                action = function(victim)
                    local pos = hero:GetPos()
                    local tp = victim:GetPos()
                    local between = ClosestPointToSegment(from, pos, tp)

                    local effect = ImmediateEffectPoint("particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_dust_gravelmaw.vpcf", PATTACH_ABSORIGIN, hero, tp)
                    ParticleManager:SetParticleControl(effect, 1, between + knockDirection(victim) * 300)
                end,
                knockback = {
                    force = function(victim)
                        return 10 + 60 * direction:Dot(knockDirection(victim))
                    end,
                    direction = knockDirection,
                    decrease = 4
                }
            }
        })
    end):Activate()
end

if IsServer() then
    Wrappers.GuidedAbility(sven_e, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(sven_e)

SvenDash = SvenDash or class({}, nil, Dash)
SvenDash.DUST_EFFECT = "particles/econ/items/rubick/rubick_force_gold_ambient/rubick_telekinesis_force_dust_gold.vpcf"

function SvenDash:constructor(...)
    getbase(SvenDash).constructor(self, ...)

    self.tick = 0
end

function SvenDash:Update()
    local position = getbase(SvenDash).Update(self)

    self.tick = self.tick + 1

    if self.tick % 2 == 0 then
        ImmediateEffectPoint(SvenDash.DUST_EFFECT, PATTACH_ABSORIGIN, self.hero, position)
    end

    if self.tick % 5 == 0 then
        self.hero:EmitSound("Arena.Sven.StepE")
        ScreenShake(position, 3, 60, 0.15, 2000, 0, true)
    end
end

function SvenDash:PositionFunction(current)
    local center = self.to + (self.from - self.to) / 2
    local diff = self.to - current
    local rel = math.min((self.to - center):Length2D() / (current - center):Length2D(), 1.5)
    self.velocity = (rel * 600 + 100) / 30
    return current + (diff:Normalized() * self.velocity)
end
