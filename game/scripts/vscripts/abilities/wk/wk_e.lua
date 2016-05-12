wk_e = class({})

LinkLuaModifier("modifier_wk_zombie", "abilities/wk/modifier_wk_zombie", LUA_MODIFIER_MOTION_NONE)

require('abilities/wk/entity_wk_zombie')

function wk_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = (target - hero:GetPos()):Normalized()
    local rotated = Vector(direction.y, -direction.x)

    for i = -3, 3 do
        local position = hero:GetPos() + direction * 256 + rotated * i * 64
        WKZombie(hero.round, hero, position, direction):Activate()

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_zombie_spawn.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
        ParticleManager:SetParticleControl(particle, 0, position)
        ParticleManager:ReleaseParticleIndex(particle)
    end

    local p1 = hero:GetPos() + direction * 256 + rotated * -3 * 64
    local p2 = hero:GetPos() + direction * 256 + rotated * 3 * 64

    hero:AreaEffect({
        filter = Filters.Line(p1, p2, 200),
        onlyHeroes = true,
        hitAllies = true,
        action = function(target)
            if target ~= self.hero then
                target:FindClearSpace(target:GetPos(), true)
            end
        end
    })

    ScreenShake(hero:GetPos(), 5, 150, 0.25, 2000, 0, true)
end

function wk_e:GetPlaybackRateOverride()
    return 2.0
end

function wk_e:GetCastAnimation()
    return ACT_DOTA_TELEPORT
end