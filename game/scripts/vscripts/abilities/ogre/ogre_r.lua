LinkLuaModifier("modifier_ogre_r", "abilities/ogre/modifier_ogre_r", LUA_MODIFIER_MOTION_NONE)

ogre_r = class({})

function ogre_r:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_ogre_r", { duration = 6 })
    hero:EmitSound("Arena.Ogre.CastR")
    hero:EmitSound("Arena.Ogre.CastR2")
    hero:EmitSound("Arena.Ogre.CastR3")
    hero:EmitSound("Arena.Ogre.CastR4")
end