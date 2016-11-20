cm_q = class({})

LinkLuaModifier("modifier_cm_frozen", "abilities/cm/modifier_cm_frozen", LUA_MODIFIER_MOTION_NONE)

function cm_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1500)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1200,
        graphics = "particles/cm/cm_q.vpcf",
        distance = 1500,
        hitSound = "Arena.CM.HitQ",
        hitFunction = function(_, target)
            CMUtil.AbilityHit(hero)

            if CMUtil.IsFrozen(target) then
                target:Damage(hero, self:GetDamage())
            else
                CMUtil.Freeze(hero, target, self)
            end
        end
    }):Activate()

    hero:EmitSound("Arena.CM.CastQ")
end

function cm_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end