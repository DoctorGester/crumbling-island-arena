Tinker = class({}, {}, Hero)

function Tinker:SetFirstPortal(first)
    self.firstPortal = first
end

function Tinker:SetSecondPortal(second)
    self.secondPortal = second
end

function Tinker:GetFirstPortal()
    if self.firstPortal and not self.firstPortal:Alive() then
        return nil
    end

    return self.firstPortal
end

function Tinker:GetSecondPortal()
    if self.secondPortal and not self.secondPortal:Alive() then
        return nil
    end

    return self.secondPortal
end
