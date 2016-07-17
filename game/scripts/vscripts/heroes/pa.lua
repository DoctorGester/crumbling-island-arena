PA = class({}, {}, Hero)

function PA:GetSpeedMultiplier()
    return self:HasModifier("modifier_pa_r") and 2 or 1
end

function PA:SetWeaponVisible(visible)
	local wearable = self:GetUnit():FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if string.find(wearable:GetModelName(), "weapon") then
            	if visible then
            		wearable:RemoveEffects(EF_NODRAW)
            	else
            		wearable:AddEffects(EF_NODRAW)
            	end

                return
            end
        end

        wearable = wearable:NextMovePeer()
    end
end

function PA:WeaponLaunched(projectile)
	self.weapon = projectile
	self:SwapAbilities("pa_q", "pa_q_sub")
	self:SwapAbilities("pa_w", "pa_w_sub")
	self:SetWeaponVisible(false)
	self:FindAbility("pa_q_sub"):StartCooldown(1.0)
    self:FindAbility("pa_q_sub"):SetActivated(true)
end

function PA:WeaponRetrieved(wasDestroyed)
	self:SwapAbilities("pa_q_sub", "pa_q")
	self:SwapAbilities("pa_w_sub", "pa_w")

    if not wasDestroyed then
        self:FindAbility("pa_q"):StartCooldown(1.4)
    end

	self:SetWeaponVisible(true)
	self.weapon = nil
end

function PA:WeaponDestroyed()
	if not self.weapon then
		return
	end
	
	self:FindAbility("pa_q_sub"):StartCooldown(3)
	self.weapon = nil

	Timers:CreateTimer(3, function()
		self:WeaponRetrieved(true)
	end)
end

function PA:GetWeapon()
	return self.weapon
end