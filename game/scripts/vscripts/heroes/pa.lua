PA = class({}, {}, Hero)

function PA:SetUnit(unit)
    getbase(PA).SetUnit(self, unit)

    for _, part in pairs({ "cape", "daggers", "helmet", "shoulders" }) do
        self:AttachWearable("models/heroes/phantom_assassin/phantom_assassin_"..part..".vmdl")
    end

    self.weaponModel = self:AttachWearable("models/heroes/phantom_assassin/phantom_assassin_weapon.vmdl")
end

function PA:GetSpeedMultiplier()
    return self:HasModifier("modifier_pa_r") and 2 or 1
end

function PA:SetWeaponVisible(visible)
    if visible then
        self.weaponModel:RemoveEffects(EF_NODRAW)
    else
        self.weaponModel:AddEffects(EF_NODRAW)
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