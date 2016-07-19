Pudge = class({}, {}, Hero)

function Pudge:SetUnit(unit)
    getbase(Pudge).SetUnit(self, unit)

    for _, part in pairs({ "back", "belt", "bracer", "hair", "leftarm", "leftweapon" }) do
        self:AttachWearable("models/heroes/pudge/"..part..".vmdl")
    end

    self.hook = self:AttachWearable("models/heroes/pudge/righthook.vmdl")
end

function Pudge:SetHookVisible(visible)
    if visible then
        self.hook:RemoveEffects(EF_NODRAW)
    else
        self.hook:AddEffects(EF_NODRAW)
    end
end
