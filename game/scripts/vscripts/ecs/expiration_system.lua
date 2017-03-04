ExpirationSystem = ExpirationSystem or System("lifetime", "timeStart")

function ExpirationSystem:Update()
    if GameRules:GetGameTime() - self.timeStart >= self.lifetime then
        if self.OnExpire then
            self:OnExpire()
        end

        self:Destroy()
    end
end