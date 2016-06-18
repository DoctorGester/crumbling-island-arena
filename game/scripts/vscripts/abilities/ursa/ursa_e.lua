ursa_e = class({})

LinkLuaModifier("modifier_ursa_e", "abilities/ursa/modifier_ursa_e", LUA_MODIFIER_MOTION_NONE)

function ursa_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:GetUnit():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
    hero:AddNewModifier(hero, self, "modifier_ursa_e", { duration = 2.5 })
    hero:EmitSound("Arena.Ursa.CastE")
    hero:FindAbility("ursa_q"):EndCooldown()
end
