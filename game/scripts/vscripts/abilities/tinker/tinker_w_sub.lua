tinker_w_sub = class({})

if IsClient() then
    require('heroes/hero_util')
end

TinkerUtil.PortalCancelAbility(
    tinker_w_sub,
    true,
    "tinker_w"
)