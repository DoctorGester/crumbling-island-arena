Zeus = class({
    wall = nil
}, {}, Hero)

function Zeus:SetUnit(unit)
    self.__base__.SetUnit(self, unit)

    local children = unit:GetChildren()

    for _, child in pairs(children) do
        if child:GetClassname() == "dota_item_wearable" then
            if not string.find(child:GetModelName(), "hair") then
                child:AddEffects(EF_NODRAW)
            end
        end
    end
end

function Zeus:GetWall()
    return wall.startPoint, wall.endPoint
end

function Zeus:SetWall(startPoint, endPoint)
    self.wall = { startPoint = startPoint, endPoint = endPoint }
end

function Zeus:WallIntersection(from, to)
    if self.wall then
        local s = self.wall.startPoint
        local f = self.wall.endPoint
        return SegmentsIntersect2(from.x, from.y, to.x, to.y, s.x, s.y, f.x, f.y)
    end

    return false
end

function Zeus:RemoveWall()
    self.wall = nil
end