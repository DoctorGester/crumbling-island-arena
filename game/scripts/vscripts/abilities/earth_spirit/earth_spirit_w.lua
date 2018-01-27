earth_spirit_w = class({})

require("abilities/earth_spirit/earth_spirit_knockback")

LinkLuaModifier("modifier_earth_spirit_w_slow", "abilities/earth_spirit/modifier_earth_spirit_w_slow", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_w:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()

    Wrappers.DirectionalAbility(self, hero:HasModifier("modifier_earth_spirit_stand") and 1400 or 700)

    local target = self:GetCursorPosition()

    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(target, 220),
        action = function(victim)
            if instanceof(victim, Hero) then
                victim:AddNewModifier(hero, self, "modifier_earth_spirit_a", { duration = 1.5 })
                victim:AddNewModifier(hero, self, "modifier_earth_spirit_w_slow", { duration = 1.5 })
            end

            if instanceof(victim, EarthSpiritRemnant) then
                local direction = (hero:GetPos() - victim:GetPos()) * Vector(1, 1, 0)
                local force = direction:Length2D() / 10
                local decrease = math.max(3, direction:Length2D() / 160)
                EarthSpiritKnockback(self, victim, hero, direction, force or 20, {
                    loopingSound = "Arena.Earth.CastW.Loop",
                    decrease = decrease
                })
            end
        end
    })

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