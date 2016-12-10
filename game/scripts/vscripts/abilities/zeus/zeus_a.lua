zeus_a = class({})
LinkLuaModifier("modifier_zeus_a", "abilities/zeus/modifier_zeus_a", LUA_MODIFIER_MOTION_NONE)

function zeus_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local dir = self:GetDirection()
    local walls = {}

    while true do
        local wall = hero.round.spells:FilterEntities(function(t)
            return instanceof(t, EntityZeusW) and t:IntersectsWith(hero:GetPos(), target) and not walls[t]
        end)[1]

        if not wall then
            break
        end

        walls[wall] = true

        target = target + dir * 600
    end

    hero:AreaEffect({
        filter = Filters.Line(hero:GetPos(), target, 32),
        damage = self:GetDamage(),
        sound = "Arena.Zeus.HitE",
        modifier = { name = "modifier_zeus_a", duration = 2.5, ability = self },
        isPhysical = true
    })

    FX("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_CUSTOMORIGIN, hero, {
        cp0 = hero:GetPos() + Vector(0, 0, 96) + Vector(dir.y, -dir.x) * 48 + dir * 16,
        cp1 = target + Vector(0, 0, 96),
        release = true
    })

    hero:EmitSound("Arena.Zeus.CastA")
end

function zeus_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function zeus_a:GetPlaybackRateOverride()
    return 3.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(zeus_a)