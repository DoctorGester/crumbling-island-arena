qop_a = class({})

function qop_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 96),
        to = target + Vector(0, 0, 96),
        speed = 1450,
        radius = 48,
        graphics = "particles/qop_a/qop_a.vpcf",
        distance = 1000,
        hitSound = "Arena.QOP.HitA",
        hitFunction = function(projectile, victim)
            local damage = self:GetDamage()
            if instanceof(victim, UnitEntity) then
                if victim:GetUnit():GetIdealSpeed() < victim:GetUnit():GetBaseMoveSpeed() then
                    damage = damage * 2
                end
            end

            victim:Damage(projectile, damage, true)
        end
    }):Activate()

    hero:EmitSound("Arena.QOP.CastQ")
end

function qop_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function qop_a:GetPlaybackRateOverride()
    return 3.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(qop_a)