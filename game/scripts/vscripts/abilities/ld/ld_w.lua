ld_w = class({})

LinkLuaModifier("modifier_ld_root", "abilities/ld/modifier_ld_root", LUA_MODIFIER_MOTION_NONE)

function ld_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1100, 1100)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local start = hero:GetPos()
    local direction = self:GetDirection()
    local offset = Vector(direction.y, -direction.x, 0) * 128
    local color = Vector(0, 120, 0)

    CreateLineMarker(hero, start + offset, target + offset, 0.8, color)
    CreateLineMarker(hero, start - offset, target - offset, 0.8, color)

    Timers:CreateTimer(0.8, function()
        hero:EmitSound("Arena.LD.HitW")

        hero:AreaEffect({
            filter = Filters.Line(start, target, 128),
            sound = "Arena.TA.HitQ",
            modifier = { name = "modifier_ld_root", duration = 1.5, ability = self }
        })

        local effect = ParticleManager:CreateParticle("particles/ld_w/ld_w.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
        ParticleManager:SetParticleControl(effect, 0, start)
        ParticleManager:SetParticleControl(effect, 1, target)
        ParticleManager:ReleaseParticleIndex(effect)
    end)

    hero:EmitSound("Arena.LD.CastW")
end

function ld_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end