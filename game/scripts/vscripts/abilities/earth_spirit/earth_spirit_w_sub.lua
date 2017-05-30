earth_spirit_w_sub = class({})

require("abilities/earth_spirit/earth_spirit_knockback")

LinkLuaModifier("modifier_earth_spirit_w_recast", "abilities/earth_spirit/modifier_earth_spirit_w_recast", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_w_sub:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()

    Wrappers.DirectionalAbility(self)

    local cursor = self:GetCursorPosition()

    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(hero:GetPos(), 300),
        hitAllies = true,
        sound = "Arena.Earth.HitW.Sub",
        action = function(target)
            local direction = cursor - hero:GetPos()

            EarthSpiritKnockback(self, target, hero, direction, 70, {
                decrease = 5
            })
        end
    })

    hero:RemoveModifier("modifier_earth_spirit_w_recast")

    FX("particles/earth_spirit_w/earth_spirit_w_area.vpcf", PATTACH_ABSORIGIN, hero,
        {
            cp1 = Vector(300, 0, 0),
            release = true
        }
    )
end

function earth_spirit_w_sub:GetCastPoint()
    return 0.1
end

function earth_spirit_w_sub:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_5
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(earth_spirit_w_sub)