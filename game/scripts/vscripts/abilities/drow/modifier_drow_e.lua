modifier_drow_e = class({})

if IsServer() then
    function modifier_drow_e:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        self.currentAngle = math.atan2(hero:GetFacing().y, hero:GetFacing().x) % (math.pi * 2)
        self.damaged = {}

        self:StartIntervalThink(0.02)
        self:OnIntervalThink()

        hero:SetHidden(true)
    end

    function modifier_drow_e:OnIntervalThink()
        self:FireArrow(self.currentAngle)
        self.currentAngle = self.currentAngle + 0.6
    end

    function modifier_drow_e:OnDestroy()
        self:GetParent():GetParentEntity():SetHidden(false)
    end

    function modifier_drow_e:FireArrow(angle)
        local direction = Vector(math.cos(angle), math.sin(angle))
        local hero = self:GetParent():GetParentEntity()
        local damage = self:GetAbility():GetDamage()

        hero:EmitSound("Arena.Drow.CastQ2")

        DistanceCappedProjectile(hero.round, {
            ability = self:GetAbility(),
            owner = hero,
            from = hero:GetPos() + Vector(0, 0, 64),
            to = hero:GetPos() + direction * 100 + Vector(0, 0, 64),
            speed = 1450,
            radius = 48,
            graphics = "particles/drow_q/drow_q.vpcf",
            distance = 300,
            hitSound = "Arena.Drow.HitA",
            hitFunction = function(_, victim)
                if self.damaged[victim] == nil then
                    victim:Damage(hero, damage)
                end

                self.damaged[victim] = true
            end
        }):Activate()
    end
end

function modifier_drow_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function modifier_drow_e:GetEffectName()
    return "particles/drow_q/drow_q_run.vpcf"
end

function modifier_drow_e:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_drow_e:IsInvulnerable()
    return true
end