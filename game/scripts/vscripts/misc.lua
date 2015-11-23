Misc = class({})

function Misc:DoActionWithPAWeapon(hero, action)
    local wearable = hero:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if string.find(wearable:GetModelName(), "weapon") then
                action(wearable)
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

function Misc:RetrievePAWeapon(hero)
    hero:SwapAbilities("pa_q", "pa_q_sub", true, false)
    hero:SwapAbilities("pa_w", "pa_w_sub", true, false)

    if hero.inFirstJump then
        hero:SwapAbilities("pa_e", "pa_e_sub", false, true)
        hero:FindAbilityByName("pa_e_sub"):SetActivated(true)
    end

    hero.paQProjectile = nil

    Misc:DoActionWithPAWeapon(hero, function(wearable) wearable:RemoveEffects(EF_NODRAW) end)
end

function Misc:RemovePAWeapon(hero)
    hero:SwapAbilities("pa_q", "pa_q_sub", false, true)
    hero:SwapAbilities("pa_w", "pa_w_sub", false, true)
    hero:SwapAbilities("pa_e", "pa_e_sub", true, false)
    hero:FindAbilityByName("pa_q_sub"):StartCooldown(1.0)
    hero:FindAbilityByName("pa_q_sub"):SetActivated(true)

    Misc:DoActionWithPAWeapon(hero, function(wearable) wearable:AddEffects(EF_NODRAW) end)
end

function Misc:DestroyPAWeapon(hero)
    hero = hero.unit

    hero:SwapAbilities("pa_q", "pa_q_sub", true, false)
    hero:FindAbilityByName("pa_q"):StartCooldown(3)

    if not hero:FindAbilityByName("pa_e_sub"):IsHidden() then
        hero:SwapAbilities("pa_e", "pa_e_sub", true, false)
    end

    hero.paQProjectile = nil

    Timers:CreateTimer(3,
        function()
            hero:SwapAbilities("pa_w", "pa_w_sub", true, false)

            Misc:DoActionWithPAWeapon(hero,
                function(wearable)
                    wearable:RemoveEffects(EF_NODRAW)

                    -- Does not work since scaling wearables is not supported
                    local scale = 0.0
                    Timers:CreateTimer(
                        function()
                            scale = math.min(1.0, scale + 0.01)
                            wearable:SetModelScale(scale)

                            if scale == 1.0 then
                                return false
                            end

                            return 0.01
                        end
                    )
                end
            )
        end
    )
end

function Misc:GetPASpeedMultiplier(projectile)
    if projectile.owner:FindModifier("modifier_pa_r") then
        return 2
    end

    return 1
end

function Misc:SetUpPAProjectile(projectileData)
    projectileData.heroCondition =
        function(self, target, prev, pos)
            return target:Alive() and SegmentCircleIntersection(prev, pos, target:GetPos(), self.radius + target:GetRad())
        end

    projectileData.heroBehaviour =
        function(self, target)
            if self.gracePeriod[target] == nil or self.gracePeriod[target] <= 0 then
                if self.owner == target then
                    Misc:RetrievePAWeapon(self.owner.unit)
                    self.owner:EmitSound("Arena.PA.Catch")
                    return true
                else
                    Spells:ProjectileDamage(self, target)
                    self.dummy:EmitSound("DOTA_Item.BattleFury")
                    self.gracePeriod[target] = 30
                end
            end

            return false
        end

    projectileData.onMove =
        function(self, prev, cur)
            for target, time in pairs(self.gracePeriod) do
                self.gracePeriod[target] = time - 1
            end
        end

    projectileData.onProjectileCollision =
        function(self, second)
            Misc:DestroyPAWeapon(self.owner)
        end
end