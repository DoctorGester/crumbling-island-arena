modifier_nyx_e = class({})


function modifier_nyx_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
    }
    return funcs
end



--[[
function modifier_nyx_e:OrderFilter(event)
    --Check if the order is the glyph type
    local nyxing = hero:FindModifier("modifier_nyx_e")
    if nyxing then
    	hero:EmitSound("Arena.TA.EndE")
	    if event.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
	    
	        local offsetVector = RandomVector(100)
	        event.position_x = event.position_x + offsetVector.x
	        event.position_y = Vector(0, 0, 0) -- this might not work
	        return true
	    end
	end
    --Return true by default to keep all other orders the same
    return true
end
]]

--[[
function modifier_nyx_e:OrderFilter()
    local mode = GameRules:GetGameModeEntity()
    mode:ClearExecuteOrderFilter()
    mode:SetExecuteOrderFilter(function(_, data) return self:OrderFilter(data) end, {}) -- Note: wrapping the call in an anonymous function allows reloading to work properly
    self.initializedOrderFilter = true
end
]]

function modifier_nyx_e:GetModifierDisableTurning( params )
    return 0
end

function modifier_nyx_e:GetModifierMoveSpeedOverride(params)
    return 450
end

