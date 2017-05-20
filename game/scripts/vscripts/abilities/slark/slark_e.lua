slark_e = class({})

LinkLuaModifier("modifier_slark_e", "abilities/slark/modifier_slark_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slark_e_leash", "abilities/slark/modifier_slark_e_leash", LUA_MODIFIER_MOTION_NONE)

function slark_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_start.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
    ParticleManager:ReleaseParticleIndex(index)

    hero:GetUnit():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

    local dash = Dash(hero, hero:GetPos() + hero:GetFacing() * 600, 1000, {
        heightFunction = DashParabola(150),
        modifier = { name = "modifier_slark_e", ability = self },
        gesture = ACT_DOTA_SLARK_POUNCE,
        gestureRate = 0.9,
        forceFacing = true
    })

    hero:EmitSound("Arena.Slark.CastE")

    dash.hitParams = {
        ability = self,
        onlyHeroes = true,
        dontBlockAction = true,
        modifier = { name = "modifier_slark_e_leash", ability = self, duration = 2.5 },
        action = function(target)
            hero:EmitSound("Arena.Slark.HitE.Voice")
            target:EmitSound("Arena.Slark.LoopE")
        end,
        notBlockedAction = function(target, wasBlocked)
            ScreenShake(target:GetPos(), 5, 150, 0.45, 3000, 0, true)

            hero:EmitSound("Arena.Slark.HitE")
            dash:Interrupt()
        end
    }
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(slark_e)