sniper_q = class({})

function sniper_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    local projectileData = {}
    projectileData.owner = hero
    projectileData.from = hero:GetPos()
    projectileData.to = target
    projectileData.velocity = 1200
    projectileData.graphics = "particles/cm/cm_q.vpcf"
    projectileData.distance = 1500
    projectileData.empowered = false
    projectileData.radius = 64

    Spells:CreateProjectile(projectileData)
    hero:EmitSound("Arena.CM.CastQ")
end

function sniper_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end