tinker_e_sub = class({})

if IsClient() then
    require('heroes/hero_util')
end

TinkerUtil.PortalCancelAbility(
    tinker_e_sub,
    false,
    "tinker_e"
)