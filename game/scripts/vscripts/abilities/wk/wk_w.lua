wk_w = class({})

LinkLuaModifier("modifier_wk_w", "abilities/wk/modifier_wk_w", LUA_MODIFIER_MOTION_NONE)

require('abilities/wk/entity_wk_archer')

function wk_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local startPos = hero:GetPos()
    local direction = (target - startPos):Normalized()
    local position = startPos + direction * 2000
    local rotated = Vector(direction.y, -direction.x)

    for i = -1, 1 do
        local angle = math.pi / 1.5 * i
        local position = hero:GetPos() - direction * 256 + rotated * i * 164
        local resultTarget = target + Vector(math.cos(angle) * 220, math.sin(angle) * 220, 0)
        CreateAOEMarker(hero, resultTarget, 200, 1.7, Vector(32, 215, 131))
        WKArcher(hero.round, hero, self, position, resultTarget, 1 + 0.05 * i):Activate()
    end

    ScreenShake(hero:GetPos(), 5, 150, 0.25, 2000, 0, true)
    hero:EmitSound("Arena.WK.CastW")
end

function wk_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(wk_w)