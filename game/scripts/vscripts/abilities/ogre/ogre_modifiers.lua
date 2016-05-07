require("util")

modifier_ogre_1 = GenericModifier(
    {
        IsDebuff = true,
        GetEffectName = "particles/generic_gameplay/generic_slowed_cold.vpcf",
        GetEffectAttachType = PATTACH_ABSORIGIN_FOLLOW,
        GetStatusEffectName = "particles/status_fx/status_effect_frost_lich.vpcf",
        StatusEffectPriority = 2,
    },
    {},
    { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE = -40 }
)

modifier_ogre_2 = GenericModifier(
    {
        IsDebuff = false,
        GetEffectName = "particles/units/heroes/hero_sven/sven_warcry_buff_b.vpcf",
        GetEffectAttachType = PATTACH_ABSORIGIN_FOLLOW,
    },
    {},
    { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE = 40 }
)

modifier_ogre_3 = GenericModifier(
    {
        IsDebuff = true,
        GetEffectName = "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle.vpcf",
        GetEffectAttachType = PATTACH_ABSORIGIN_FOLLOW
    },
    {
        MODIFIER_STATE_ROOTED
    },
    {}
)

modifier_ogre_4 = GenericModifier(
    {
        IsDebuff = false,
    },
    {
        MODIFIER_STATE_INVISIBLE
    },
    { MODIFIER_PROPERTY_INVISIBILITY_LEVEL = 1 }
)

modifier_ogre_5 = GenericModifier(
    {
        IsDebuff = true,
        GetEffectName = "particles/generic_gameplay/generic_silence.vpcf",
        GetEffectAttachType = PATTACH_OVERHEAD_FOLLOW
    },
    {
        MODIFIER_STATE_SILENCED
    },
    {}
)

modifier_ogre_6 = GenericModifier(
    {
        IsDebuff = true,
        GetDuration = 1.5,
        GetEffectName = "particles/items_fx/item_sheepstick.vpcf",
        GetEffectAttachType = PATTACH_ABSORIGIN
    },
    {
        MODIFIER_STATE_SILENCED
    },
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE = -40,
        MODIFIER_PROPERTY_MODEL_CHANGE = "models/items/hex/sheep_hex/sheep_hex.vmdl",
        MODIFIER_PROPERTY_PRESERVE_PARTICLES_ON_MODEL_CHANGE = false
    }
)