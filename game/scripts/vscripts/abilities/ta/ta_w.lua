ta_w = class({})
LinkLuaModifier("modifier_ta_w", "abilities/ta/modifier_ta_w", LUA_MODIFIER_MOTION_NONE)

function ta_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()

    local target = self:GetCursorPosition()
    local castDirection = (target - hero:GetPos()):Normalized()

    if castDirection:Length2D() == 0 then
        castDirection = hero:GetFacing()
    end

    local effect = ImmediateEffect("particles/ta_w/ta_w.vpcf", PATTACH_CUSTOMORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos() + Vector(0, 0, 32))
    ParticleManager:SetParticleControl(effect, 1, pos + castDirection * 500 + Vector(0, 0, 32))

    hero:MultipleHeroesModifier(self, "modifier_ta_w", { duration = 1.5 },
        function (source, heroTarget)
            local targetDirection = heroTarget:GetPos() - pos
            local distance = targetDirection:Length2D()
            local angle = math.acos(castDirection:Dot(targetDirection:Normalized()))

            return source ~= heroTarget and distance <= 500 and angle <= math.pi / 4
        end
    )

    hero:EmitSound("Arena.TA.CastW")
end

function ta_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end