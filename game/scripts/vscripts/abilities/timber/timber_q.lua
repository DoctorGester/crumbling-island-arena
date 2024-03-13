timber_q = class({})
local chakram = nil

LinkLuaModifier("modifier_timber_q_recast", "abilities/timber/modifier_timber_q_recast", LUA_MODIFIER_MOTION_NONE)

require("abilities/timber/projectile_timber_q")

function timber_q:OnSpellStart()
	Wrappers.DirectionalAbility(self, 1300)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.Timber.CastQ")
    chakram = ProjectileTimberQ(hero.round, hero, target, self:GetDamage(), self):Activate()

    hero:SwapAbilities("timber_q", "timber_q_sub")
    hero:FindAbility("timber_q_sub"):StartCooldown(0.5)
    Timers:CreateTimer(0.5, function()
        hero:AddNewModifier(hero, self, "modifier_timber_q_recast", { duration = 3.0 })
        Timers:RemoveTimer()
    end
    )
end

function timber_q:GetChakram()
	return chakram
end

function timber_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function timber_q:GetPlaybackRateOverride()
    return 1.33
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(timber_q)