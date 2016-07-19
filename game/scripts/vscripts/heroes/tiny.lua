Tiny = class({}, {}, Hero)

function Tiny:SetUnit(unit)
    getbase(Tiny).SetUnit(self, unit)

    for _, part in pairs({ "body", "head", "left_arm", "right_arm" }) do
        self:AttachWearable("models/heroes/tiny_01/tiny_01_"..part..".vmdl")
    end
end