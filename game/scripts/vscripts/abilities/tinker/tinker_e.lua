tinker_e = class({})

LinkLuaModifier("modifier_tinker_portal_cd", "abilities/tinker/modifier_tinker_portal_cd", LUA_MODIFIER_MOTION_NONE)

if IsClient() then
    require('heroes/hero_util')
end

TinkerUtil.PortalAbility(
    tinker_e,
    false,
    "tinker_e_sub",
    "particles/tinker_e/tinker_e_second_pre.vpcf",
    "particles/tinker_e/tinker_e_second.vpcf",
    "particles/tinker_e/tinker_e_second_warp_b.vpcf"
)