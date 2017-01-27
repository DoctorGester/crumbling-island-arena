invoker_e = class({})

LinkLuaModifier("modifier_invoker_e", "abilities/invoker/modifier_invoker_e", LUA_MODIFIER_MOTION_NONE)

function invoker_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 800)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local holder = CreateUnitByName(DUMMY_UNIT, target, false, hero.unit, hero.unit, hero.unit:GetTeam())
    holder.hero = hero
    holder:AddNewModifier(holder, self, "modifier_invoker_e", { duration = 4 })
    holder:EmitSound("Arena.CM.CastR")
end

function invoker_e:GetCastAnimation()
    return ACT_DOTA_CAST_ALACRITY
end

function invoker_e:GetPlaybackRateOverride()
    return 1.3
end