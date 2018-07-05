Brewmaster = class({}, {}, Hero)

function Brewmaster:Init() end

function Brewmaster:Update()
    getbase(Brewmaster).Update(self)

    self:FindAbility("brew_e"):SetActivated(self:FindAbility("brew_q"):CountBeer(self) > 0)
end