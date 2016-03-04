modifier_pugna_w = class({})

if IsServer() then
    function modifier_pugna_w:OnCreated(keys)
        self:StartIntervalThink(0.1)

        self.effect = ParticleManager:CreateParticle("particles/pugna_w/pugna_w.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.effect, 2, self:GetCaster().hero:GetTrapColor())
        self:AddParticle(self.effect, false, false, 1, false, false)
    end
end

function modifier_pugna_w:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true
    }

    return state
end

function modifier_pugna_w:OnIntervalThink()
    local hero = self:GetCaster().hero
    local trap = self:GetParent()

    ParticleManager:SetParticleControl(self.effect, 2, hero:GetTrapColor())

    if self:GetElapsedTime() >= 1.5 then
        if not self.rune then
            self.rune = ParticleManager:CreateParticle("particles/pugna_w/pugna_w_rune.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            self:AddParticle(self.rune, false, false, 1, false, false)
        end

        ParticleManager:SetParticleControl(self.rune, 2, hero:GetTrapColor())

        for _, target in pairs(Spells:GetValidTargets()) do
            local distance = (target:GetPos() - trap:GetAbsOrigin()):Length2D()

            if distance <= 96 and target:__instanceof__(Hero) then
                self:GetParent():ForceKill(false)

                if hero:IsReversed() then
                    target:Damage(hero)
                    GameRules.GameMode.Round:CheckEndConditions()
                else
                    target:Heal()
                end

                local effect = ImmediateEffectPoint("particles/pugna_w/pugna_w_explode.vpcf", PATTACH_ABSORIGIN, trap, trap:GetAbsOrigin())
                ParticleManager:SetParticleControl(effect, 2, hero:GetTrapColor())

                trap:EmitSound("Arena.Pugna.HitW")
                target:EmitSound(hero:GetTrapSound())
                break
            end
        end
    end
end
