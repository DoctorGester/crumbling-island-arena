modifier_timber_r_charges = class({})
local self = modifier_timber_r_charges

function self:GetTexture()
    return "disruptor_thunder_strike"
end

if IsServer() then
    function self:OnCreated()
        self:StartIntervalThink(0.1)
    end

    function self:OnIntervalThink()
        local parent = self:GetParent():GetParentEntity()

        local ability1 = parent:FindAbility("timber_r")
        local timeleft1 = ability1:IsCooldownReady() 
        local ability2 = parent:FindAbility("timber_r_sub")  
        local timeleft2 = ability2:IsCooldownReady()

        -- Some weird shit there and I totally forgot what was the exact problem.

        if timeleft1 and timeleft2 then
            self:SetStackCount(math.min(2, 2))
            self:ForceRefresh()
        elseif (timeleft1 and not ability1:IsHidden() and not timeleft2) or (not timeleft1 and timeleft2 and not ability2:IsHidden()) then
            self:SetStackCount(math.min(1, 2))
            self:ForceRefresh()
        elseif not timeleft1 and not timeleft2 then
            self:SetStackCount(math.min(0, 2))
            self:ForceRefresh()
        end 
    end
end

function self:IsHidden()
    return self:GetStackCount() == 0
end