ursa_w = class({})

LinkLuaModifier("modifier_ursa_w", "abilities/ursa/modifier_ursa_w", LUA_MODIFIER_MOTION_NONE)

function ursa_w:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:Animate(ACT_DOTA_OVERRIDE_ABILITY_3)
    hero:AddNewModifier(hero, self, "modifier_ursa_w", { duration = 2.0 })
    hero:EmitSound("Arena.Ursa.CastW")
    hero:FindAbility("ursa_a"):EndCooldown()
end
