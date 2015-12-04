modifier_sniper_w_trap = class({})

function modifier_sniper_w_trap:OnCreated(keys)
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_sniper_w_trap:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVISIBLE] = self:GetElapsedTime() >= 0.3
    }

    return state
end

function modifier_sniper_w_trap:OnIntervalThink()
    local hero = self:GetCaster().hero
    local trap = self:GetParent()

    for _, target in pairs(Spells:GetValidTargets()) do
        local distance = (target:GetPos() - trap:GetAbsOrigin()):Length2D()

        if target ~= hero and distance <= 64 and target:__instanceof__(Hero) then
            self:GetParent():ForceKill(false)
            target:AddNewModifier(hero, self:GetAbility(), "modifier_sniper_w", { duration = 1.7 })
            ImmediateEffectPoint("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_ABSORIGIN, trap, trap:GetAbsOrigin())
            target:EmitSound("Arena.Sniper.HitW")
            break
        end
    end
end


function modifier_sniper_w_trap:GetModifierInvisibilityLevel(params)
    return math.min(self:GetElapsedTime() / 0.3, 1.0)
end
