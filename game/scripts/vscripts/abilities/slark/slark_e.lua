slark_e = class({})

LinkLuaModifier("modifier_slark_e", "abilities/slark/modifier_slark_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slark_e_leash", "abilities/slark/modifier_slark_e_leash", LUA_MODIFIER_MOTION_NONE)

function slark_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_start.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
    ParticleManager:ReleaseParticleIndex(index)

    hero:GetUnit():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

    local dash = Dash(hero, hero:GetPos() + hero:GetFacing() * 600, 1000, {
        heightFunction = DashParabola(150),
        modifier = { name = "modifier_slark_e", ability = self },
    })

    hero:EmitSound("Arena.Slark.CastE")

    dash.hitParams = {
        modifier = { name = "modifier_slark_e_leash", ability = self, duration = 3.5 },
        action = function(target)
            ScreenShake(target:GetPos(), 5, 150, 0.45, 3000, 0, true)

            hero:EmitSound("Arena.Slark.HitE")
            hero:EmitSound("Arena.Slark.HitE.Voice")
            target:EmitSound("Arena.Slark.LoopE")

            dash:Interrupt()
        end
    }
end