ursa_r = class({})

LinkLuaModifier("modifier_ursa_r", "abilities/ursa/modifier_ursa_r", LUA_MODIFIER_MOTION_NONE)

function ursa_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:GetUnit():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
    hero:AddNewModifier(hero, self, "modifier_ursa_r", { duration = 4.5 })
    hero:EmitSound("Arena.Ursa.CastR")
end
