nyx_e = class({})

LinkLuaModifier("modifier_nyx_e", "abilities/nyx/modifier_nyx_e", LUA_MODIFIER_MOTION_NONE)



function nyx_e:OnToggle()
    local hero = self:GetCaster().hero
    local on = self:GetToggleState()

    if on then
        hero:AddNewModifier(hero, self, "modifier_nyx_e", {})
        --hero.nyx_e:OrderFilter(hero)
    else
        hero:FindModifier("modifier_nyx_e"):Destroy()
    end
    
    hero:EmitSound("Arena.Nyx.CastE")
    self:StartCooldown(self:GetCooldown(1))
end

--[[
function nyx_e:OrderFilter(event, hero)

        if event == DOTA_UNIT_ORDER_MOVE_TO_POSITION and nyxing then
        	event.position_y = event.position_y - offsetVector.y
        	return true
        end
    
end
]]


function nyx_e:GetIntrinsicModifierName()
    return "modifier_nyx_e"
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(nyx_e)