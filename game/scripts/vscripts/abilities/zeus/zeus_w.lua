zeus_w = class({})
LinkLuaModifier("modifier_zeus_w", "abilities/zeus/modifier_zeus_w", LUA_MODIFIER_MOTION_NONE)

function zeus_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local casterPos = hero:GetPos()
    local target = self:GetCursorPosition()
    local direction = (target - casterPos):Normalized()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    casterPos.z = 0
    direction.z = 0

    local wallCenter = casterPos + direction * 300
    local offset = Vector(-direction.y, direction.x, 0)
    local wallStart = wallCenter + offset * 250
    local wallEnd = wallCenter - offset * 250

    hero:SetWall(wallStart, wallEnd)

    wallStart.z =  GetGroundHeight(wallStart, nil) + 32
    wallEnd.z = GetGroundHeight(wallEnd, nil) + 32

    local particle = ParticleManager:CreateParticle("particles/zeus_w2/zeus_w2.vpcf", PATTACH_CUSTOMORIGIN, hero.unit)
    ParticleManager:SetParticleControl(particle, 0, wallStart)
    ParticleManager:SetParticleControl(particle, 1, wallEnd)

    local timePassed = 0

    Timers:CreateTimer(0.1,
        function()
            if hero:Alive() then
                if SegmentCircleIntersection(wallStart, wallEnd, hero:GetPos(), hero:GetRad()) then
                    hero:AddNewModifier(hero, self, "modifier_zeus_w", { duration = 1.5 })
                end
            end

            timePassed = timePassed + 0.1

            if timePassed >= 3.5 then
                hero:RemoveWall()
                ParticleManager:DestroyParticle(particle, false)
                ParticleManager:ReleaseParticleIndex(particle)
                --hero:StopSound("Ability.static.loop")
                hero:EmitSound("Arena.Zeus.EndW")

                return
            end

            return 0.1
        end
    )

    hero:EmitSound("Arena.Zeus.CastW")
    --hero:EmitSound("Ability.static.loop")

    --"particles/units/heroes/hero_leshrac/leshrac_lightning_slow.vpcf"
end

function zeus_w:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end