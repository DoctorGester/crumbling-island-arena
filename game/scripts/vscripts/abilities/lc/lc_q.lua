lc_q = class({})

LinkLuaModifier("modifier_lc_q", "abilities/lc/modifier_lc_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lc_q_animation", "abilities/lc/modifier_lc_q_animation", LUA_MODIFIER_MOTION_NONE)

function lc_q:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local dir = self:GetDirection()

    hero:EmitSound("Arena.LC.CastQ")

    FunctionDash(hero, hero:GetPos() + dir * 300, 0.3, {
        forceFacing = true,
        heightFunction = DashParabola(50),
        arrivalFunction = function(dash)
            local target = hero:GetPos() + dir * 200

            FX("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, hero, {
                cp0 = target,
                cp1 = Vector(600, 1, 1),
                cp2 = target,
                cp3 = target,
                release = true
            })

            hero:AreaEffect({
                ability = self,
                filter = Filters.Area(target, 200),
                damage = self:GetDamage(),
                modifier = { name = "modifier_lc_q", duration = 1.5, ability = self },
            })

            hero:EmitSound("Arena.LC.HitQ")

            ScreenShake(target, 45 * 40, 45 * 40, 0.15, 1800, 0, true)
            Spells:GroundDamage(target, 200, hero)
        end,
        modifier = { name = "modifier_lc_q_animation", ability = self },
    })

    AddAnimationTranslate(hero:GetUnit(), "duel_kill", 0.1)
    hero:Animate(ACT_DOTA_ATTACK, 1.5)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(lc_q)