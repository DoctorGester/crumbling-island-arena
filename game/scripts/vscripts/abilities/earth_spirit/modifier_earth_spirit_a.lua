modifier_earth_spirit_a = class({})

if IsServer() then
    function modifier_earth_spirit_a:OnCreated()
        self:StartIntervalThink(0.6)
        self:OnIntervalThink()
    end

    function modifier_earth_spirit_a:OnIntervalThink()
        FX("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            cp1 = self:GetParent():GetAbsOrigin() + Vector(0, 0, 100),
            cp2 = Vector(300, 1, 1),
            release = true
        })
    end
end