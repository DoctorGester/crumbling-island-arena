StormSpirit = class({}, nil, Hero)

function StormSpirit:constructor(data)
    self.__base__.constructor(self, data)

    self.remnants = {}
    self.lastRemnants = {}
end

function StormSpirit:AddRemnant(remnant)
    table.insert(self.remnants, remnant)
end

function StormSpirit:RemoveRemnant(remnant)
    table.insert(self.lastRemnants, { position = remnant:GetPos(), facing = remnant:GetFacing() })

    if #self.lastRemnants > 3 then
        table.remove(self.lastRemnants, 1)
    end

    table.remove(self.remnants, GetIndex(self.remnants, remnant))
end

function StormSpirit:FindClosestRemnant(point)
    local closest = nil
    local distance = 64000

    for _, value in pairs(self.remnants) do
        local toRemnant = (point - value:GetPos()):Length2D()

        if toRemnant <= distance and not value.falling then
            closest = value
            distance = toRemnant
        end
    end

    return closest
end

function StormSpirit:HasRemnants()
    return #self.remnants > 0
end

function StormSpirit:Remove()
    self:StopSound("Arena.Storm.LoopE")

    getbase(StormSpirit).Remove(self)
end