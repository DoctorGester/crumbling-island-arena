ogre_e = class({})

function ogre_e:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:RollRandomSpell()
    hero:EmitSound("Arena.Ogre.CastE")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ogre_e)