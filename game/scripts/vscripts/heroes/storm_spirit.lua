StormSpirit = class({}, nil, Hero)

function StormSpirit:constructor()
    self.__base__.constructor(self)

    self.remnants = {}
    self.lastRemnants = {}
end

function StormSpirit:CreateRemnant(location, facing)
    local dummy = CreateUnitByName(self:GetName(), location, false, self.unit, nil, self.unit:GetTeamNumber())

    dummy:SetForwardVector(facing)
    dummy:AddNewModifier(self.unit, nil, "modifier_storm_spirit_remnant", {})
    dummy:EmitSound("Hero_StormSpirit.StaticRemnantPlant")

    table.insert(self.remnants, dummy)
end

function StormSpirit:DestroyRemnant(remnant)
    table.insert(self.lastRemnants, { position = remnant:GetAbsOrigin(), facing = remnant:GetForwardVector() })

    if #self.lastRemnants > 3 then
        table.remove(self.lastRemnants, 1)
    end

    remnant:EmitSound("Hero_StormSpirit.StaticRemnantExplode")
    remnant:RemoveSelf()

    table.remove(self.remnants, GetIndex(self.remnants, remnant))
end

function StormSpirit:FindClosestRemnant(point)
    local closest = nil
    local distance = 64000

    for _, value in pairs(self.remnants) do
        local toRemnant = (point - value:GetAbsOrigin()):Length2D()

        if toRemnant <= distance then
            closest = value
            distance = toRemnant
        end
    end

    return closest
end

function StormSpirit:HasRemnants()
    return #self.remnants > 0
end

function StormSpirit:Delete()
    self.__base__.Delete(self)

    for _, remnant in pairs(self.remnants) do
        remnant:RemoveSelf()
    end
end