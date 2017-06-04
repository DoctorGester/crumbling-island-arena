earth_spirit_w = class({})

require("abilities/earth_spirit/earth_spirit_knockback")

function earth_spirit_w:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()

    Wrappers.DirectionalAbility(self, hero:HasModifier("modifier_earth_spirit_stand") and 1400 or 700)

    local target = self:GetCursorPosition()
    local s = hero.round.spells;

    local function distFrom(o)
        return (o:GetPos() - target):Length2D()
    end

    local min = math.huge
    local isHero = false
    local closest = nil

    local treeFilter = Filters.WrapFilter(function(e) return not instanceof(e, Obstacle) end )

    for _, ent in pairs(s:FilterEntities(Filters.Area(target, 220) + treeFilter, s:GetValidTargets())) do
        local distance = distFrom(ent)
        local isEntHero = instanceof(ent, Hero) ~= nil

        if distance < min and (not isHero or isEntHero) and ent ~= hero then
            min = distance
            isHero = isEntHero
            closest = ent
        end
    end

    if closest then
        local target = closest
        local direction = (hero:GetPos() - target:GetPos()) * Vector(1, 0, 0)
        local force = direction:Length2D() / 10
        local decrease = direction:Length2D() / 160
        EarthSpiritKnockback(self, target, hero, direction, force or 20, {
            loopingSound = "Arena.Earth.CastW.Loop",
            decrease = decrease
        })
    end

    hero:EmitSound("Arena.Earth.CastW.Voice")
    hero:AddNewModifier(hero, hero:FindAbility("earth_spirit_w_sub"), "modifier_earth_spirit_w_recast", { duration = 2.5 })

    FX("particles/earth_spirit_w/earth_spirit_w_area.vpcf", PATTACH_WORLDORIGIN, GameRules:GetGameModeEntity(),
        {
            cp0 = target,
            cp1 = Vector(220, 0, 0),
            release = true
        }
    )
end

function earth_spirit_w:GetCastPoint()
    return 0.15
end

function earth_spirit_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(earth_spirit_w)