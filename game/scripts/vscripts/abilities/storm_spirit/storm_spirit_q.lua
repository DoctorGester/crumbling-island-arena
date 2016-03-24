storm_spirit_q = class({})
LinkLuaModifier("modifier_storm_spirit_remnant", "abilities/storm_spirit/modifier_storm_spirit_remnant", LUA_MODIFIER_MOTION_NONE)

require("abilities/storm_spirit/entity_storm_q")

function storm_spirit_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    else
        direction = direction:Normalized()
    end

    PointTargetProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 800,
        graphics = "particles/storm_q/storm_q2.vpcf",
        continueOnHit = true,
        targetReachedFunction =
            function(self)
                hero:AddRemnant(EntityStormQ(self.round, hero, self:GetPos(), direction):Activate())
            end
    }):Activate()

    hero:EmitSound("Arena.Storm.CastQ")
end

function storm_spirit_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end