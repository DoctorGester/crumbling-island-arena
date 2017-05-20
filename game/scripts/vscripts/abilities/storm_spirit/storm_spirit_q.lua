storm_spirit_q = class({})
LinkLuaModifier("modifier_storm_spirit_remnant", "abilities/storm_spirit/modifier_storm_spirit_remnant", LUA_MODIFIER_MOTION_NONE)

require("abilities/storm_spirit/entity_storm_q")

function storm_spirit_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1100)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()

    hero:AddNewModifier(hero, hero:FindAbility("storm_spirit_a"), "modifier_storm_spirit_a", { duration = 5 })

    PointTargetProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 800,
        graphics = "particles/storm_q/storm_q2.vpcf",
        damage = self:GetDamage(),
        continueOnHit = true,
        considersGround = true,
        targetReachedFunction =
            function(proj)
                hero:AddRemnant(EntityStormQ(proj.round, hero, proj:GetPos(), direction, self):Activate())
            end
    }):Activate()

    hero:EmitSound("Arena.Storm.CastQ")
end

function storm_spirit_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function storm_spirit_q:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(storm_spirit_q)