modifier_ta_e = class({})

function modifier_ta_e:OnDamageDealt(target, hero, amount)
    if instanceof(target, Hero) then
        local modifier = target:FindModifier("modifier_ta_e_counter")

        if not modifier then
            modifier = target:AddNewModifier(hero, self:GetAbility(), "modifier_ta_e_counter", {})
        end

        if modifier then
            modifier:SetStackCount(modifier:GetStackCount() + amount)
            modifier:Update()

            if modifier:GetStackCount() >= 3 then
                self:GetAbility():EndCooldown()
                modifier:Destroy()

                FX("particles/units/heroes/hero_templar_assassin/templar_loadout.vpcf", PATTACH_ABSORIGIN, target, {
                    release = true
                })

                target:EmitSound("Arena.TA.HitE")
            else
                modifier:SetDuration(5, false)
            end
        end
    end
end

function modifier_ta_e:IsHidden()
    return true
end