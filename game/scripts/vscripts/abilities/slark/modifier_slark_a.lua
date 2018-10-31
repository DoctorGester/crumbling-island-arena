modifier_slark_a = class({})

if IsServer() then
    function modifier_slark_a:OnCreated()
        self.stacks = {}
        self:StartIntervalThink(0)
    end

    function modifier_slark_a:OnIntervalThink()
        if #self.stacks > 0 then
            for i=#self.stacks,1,-1 do
                if GameRules:GetGameTime() - self.stacks[i].timeAdded > 12 then
                    self:DestroyStack(i)
                end
            end
        end
    end

    function modifier_slark_a:OnDestroy()
        for i=#self.stacks,1,-1 do
            self:DestroyStack(i)
        end
    end
end

function modifier_slark_a:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_slark_a:GetModifierMoveSpeedBonus_Percentage(params)
    local speedBonus = self:GetParent() == self:GetAbility():GetCaster() and 7 or -7
    if self:GetAbility():GetCaster():GetParentEntity():FindModifier("modifier_slark_r") then
        speedBonus = speedBonus * 2
    end

    return speedBonus * self:GetStackCount()
end

function modifier_slark_a:AddNewStack(target)
    self:IncrementStackCount()
    self:ForceRefresh()

    table.insert(self.stacks, { timeAdded = GameRules:GetGameTime(), target = target })
end

function modifier_slark_a:DestroyStack(index)
    if self.stacks[index].target and self.stacks[index].target:Alive() then
        local color = Vector(161, 127, 255)
        local hero = self:GetParent():GetParentEntity()

        hero:EmitSound("Arena.Slark.EndA")

        FX("particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit(), {
            cp0 = {ent = self.stacks[index].target:GetUnit(), point = "attach_hitloc"},
            cp1 = {ent = hero:GetUnit(), point = "attach_hitloc"},
            cp10 = color,
            cp11 = color,
            cp15 = color,
            cp16 = color
        })
    end

    self:DecrementStackCount()
    table.remove(self.stacks,index)
end

function modifier_slark_a:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_slark_a:IsDebuff()
    if self:GetParent() == self:GetAbility():GetCaster() then
        return false 
    else 
        return true
    end
end