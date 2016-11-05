tinker_e_sub = class({})

if IsClient() then
    require('heroes/hero_util')
end

TinkerUtil.PortalAbility(
    tinker_e_sub,
    false,
    "tinker_e",
    "particles/tinker_e/tinker_e_second_pre.vpcf",
    "particles/tinker_e/tinker_e_second.vpcf",
    "particles/tinker_e/tinker_e_second_warp_b.vpcf"
)