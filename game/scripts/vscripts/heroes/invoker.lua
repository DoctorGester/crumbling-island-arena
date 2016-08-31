Invoker = class({}, {}, Hero)

function Invoker:GetAwardSeason()
    return 2
end

function Invoker:SetOwner(owner)
    getbase(Invoker).SetOwner(self, owner)

    if self:IsAwardEnabled() then
        for _, part in pairs({ "bracer", "cape", "hair", "belt", "shoulder" }) do
            self:AttachWearable("models/items/invoker/dark_artistry/dark_artistry_"..part.."_model.vmdl")
        end

        self:AttachWearable("models/heroes/invoker/invoker_head.vmdl")
    else
        for _, part in pairs({ "bracer", "cape", "head", "dress", "shoulder", "hair" }) do
            self:AttachWearable("models/heroes/invoker/invoker_"..part..".vmdl")
        end
    end
end