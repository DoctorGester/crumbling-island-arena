modifier_tree_heal = class({})

if IsServer() then
    function modifier_tree_heal:OnCreated()
        self:StartIntervalThink(1)
        self:SetStackCount(2)

        self:GetParent():GetParentEntity():EmitSound("Arena.TreeHealStart")
    end

    function modifier_tree_heal:OnIntervalThink()
        self:GetParent():GetParentEntity():Heal(1)

        self:DecrementStackCount()

        if self:GetStackCount() == 0 then
            self:Destroy()
        end
    end
end

function modifier_tree_heal:GetEffectName()
    return "particles/items_fx/healing_tango.vpcf"
end

function modifier_tree_heal:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tree_heal:GetTexture()
    return "../items/tango"
end