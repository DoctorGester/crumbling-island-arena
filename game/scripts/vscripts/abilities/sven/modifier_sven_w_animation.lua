modifier_sven_w_animation_one = class({})

function modifier_sven_w_animation_one:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
 
	return funcs
end

function modifier_sven_w_animation_one:GetActivityTranslationModifiers()
	return "sven_shield"
end

function modifier_sven_w_animation_one:IsHidden()
	return true
end

modifier_sven_w_animation_two = class({})

function modifier_sven_w_animation_two:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
 
	return funcs
end

function modifier_sven_w_animation_two:GetActivityTranslationModifiers()
	return "sven_warcry"
end

function modifier_sven_w_animation_two:IsHidden()
	return true
end
