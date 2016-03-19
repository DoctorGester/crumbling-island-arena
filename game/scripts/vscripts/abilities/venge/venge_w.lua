venge_w = class({})

LinkLuaModifier("modifier_venge_w", "abilities/venge/modifier_venge_w", LUA_MODIFIER_MOTION_NONE)

function venge_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    Projectile(hero.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 2000,
        graphics = "particles/venge_w/venge_w.vpcf",
        distance = 1400,
        hitModifier = { name = "modifier_venge_w", duration = 3.0, ability = self },
        continueOnHit = true
    }):Activate()

    hero.round.spells:AddDynamicEntity(projectile)
    hero:EmitSound("Arena.Venge.CastW")
end
