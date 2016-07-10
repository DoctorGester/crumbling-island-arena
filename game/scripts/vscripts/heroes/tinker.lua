Tinker = class({}, {}, Hero)

function Tinker:SetFirstPortal(first)
    self.firstPortal = first
end

function Tinker:SetSecondPortal(second)
    self.secondPortal = second
end

function Tinker:GetFirstPortal(first)
    return self.firstPortal
end

function Tinker:GetSecondPortal(second)
    return self.secondPortal
end
