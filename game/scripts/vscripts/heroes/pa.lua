PA = class({}, {}, Hero)

function PA:GetSpeedMultiplier()
    return self:HasModifier("modifier_pa_r") and 1.6 or 1
end

function PA:SetWeaponVisible(visible)
    if visible then
        self:GetWearableBySlot("weapon"):RemoveEffects(EF_NODRAW)
    else
        self:GetWearableBySlot("weapon"):AddEffects(EF_NODRAW)
    end
end

function PA:WeaponLaunched(projectile)
	self.weapon = projectile
	self:SetWeaponVisible(false)
	self:FindAbility("pa_a"):SetActivated(false)
    self:FindAbility("pa_w"):SetActivated(false)
end

function PA:WeaponRetrieved()
	self:FindAbility("pa_a"):SetActivated(true)
    self:FindAbility("pa_w"):SetActivated(true)

	self:SetWeaponVisible(true)
	self.weapon = nil
end

function PA:WeaponDestroyed()
	if not self.weapon then
		return
	end
	
	self:FindAbility("pa_a"):StartCooldown(1.8)
	self.weapon = nil

	Timers:CreateTimer(1.8, function()
		self:WeaponRetrieved(true)
	end)
end

function PA:GetWeapon()
	return self.weapon
end