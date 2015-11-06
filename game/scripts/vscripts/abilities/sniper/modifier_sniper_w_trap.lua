modifier_sniper_w_trap = class({})

function modifier_sniper_w_trap:OnCreated(keys)
    if IsServer() then
        self.timePassed = 0
        self:StartIntervalThink(0.1)
    end
end

function modifier_sniper_w_trap:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true
    }

    if IsServer() then
        if self.timePassed >= 1.0 then
            self.timePassed = -1
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible", { fadetime = 0.3 })
        end

        state[MODIFIER_STATE_INVISIBLE] = self.timePassed > 1.0 or self.timePassed == -1
    end

    return state
end

function modifier_sniper_w_trap:OnIntervalThink()
    if IsServer() then
        if self.timePassed ~= -1 then
            self.timePassed = self.timePassed + 0.1
        end

        local hero = self:GetCaster().hero
        local trap = self:GetParent()

        for _, target in pairs(Spells:GetValidTargets()) do
            local distance = (target:GetPos() - trap:GetAbsOrigin()):Length2D()

            if target ~= hero and distance <= 64 then
                self:GetParent():ForceKill(false)
                target:AddNewModifier(hero, self:GetAbility(), "modifier_sniper_w", { duration = 1.7 })
                ImmediateEffectPoint("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_ABSORIGIN, trap, trap:GetAbsOrigin())
                target:EmitSound("Arena.Sniper.HitW")
                break
            end
        end
    end
end