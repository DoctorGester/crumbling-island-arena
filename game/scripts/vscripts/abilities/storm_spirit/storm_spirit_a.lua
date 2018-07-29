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

    local ignorePrimary = function(projectile)
        return function(victim) 
            return not projectile.hitGroup[victim]
        end
    end

    local data = {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1450,
        radius = 48,
        graphics = "particles/storm_a/storm_a.vpcf",
        distance = 700,
        hitSound = charged and "Arena.Storm.HitA2" or "Arena.Storm.HitA",
        isPhysical = true
    }

    if charged then
        data.damagesTrees = true

        data.hitFunction = function(projectile, victim)
            projectile.hitSomething = true
            projectile.hitGroup[victim] = true
            victim:Damage(projectile, self:GetDamage() * 2, true)
            victim:AddNewModifier(projectile:GetTrueHero(), self, "modifier_storm_spirit_a_slow", { duration = 1.2 })
            projectile:Destroy() 
        end

        data.destroyFunction = function(projectile)
            if not projectile.hitSomething then
                return
            end

            projectile:AreaEffect({
                ability = self,
                filter = Filters.Area(projectile:GetPos(), 350) + ignorePrimary(projectile),
                damage = self:GetDamage(),
                modifier = { name = "modifier_storm_spirit_a_slow", duration = 1.2, ability = self },
                isPhysical = true
            })

            FX("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_WORLDORIGIN, projectile, {
                cp0 = projectile:GetPos(),
                release = true
            })

            ScreenShake(projectile:GetPos(), 5, 150, 0.15, 3000, 0, true)
        end
    else
        data.damage = self:GetDamage()
    end

    DistanceCappedProjectile(hero.round, data):Activate()

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