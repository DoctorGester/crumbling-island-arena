Pugna = class({}, {}, Hero)

function Pugna:SetUnit(unit)
    self.__base__.SetUnit(self, unit)

    self.ambientParticle = self:AttachParticle("particles/pugna/ambient.vpcf", "attach_belly")
    self.weaponParticle = self:AttachParticle("particles/pugna/weapon_glow.vpcf", "attach_attack1")

    self:UpdateColor()
end

function Pugna:AttachParticle(path, attach)
    local index = ParticleManager:CreateParticle(path, PATTACH_POINT_FOLLOW, self.unit)
    ParticleManager:SetParticleControlEnt(index, 0, self.unit, PATTACH_POINT_FOLLOW, attach, self.unit:GetOrigin(), true)

    return index
end

function Pugna:UpdateColor()
    local color = self:GetProjectileColor()

    ParticleManager:SetParticleControl(self.ambientParticle, 3, color)
    ParticleManager:SetParticleControl(self.weaponParticle, 2, color)

    self.unit:SetRenderColor(color.x, color.y, color.z)

    for _, wearable in pairs(self.wearables) do
        local m = wearable:GetModelName()

        if m == "models/heroes/pugna/pugna_shoulder.vmdl" or
           m == "models/heroes/pugna/pugna_head.vmdl" or
           m == "models/heroes/pugna/pugna_weapon.vmdl"
        then 
            wearable:SetRenderColor(color.x, color.y, color.z)
        end
    end
end

function Pugna:GetProjectileSound()
    if self:IsReversed() then
        return "Arena.Pugna.Heal"
    end

    return "Arena.Pugna.Damage"
end

function Pugna:GetTrapSound()
    if self:IsReversed() then
        return "Arena.Pugna.Damage"
    end

    return "Arena.Pugna.Heal"
end

function Pugna:IsReversed()
    return self:FindAbility("pugna_e"):GetToggleState()
end

function Pugna:Damage(source)
    if not self.unit:HasModifier("modifier_pugna_r") then
        Hero.Damage(self, source)
    end
end

function Pugna:Heal()
    if not self.unit:HasModifier("modifier_pugna_r") then
        Hero.Heal(self)
    end
end

function Pugna:GetProjectileColor()
    if self:IsReversed() then
        return Vector(58, 193, 0)
    end

    return Vector(255, 128, 0)
end

function Pugna:GetTrapColor()
    if self:IsReversed() then
        return Vector(255, 128, 0)
    end

    return Vector(58, 193, 0)
end