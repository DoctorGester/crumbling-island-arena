modifier_pl_w_invul = class({})
local self = modifier_pl_w_invul

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function self:IsHidden()
    return true
end

function self:IsInvulnerable()
    return true
end

function self:OnModifierAdded()
    return false
end

if IsServer() then
    function self:OnCreated()
        self:GetParent():AddNoDraw()

        local hero = self:GetParent():GetParentEntity()
        local source = self:GetCaster():GetParentEntity()

        self.target = source:GetPos() - source:GetFacing() * 180
        self.facing = source:GetFacing()

        FX("particles/pl_w/pl_w.vpcf", PATTACH_ABSORIGIN, hero, {
            cp1 = self.target,
            release = true
        })

        FX("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_aoe.vpcf", PATTACH_ABSORIGIN, hero, {
            cp2 = Vector(150, 1, 1),
            cp3 = Vector(1, 0, 0),
            release = true
        })
    end

    function self:OnDestroy()
        self:GetParent():RemoveNoDraw()

        local hero = self:GetParent():GetParentEntity()

        hero:EmitSound("Arena.PL.EndW")

        hero:FindClearSpace(self.target, true)
        hero:SetFacing(self.facing)
        hero:GetUnit():Interrupt()
    end
end