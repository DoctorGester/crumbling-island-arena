storm_spirit_a = class({})
LinkLuaModifier("modifier_storm_spirit_a", "abilities/storm_spirit/modifier_storm_spirit_a", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_storm_spirit_a_slow", "abilities/storm_spirit/modifier_storm_spirit_a_slow", LUA_MODIFIER_MOTION_NONE)

function storm_spirit_a:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()
    local charged = hero:FindModifier("modifier_storm_spirit_a")

    if charged then
        charged:Destroy()
    end

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1450,
        radius = 48,
        graphics = "particles/storm_a/storm_a.vpcf",
        distance = 700,
        hitSound = charged and "Arena.Storm.HitA2" or "Arena.Storm.HitA",
        destroyFunction = function(projectile, victim)
            if charged then
                projectile:AreaEffect({
                    filter = Filters.Area(projectile:GetPos(), 350),
                    damage = self:GetDamage() * 2,
                    modifier = { name = "modifier_storm_spirit_a_slow", duration = 1.2, ability = self }
                })

                FX("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_WORLDORIGIN, projectile, {
                    cp0 = projectile:GetPos(),
                    release = true
                })

                ScreenShake(projectile:GetPos(), 5, 150, 0.15, 3000, 0, true)
            else
                victim:Damage(hero, self:GetDamage(), true)
            end
        end
    }):Activate()

    hero:EmitSound("Arena.Storm.CastA")
end

function storm_spirit_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function storm_spirit_a:GetPlaybackRateOverride()
    return 4
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(storm_spirit_a)