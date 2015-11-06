Sniper = class({}, nil, Hero)

function Sniper:constructor()
    self.__base__.constructor(self)

    self.traps = {}
end

function Sniper:Delete()
    self.__base__.Delete(self)

    for _, trap in pairs(self.traps) do
        if IsValidEntity(trap) then
            trap:RemoveSelf()
        end
    end
end