modifier_tiny_r = class({})

function modifier_tiny_r:ChangeModelLevel(previous, level)
    local model = self:GetParent():FirstMoveChild()

    level = tostring(level)
    previous = tostring(previous)

    while model ~= nil do
        if model:GetClassname() == "prop_dynamic" then
            local newName = string.gsub(model:GetModelName(), previous, level)
            model:SetModel(newName)
        end
        model = model:NextMovePeer()
    end
end

if IsServer() then
    function modifier_tiny_r:Use()
        self.used = true
        self:SetDuration(0.5, true)
    end

    function modifier_tiny_r:OnCreated(kv)
        self.used = false

        self:ChangeModelLevel(1, 4)
    end

    function modifier_tiny_r:OnDestroy(kv)
        self:ChangeModelLevel(4, 1)

        ImmediateEffect("particles/units/heroes/hero_tiny/tiny_transform.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    end
end

function modifier_tiny_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }

    return funcs
end

function modifier_tiny_r:GetModifierMoveSpeedBonus_Percentage(params)
    return 15
end

function modifier_tiny_r:GetModifierModelChange()
    return "models/heroes/tiny_04/tiny_04.vmdl"
end

function modifier_tiny_r:GetEffectName()
    return "particles/units/heroes/hero_tiny/tiny_transform.vpcf"
end

function modifier_tiny_r:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end