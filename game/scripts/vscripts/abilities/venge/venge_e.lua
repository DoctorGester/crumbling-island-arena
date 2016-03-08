venge_e = class({})

function venge_e:OnSpellStart()
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
    projectileData.velocity = 1300
    projectileData.graphics = "particles/venge_e/venge_e.vpcf"
    projectileData.distance = 950
    projectileData.radius = 64
    projectileData.heroBehaviour =
        function(self, target)
            local pos = hero:GetPos()

            local effect = ImmediateEffect("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, hero)
            ParticleManager:SetParticleControl(effect, 0, hero:GetPos())
            ParticleManager:SetParticleControl(effect, 1, target:GetPos())

            effect = ImmediateEffect("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, hero)
            ParticleManager:SetParticleControl(effect, 1, hero:GetPos())
            ParticleManager:SetParticleControl(effect, 0, target:GetPos())

            hero:SetPos(target:GetPos())
            target:SetPos(pos)
            target:EmitSound("Arena.CM.HitQ")

            return true
        end

    Spells:CreateProjectile(projectileData)
    hero:EmitSound("Arena.CM.CastQ")
end

function venge_e:GetCastAnimation()
    return ACT_DOTA_ATTACK
end
