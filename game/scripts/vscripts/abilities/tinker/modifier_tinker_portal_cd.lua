modifier_tinker_portal_cd = class({})
local self = modifier_tinker_portal_cd

function self:DestroyOnExpire()
	return false
end


function self:GetTexture()
	if self:GetRemainingTime() >= 0 then
		return "tinker_cd"
	else
		return "tinker_e_sub"
	end
end

function self:GetPriority()
	return 2
end

function self:GetAttributes()
	return 2 -- MODIFIER_ATTRIBUTE_MULTIPLE
end