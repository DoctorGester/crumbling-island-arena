tinker_e = class({})

require("abilities/tinker/entity_tinker_e")

if IsClient() then
    require('heroes/hero_util')
end

TinkerUtil.PortalAbility(
    tinker_e,
    true,
    "tinker_e_sub",
    "particles/econ/items/tinker/boots_of_travel/teleport_start_bots.vpcf",
    "particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf",
    "particles/econ/items/tinker/boots_of_travel/teleport_end_bots_warp_b.vpcf"
)