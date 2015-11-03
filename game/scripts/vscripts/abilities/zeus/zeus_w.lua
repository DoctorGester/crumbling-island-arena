zeus_w = class({})

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

    Timers:CreateTimer(6,
        function()
            hero:RemoveWall()
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
            --hero:StopSound("Ability.static.loop")
            hero:EmitSound("Ability.static.end")
        end
    )

    hero:EmitSound("Ability.static.start")
    --hero:EmitSound("Ability.static.loop")

    --"particles/units/heroes/hero_leshrac/leshrac_lightning_slow.vpcf"
end

function zeus_w:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end