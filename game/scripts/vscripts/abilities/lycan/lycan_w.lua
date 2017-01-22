lycan_w = class({})

LinkLuaModifier("modifier_lycan_w", "abilities/lycan/modifier_lycan_w", LUA_MODIFIER_MOTION_NONE)

function lycan_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local particle = FX("particles/lycan_w/lycan_w_ring.vpcf", PATTACH_WORLDORIGIN, GameRules:GetGameModeEntity(), {
        cp0 = target,
        cp1 = Vector(500, 500, 500)
    })

    hero:EmitSound("Arena.Lycan.CastW", target)

    local modifier = nil

    if LycanUtil.IsTransformed(hero) then
        modifier = { name = "modifier_lycan_w", duration = 2.5, ability = self }
    end

    TimedEntity(2.0, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)

        hero:EmitSound("Arena.Lycan.EndW", target)

        if LycanUtil.IsTransformed(hero) then
            modifier = { name = "modifier_lycan_w", duration = 2.5, ability = self }
        end

        hero:AreaEffect({
            ability = self,
            filter = Filters.Area(target, 500),
            damage = self:GetDamage(),
            modifier = modifier,
            action = function(target)
                LycanUtil.MakeBleed(hero, target)
            end
        })
    end):Activate()
end

function lycan_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end