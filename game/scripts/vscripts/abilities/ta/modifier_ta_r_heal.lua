modifier_ta_r_heal = class({})

if IsServer() then
    function modifier_ta_r_heal:OnDestroy()
        self:GetParent().hero:Heal()
        self:GetParent().hero:EmitSound("Arena.TA.HitR2")

        ImmediateEffect("particles/items3_fx/fish_bones_active.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
    end
end

function modifier_ta_r_heal:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ta_r_heal:GetTexture()
    return "templar_assassin_refraction_damage"
end