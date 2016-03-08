venge_q = class({})

function venge_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    local projectileData = {}
    projectileData.owner = hero
    projectileData.from = hero:GetPos() + Vector(0, 0, 128)
    projectileData.to = target + Vector(0, 0, 128)
    projectileData.velocity = 1250
    projectileData.graphics = "particles/venge_q/venge_q.vpcf"
    projectileData.distance = 950
    projectileData.radius = 64
    projectileData.heroBehaviour =
        function(self, target)
            Spells:ProjectileDamage(self, target)
            target:EmitSound("Arena.CM.HitQ")
            target:AddNewModifier(hero, ability, "modifier_stunned", { duration = 1.0 })
            return true
        end

    Spells:CreateProjectile(projectileData)
    hero:EmitSound("Arena.CM.CastQ")
end