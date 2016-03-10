venge_w = class({})

LinkLuaModifier("modifier_venge_w", "abilities/venge/modifier_venge_w", LUA_MODIFIER_MOTION_NONE)

function venge_w:OnSpellStart()
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
    projectileData.velocity = 2000
    projectileData.graphics = "particles/venge_w/venge_w.vpcf"
    projectileData.distance = 1400
    projectileData.radius = 64
    projectileData.heroBehaviour =
        function(self, target)
            self.damagedGroup = self.damagedGroup or {}

            if not self.damagedGroup[target] then
                Spells:ProjectileDamage(self, target)

                target:AddNewModifier(hero, ability, "modifier_venge_w", { duration = 3.0 })
                self.damagedGroup[target] = true
            end

            return false
        end

    Spells:CreateProjectile(projectileData)
    hero:EmitSound("Arena.Venge.CastW")
end
