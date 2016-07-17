modifier_lycan_e = class({})

function modifier_lycan_e:OnCreated()
    if IsServer() then
        self.bleedingOccured = self:GetCaster().hero:IsBleeding(self:GetParent().hero)

        local unit = self:GetParent()
        local direction = unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
        local position = unit:GetAbsOrigin() + direction:Normalized() * 2000

        ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, Position = position })
    end
end

function modifier_lycan_e:OnDestroy()
    if IsServer() and self.bleedingOccured then
        local hero = self:GetCaster().hero
        local target = self:GetParent().hero

        if hero:IsTransformed() then
            target:AddNewModifier(hero, self:GetAbility(), "modifier_lycan_e_silence", { duration = 1.7 })
        end
    end
end

function modifier_lycan_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_lycan_e:GetEffectName()
    return "particles/econ/items/nightstalker/nightstalker_black_nihility/nightstalker_black_nihility_void.vpcf"
end
 
function modifier_lycan_e:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
 
function modifier_lycan_e:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_INVISIBLE] = false
    }
 
    return state
end


function modifier_lycan_e:GetModifierMoveSpeedBonus_Percentage(params)
    return 20
end