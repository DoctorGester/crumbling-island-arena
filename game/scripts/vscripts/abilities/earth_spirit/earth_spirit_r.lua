earth_spirit_r = class({})
LinkLuaModifier("modifier_earth_spirit_remnant", "abilities/earth_spirit/modifier_earth_spirit_remnant", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_r:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_5
end

function earth_spirit_r:GetChannelTime()
	return 0.5
end

function earth_spirit_r:OnSpellStart()
	self:GetCaster().hero:EmitSound("Arena.Earth.CastR")
end

function earth_spirit_r:OnChannelFinish()
	local hero = self:GetCaster().hero
	local remnant = hero:FindRemnant(self:GetCursorPosition(), 200)

	if not remnant then return end

	local particlePath = "particles/units/heroes/hero_earth_spirit/espirit_magnet_arclightning.vpcf"
	local particle = ImmediateEffect(particlePath, PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, hero:GetPos())
	ParticleManager:SetParticleControl(particle, 1, remnant:GetPos())

	local remnantUnit = remnant.unit
	remnant:SetPos(hero:GetPos())
	remnant:SetUnit(hero.unit, hero:HasRemnantStand())

	if hero:HasRemnantStand() then
		local stand = hero:GetRemnantStand()
		hero:RemoveRemnantStand()
		stand:Destroy()
	end

	hero:EmitSound("Arena.Earth.FinishR")
	hero:AddNewModifier(hero, self, "modifier_earth_spirit_remnant", {})
	FreezeAnimation(hero.unit)

	remnantUnit:RemoveModifierByName("modifier_earth_spirit_remnant")
	remnantUnit:FindAbilityByName(self:GetAbilityName()):StartCooldown(self:GetCooldown(1))
	hero:SetUnit(remnantUnit)
	hero:SetOwner(hero.owner) -- Just refreshing control
	hero:Setup()

	remnantUnit:SetHealth(3 * remnant.health)

	CustomGameEventManager:Send_ServerToPlayer(hero.owner.player, "update_heroes", {})
end

function earth_spirit_r:CastFilterResultLocation(location)
	-- Remnant data can't be accessed on the client
	if not IsServer() then return UF_SUCCESS end

	if not self:GetCaster().hero:FindRemnant(location, 200) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function earth_spirit_r:GetCustomCastErrorLocation(location)
	if not IsServer() then return "" end

	if not self:GetCaster().hero:FindRemnant(location, 200) then
		return "#dota_hud_error_earth_spirit_cant_cast_no_remnant"
	end

	return ""
end
