modifier_pl_a = class({})
local self = modifier_pl_a
--local illu = EntityPLIllusion
--local truepl = self:GetParent().hero

if IsServer() then
    function self:OnCreated()
        local index = ParticleManager:CreateParticle("particles/pl_projectile/pl_projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

        self:GetParent():AddNoDraw()
    end

    function self:OnDestroy()
        local target = self:GetParent()

        if self:GetParent():GetParentEntity():Alive() then
            self:GetParent():RemoveNoDraw()
        end

        if not instanceof(target, EntityPLIllusion) then
            target:AddNewModifier(target, self.ability, "modifier_pl_a_dmg", { duration = 2 })
        end
        --local hero = self:GetParent():GetParentEntity()
        --hero:AddNewModifier(hero, self, "modifier_pl_a_dmg", { duration = 2.0 })
        --hero:AddNewModifier(hero, self:GetAbility(), "modifier_pl_a_dmg", { duration = 2.0 })
        --if self:GetName() == "npc_dota_hero_phantom_lancer" then
        --    self:GetParent():GetParentEntity():AddNewModifier(self:GetCaster():GetParentEntity(), self:GetAbility(), "modifier_pl_a_dmg", { duration = 2.0 })
        --end
    end
end

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        --[MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function self:Airborne()
    return true
end