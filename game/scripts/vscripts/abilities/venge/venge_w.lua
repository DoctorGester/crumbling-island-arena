venge_w = class({})

LinkLuaModifier("modifier_venge_w", "abilities/venge/modifier_venge_w", LUA_MODIFIER_MOTION_NONE)

function venge_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 2000,
        graphics = "particles/venge_w/venge_w.vpcf",
        distance = 1400,
        hitModifier = { name = "modifier_venge_w", duration = 3.0, ability = self },
        continueOnHit = true,
        damage = self:GetDamage()
    }):Activate()

    hero:EmitSound("Arena.Venge.CastW")
    hero:EmitSound("Arena.Venge.CastW.Voice")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(venge_w)