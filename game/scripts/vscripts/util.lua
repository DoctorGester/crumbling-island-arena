function string.starts(str,start)
   return string.sub(str, 1, string.len(start)) == start
end

function string.ends(str, ending)
   return ending == '' or string.sub(str, -string.len(ending)) == ending
end

function string.split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end

   return result
end

function WrapString(str)
    local result = {}
    result[str] = 0
    return result
end

function UnwrapString(table)
    for k, _ in pairs(table) do
        return k
    end
end

function GetIndex(list, element)
    for k, v in pairs(list) do
        if v == element then
            return k
        end
    end

    return nil
end

function Bezier(t, p0, p1, p2, p3)
    local u = 1 - t
    local tt = t*t
    local uu = u*u
    local uuu = uu * u
    local ttt = tt * t

    local p = uuu * p0
    p = p + 3 * uu * t * p1
    p = p + 3 * u * tt * p2
    p = p + ttt * p3

    return p
end

function EaseOutCircular(t, b, c, d)
    t = t / d;
    t = t - 1;
    return c * math.sqrt(1 - t * t) + b;
end

function EaseOutBounce(t, b, c, d)
    t = t / d
    if (t < (1/2.75)) then
        return c*(7.5625*t*t) + b;
    elseif (t < (2/2.75)) then
        t = t - (1.5/2.75)
        return c*(7.5625*t*t + 0.75) + b
    elseif (t < (2.5/2.75)) then
        t = t - (2.25/2.75)
        return c*(7.5625*t*t + 0.9375) + b
    else
        t = t- (2.625/2.75)
        return c*(7.5625*(t)*t + 0.984375) + b
    end
end

function EaseOutElastic(t, b, c, d)
    local p = 0.3
    local v = (2 ^ (-10*t)) * math.sin((t-p/4)*(2*math.pi)/p) + 1
    return v * (t / d) * c + b
end

function EaseInOutBack(t, b, c, d)
    local s = 1.70158;
    local v = nil
    local pos = t / d / 0.5

    if(pos < 1) then
        v = 0.5*(pos*pos*(((s*(1.525))+1)*pos -s))
    else
        pos = pos - 2
        v = 0.5*(pos*pos*(((s*(1.525))+1)*pos +s) +2);
    end

    return v * (t / d) * c + b
end

function FX(path, attach, parent, options)
    if parent and parent.GetUnit then
        parent = parent:GetUnit()
    end

    local index = ParticleManager:CreateParticle(path, attach, parent)

    for i = 0, 16 do
        local cp = options["cp"..tostring(i)]
        local cpf = options["cp"..tostring(i).."f"]

        if cp then
            -- Probably vector
            if type(cp) == "userdata" then
                ParticleManager:SetParticleControl(index, i, cp)
            end

            -- Entity
            if type(cp) == "table" then
                if cp.ent and cp.ent.GetUnit then
                    cp.ent = cp.ent:GetUnit()
                end

                cp.ent = cp.ent or parent

                if not cp.attach then
                    cp.attach = PATTACH_POINT_FOLLOW
                end

                ParticleManager:SetParticleControlEnt(index, i, cp.ent, cp.attach, cp.point, cp.ent:GetAbsOrigin(), true)
            end
        end

        if cpf then
            ParticleManager:SetParticleControlForward(index, i, cpf)
        end
    end

    if options.release then
        ParticleManager:ReleaseParticleIndex(index)
    else
        return index
    end
end

function DFX(index, force)
    force = force ~= nil

    ParticleManager:DestroyParticle(index, force)
    ParticleManager:ReleaseParticleIndex(index)
end

function SplashEffect(point)
    local id = ParticleManager:CreateParticle("particles/econ/courier/courier_kunkka_parrot/courier_kunkka_parrot_splash.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity())
    ParticleManager:SetParticleControl(id, 0, Vector(point.x, point.y, -3500))

    ParticleManager:ReleaseParticleIndex(id)
end

function Shuffle(table)
    local iterations = #table
    local j

    for i = iterations, 2, -1 do
        j = RandomInt(1, i)
        table[i], table[j] = table[j], table[i]
    end
end

function IsOutOfTheMap(pos)
    return pos.x < GetWorldMinX() or pos.y < GetWorldMinY() or pos.x > GetWorldMaxX() or pos.y > GetWorldMaxY()
end

function ClampToMap(pos)
    return Vector(math.max(GetWorldMinX() + 128, math.min(GetWorldMaxX() - 128, pos.x)), math.max(GetWorldMinY() + 128, math.min(GetWorldMaxY() - 128, pos.y)))
end

function IsLeft(a, b, c)
     return ((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)) > 0
end

function RelativeCCW(x1, y1, x2, y2, px, py)
    x2 = x2 - x1
    y2 = y2 - y1
    px = px - x1
    py = py - y1

    local ccw = px * y2 - py * x2

    if ccw == 0.0 then
        ccw = px * x2 + py * y2
        if (ccw > 0.0) then
            px = px - x2
            py = py - y2
            ccw = px * x2 + py * y2
            if ccw < 0.0 then
                ccw = 0.0
            end
        end
    end

    if ccw < 0.0 then
        return -1
    else
        if ccw > 0.0 then
            return 1
        else
            return 0
        end
    end
end

function SegmentsIntersect2(x1, y1, x2, y2, x3, y3, x4, y4)
    local t1 = RelativeCCW(x1, y1, x2, y2, x3, y3) * RelativeCCW(x1, y1, x2, y2, x4, y4)
    local t2 = RelativeCCW(x3, y3, x4, y4, x1, y1) * RelativeCCW(x3, y3, x4, y4, x2, y2)
    return t1 <= 0 and t2 <= 0
end

function SegmentsIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
    local d = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
    if d == 0 then return false end --lines are parallel or coincidental
    local t1 = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / d
    local t2 = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / d

    return t1 >= 0 and t1 <= 1 and t2 >= 0 and t2 <= 1
end

function ClosestPointToSegment(start, finish, point)
    local segment = finish - start
    local pointVector = point - start

    local normalized = segment:Normalized()
    local dot = pointVector:Dot(normalized)

    if dot <= 0 then
        return start
    end

    if dot >= segment:Length2D() then
        return finish
    end

    return start + (normalized * dot)
end

function SegmentCircleIntersection(start, finish, point, radius)
    local closest = ClosestPointToSegment(start, finish, point)
    local dist = point - closest

    return dist:Length2D() <= radius
end

-- max height, full distance, current distance
function ParabolaZ(h, d, x)
  return (4 * h / d) * (d - x) * (x / d)
end

function ParabolaZ2(y0, y1, h, d, x)
    return ((4 * h / d) * (d - x) + y1 - y0) * (x / d) + y0
end

function DashParabola(height)
    return function(dash, current)
        local d = (dash.from - dash.to):Length2D()
        local x = (dash.from - current):Length2D()
        return ParabolaZ(height, d, x)
    end
end

function AddLevelOneAbility(hero, abilityName)
    hero:AddAbility(abilityName):SetLevel(1)
end

function IsAttackAbility(ability)
    return ability and ability:GetName():ends("_a")
end

function ImmediateEffect(path, attach, owner, time)
    local id = ParticleManager:CreateParticle(path, attach, owner.unit or owner)

    Timers:CreateTimer(time or 3,
        function()
            ParticleManager:DestroyParticle(id, false)
            ParticleManager:ReleaseParticleIndex(id)
        end
    )

    return id
end

function ImmediateEffectPoint(path, attach, owner, point, time)
    local effect = ImmediateEffect(path, attach, owner, time)
    ParticleManager:SetParticleControl(effect, 0, point)
    return effect
end

function CreateEntityAOEMarker(point, radius, duration, color, alpha, isThick)
    DynamicEntity()
        :SetPos(point)
        :AddComponent(PlayerCircleComponent(radius, isThick, alpha, color))
        :AddComponent(ExpirationComponent(duration))
        :Activate()
end

function CreateAOEMarker(owner, point, radius, duration, color)
    color = color or Vector(255, 255, 255)
    local particle = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN, owner.unit or owner)

    ParticleManager:SetParticleControl(particle, 0, point)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, 1, 1))
    ParticleManager:SetParticleControl(particle, 2, color)
    ParticleManager:SetParticleControl(particle, 3, Vector(duration, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)
end

function CreateLineMarker(owner, point, target, duration, color)
    color = color or Vector(255, 255, 255)
    local particle = ParticleManager:CreateParticle("particles/line_marker.vpcf", PATTACH_ABSORIGIN, owner.unit or owner)

    ParticleManager:SetParticleControl(particle, 0, point)
    ParticleManager:SetParticleControl(particle, 1, target)
    ParticleManager:SetParticleControl(particle, 2, color)
    ParticleManager:SetParticleControl(particle, 3, Vector(duration, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)
end

--[[
Declares a general lua modifier
definition is {
    IsDebuff = true,
    GetEffectName = "vfx.vpcf"
}

states are {
    MODIFIER_STATE_STUNNED,
    MODIFIER_STATE_NO_HEALTH_BAR
}

properties are {
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION = ACT_DOTA_DISABLED,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE = function(self) return self:GetParent():GetBaseMoveSpeed() end
}
]]

_G.modifierFunctions = {
    MODIFIER_EVENT_ON_ABILITY_END_CHANNEL = "OnAbilityEndChannel",
    MODIFIER_EVENT_ON_ABILITY_EXECUTED = "OnAbilityExecuted",
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST = "OnAbilityFullyCast",
    MODIFIER_EVENT_ON_ABILITY_START = "OnAbilityStart",
    MODIFIER_EVENT_ON_ATTACK = "OnAttack",
    MODIFIER_EVENT_ON_ATTACKED = "OnAttacked",
    MODIFIER_EVENT_ON_ATTACK_ALLIED = "OnAttackAllied",
    MODIFIER_EVENT_ON_ATTACK_FAIL = "OnAttackFail",
    MODIFIER_EVENT_ON_ATTACK_FINISHED = "OnAttackFinished",
    MODIFIER_EVENT_ON_ATTACK_LANDED = "OnAttackLanded",
    MODIFIER_EVENT_ON_ATTACK_RECORD = "OnAttackRecord",
    MODIFIER_EVENT_ON_ATTACK_START = "OnAttackStart",
    MODIFIER_EVENT_ON_BREAK_INVISIBILITY = "OnBreakInvisibility",
    MODIFIER_EVENT_ON_BUILDING_KILLED = "OnBuildingKilled",
    MODIFIER_EVENT_ON_DEATH = "OnDeath",
    MODIFIER_EVENT_ON_DOMINATED = "OnDominated",
    MODIFIER_EVENT_ON_HEALTH_GAINED = "OnHealthGained",
    MODIFIER_EVENT_ON_HEAL_RECEIVED = "OnHealReceived",
    MODIFIER_EVENT_ON_HERO_KILLED = "OnHeroKilled",
    MODIFIER_EVENT_ON_MANA_GAINED = "OnManaGained",
    MODIFIER_EVENT_ON_MODEL_CHANGED = "OnModelChanged",
    MODIFIER_EVENT_ON_ORB_EFFECT = "",
    MODIFIER_EVENT_ON_ORDER = "OnOrder",
    MODIFIER_EVENT_ON_PROCESS_UPGRADE = "",
    MODIFIER_EVENT_ON_PROJECTILE_DODGE = "OnProjectileDodge",
    MODIFIER_EVENT_ON_REFRESH = "",
    MODIFIER_EVENT_ON_RESPAWN = "OnRespawn",
    MODIFIER_EVENT_ON_SET_LOCATION = "OnSetLocation",
    MODIFIER_EVENT_ON_SPELL_TARGET_READY = "OnSpellTargetReady",
    MODIFIER_EVENT_ON_SPENT_MANA = "OnSpentMana",
    MODIFIER_EVENT_ON_STATE_CHANGED = "OnStateChanged",
    MODIFIER_EVENT_ON_TAKEDAMAGE = "OnTakeDamage",
    MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT = "OnTakeDamageKillCredit",
    MODIFIER_EVENT_ON_TELEPORTED = "OnTeleported",
    MODIFIER_EVENT_ON_TELEPORTING = "OnTeleporting",
    MODIFIER_EVENT_ON_UNIT_MOVED = "OnUnitMoved",
    MODIFIER_FUNCTION_INVALID = "",
    MODIFIER_FUNCTION_LAST = "",
    MODIFIER_PROPERTY_ABILITY_LAYOUT = "GetModifierAbilityLayout",
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL = "GetAbsoluteNoDamageMagical",
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL = "GetAbsoluteNoDamagePhysical",
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE = "GetAbsoluteNoDamagePure",
    MODIFIER_PROPERTY_ABSORB_SPELL = "GetAbsorbSpell",
    MODIFIER_PROPERTY_ALWAYS_ALLOW_ATTACK = "GetAlwaysAllowAttack",
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT = "GetModifierAttackSpeedBonus_Constant",
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT_POWER_TREADS = "GetModifierAttackSpeedBonus_Constant_PowerTreads",
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT_SECONDARY = "GetModifierAttackSpeedBonus_Constant_Secondary",
    MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT = "GetModifierAttackPointConstant",
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS = "GetModifierAttackRangeBonus",
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE = "GetModifierAttackRangeBonusUnique",
    MODIFIER_PROPERTY_AVOID_DAMAGE = "GetModifierAvoidDamage",
    MODIFIER_PROPERTY_AVOID_SPELL = "GetModifierAvoidSpell",
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE = "GetModifierBaseAttack_BonusDamage",
    MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE = "GetModifierBaseDamageOutgoing_Percentage",
    MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE_UNIQUE = "GetModifierBaseDamageOutgoing_PercentageUnique",
    MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT = "GetModifierBaseAttackTimeConstant",
    MODIFIER_PROPERTY_BASE_MANA_REGEN = "GetModifierBaseRegen",
    MODIFIER_PROPERTY_BONUS_DAY_VISION = "GetBonusDayVision",
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION = "GetBonusNightVision",
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION_UNIQUE = "GetBonusNightVisionUnique",
    MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE = "GetBonusVisionPercentage",
    MODIFIER_PROPERTY_BOUNTY_CREEP_MULTIPLIER = "GetModifierBountyCreepMultiplier",
    MODIFIER_PROPERTY_BOUNTY_OTHER_MULTIPLIER = "GetModifierBountyOtherMultiplier",
    MODIFIER_PROPERTY_CASTTIME_PERCENTAGE = "GetModifierPercentageCasttime",
    MODIFIER_PROPERTY_CAST_RANGE_BONUS = "GetModifierCastRangeBonus",
    MODIFIER_PROPERTY_CHANGE_ABILITY_VALUE = "GetModifierChangeAbilityValue",
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE = "GetModifierPercentageCooldown",
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING = "GetModifierPercentageCooldownStacking",
    MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT = "GetModifierCooldownReduction_Constant",
    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE = "GetModifierDamageOutgoing_Percentage",
    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE_ILLUSION = "GetModifierDamageOutgoing_Percentage_Illusion",
    MODIFIER_PROPERTY_DEATHGOLDCOST = "GetModifierConstantDeathGoldCost",
    MODIFIER_PROPERTY_DISABLE_AUTOATTACK = "GetDisableAutoAttack",
    MODIFIER_PROPERTY_DISABLE_HEALING = "GetDisableHealing",
    MODIFIER_PROPERTY_DISABLE_TURNING = "GetModifierDisableTurning",
    MODIFIER_PROPERTY_EVASION_CONSTANT = "GetModifierEvasion_Constant",
    MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS = "GetModifierExtraHealthBonus",
    MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE = "GetModifierExtraHealthPercentage",
    MODIFIER_PROPERTY_EXTRA_MANA_BONUS = "GetModifierExtraManaBonus",
    MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS = "GetModifierExtraStrengthBonus",
    MODIFIER_PROPERTY_FIXED_DAY_VISION = "GetFixedDayVision",
    MODIFIER_PROPERTY_FIXED_NIGHT_VISION = "GetFixedNightVision",
    MODIFIER_PROPERTY_FORCE_DRAW_MINIMAP = "GetForceDrawOnMinimap",
    MODIFIER_PROPERTY_HEALTH_BONUS = "GetModifierHealthBonus",
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT = "GetModifierConstantHealthRegen",
    MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE = "GetModifierHealthRegenPercentage",
    MODIFIER_PROPERTY_IGNORE_CAST_ANGLE = "GetModifierIgnoreCastAngle",
    MODIFIER_PROPERTY_IGNORE_COOLDOWN = "GetModifierIgnoreCooldown",
    MODIFIER_PROPERTY_ILLUSION_LABEL = "GetModifierIllusionLabel",
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE = "GetModifierIncomingDamage_Percentage",
    MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_CONSTANT = "GetModifierIncomingPhysicalDamageConstant",
    MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE = "GetModifierIncomingPhysicalDamage_Percentage",
    MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT = "GetModifierIncomingSpellDamageConstant",
    MODIFIER_PROPERTY_INVISIBILITY_LEVEL = "GetModifierInvisibilityLevel",
    MODIFIER_PROPERTY_IS_ILLUSION = "GetIsIllusion",
    MODIFIER_PROPERTY_IS_SCEPTER = "GetModifierScepter",
    MODIFIER_PROPERTY_LIFETIME_FRACTION = "GetUnitLifetimeFraction",
    MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK = "GetModifierMagical_ConstantBlock",
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS = "GetModifierMagicalResistanceBonus",
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE = "GetModifierMagicalResistanceDecrepifyUnique",
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_ITEM_UNIQUE = "GetModifierMagicalResistanceItemUnique",
    MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE = "GetModifierMagicDamageOutgoing_Percentage",
    MODIFIER_PROPERTY_MANACOST_PERCENTAGE = "GetModifierPercentageManacost",
    MODIFIER_PROPERTY_MANA_BONUS = "GetModifierManaBonus",
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT = "GetModifierConstantManaRegen",
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT_UNIQUE = "GetModifierConstantManaRegenUnique",
    MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE = "GetModifierPercentageManaRegen",
    MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE = "GetModifierTotalPercentageManaRegen",
    MODIFIER_PROPERTY_MAX_ATTACK_RANGE = "GetModifierMaxAttackRange",
    MODIFIER_PROPERTY_MIN_HEALTH = "GetMinHealth",
    MODIFIER_PROPERTY_MISS_PERCENTAGE = "GetModifierMiss_Percentage",
    MODIFIER_PROPERTY_MODEL_CHANGE = "GetModifierModelChange",
    MODIFIER_PROPERTY_MODEL_SCALE = "GetModifierModelScale",
    MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE = "GetModifierMoveSpeed_Absolute",
    MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN = "GetModifierMoveSpeed_AbsoluteMin",
    MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE = "GetModifierMoveSpeedOverride",
    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT = "GetModifierMoveSpeedBonus_Constant",
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE = "GetModifierMoveSpeedBonus_Percentage",
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE = "GetModifierMoveSpeedBonus_Percentage_Unique",
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE_2 = "GetModifierMoveSpeedBonus_Percentage_Unique_2",
    MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE = "GetModifierMoveSpeedBonus_Special_Boots",
    MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE_2 = "GetModifierMoveSpeedBonus_Special_Boots_2",
    MODIFIER_PROPERTY_MOVESPEED_LIMIT = "GetModifierMoveSpeed_Limit",
    MODIFIER_PROPERTY_MOVESPEED_MAX = "GetModifierMoveSpeed_Max",
    MODIFIER_PROPERTY_NEGATIVE_EVASION_CONSTANT = "GetModifierNegativeEvasion_Constant",
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION = "GetOverrideAnimation",
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE = "GetOverrideAnimationRate",
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT = "GetOverrideAnimationWeight",
    MODIFIER_PROPERTY_OVERRIDE_ATTACK_MAGICAL = "GetOverrideAttackMagical",
    MODIFIER_PROPERTY_PERSISTENT_INVISIBILITY = "GetModifierPersistentInvisibility",
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS = "GetModifierPhysicalArmorBonus",
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS_ILLUSIONS = "GetModifierPhysicalArmorBonusIllusions",
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS_UNIQUE = "GetModifierPhysicalArmorBonusUnique",
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS_UNIQUE_ACTIVE = "GetModifierPhysicalArmorBonusUniqueActive",
    MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK = "GetModifierPhysical_ConstantBlock",
    MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK_SPECIAL = "GetModifierPhysical_ConstantBlockSpecial",
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE = "GetModifierPreAttack_BonusDamage",
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT = "GetModifierPreAttack_BonusDamagePostCrit",
    MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE = "GetModifierPreAttack_CriticalStrike",
    MODIFIER_PROPERTY_PREATTACK_TARGET_CRITICALSTRIKE = "GetModifierPreAttack_Target_CriticalStrike",
    MODIFIER_PROPERTY_PRESERVE_PARTICLES_ON_MODEL_CHANGE = "PreserveParticlesOnModelChanged",
    MODIFIER_PROPERTY_PRE_ATTACK = "GetModifierPreAttack",
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL = "GetModifierProcAttack_BonusDamage_Magical",
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL = "GetModifierProcAttack_BonusDamage_Physical",
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE = "GetModifierProcAttack_BonusDamage_Pure",
    MODIFIER_PROPERTY_PROCATTACK_FEEDBACK = "GetModifierProcAttack_Feedback",
    MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS = "GetModifierProjectileSpeedBonus",
    MODIFIER_PROPERTY_PROVIDES_FOW_POSITION = "GetModifierProvidesFOWVision",
    MODIFIER_PROPERTY_REFLECT_SPELL = "GetReflectSpell",
    MODIFIER_PROPERTY_REINCARNATION = "ReincarnateTime",
    MODIFIER_PROPERTY_RESPAWNTIME = "GetModifierConstantRespawnTime",
    MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE = "GetModifierPercentageRespawnTime",
    MODIFIER_PROPERTY_RESPAWNTIME_STACKING = "GetModifierStackingRespawnTime",
    MODIFIER_PROPERTY_SPELLS_REQUIRE_HP = "GetModifierSpellsRequireHP",
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE = "GetModifierSpellAmplify_Percentage",
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS = "GetModifierBonusStats_Agility",
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS = "GetModifierBonusStats_Intellect",
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS = "GetModifierBonusStats_Strength",
    MODIFIER_PROPERTY_SUPER_ILLUSION = "GetModifierSuperIllusion",
    MODIFIER_PROPERTY_SUPER_ILLUSION_WITH_ULTIMATE = "GetModifierSuperIllusionWithUltimate",
    MODIFIER_PROPERTY_TEMPEST_DOUBLE = "GetModifierTempestDouble",
    MODIFIER_PROPERTY_TOOLTIP = "OnTooltip",
    MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE = "GetModifierTotalDamageOutgoing_Percentage",
    MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK = "GetModifierTotal_ConstantBlock",
    MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK_UNAVOIDABLE_PRE_ARMOR = "GetModifierPhysical_ConstantBlockUnavoidablePreArmor",
    MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS = "GetActivityTranslationModifiers",
    MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND = "GetAttackSound",
    MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE = "GetModifierTurnRate_Percentage",
    MODIFIER_PROPERTY_UNIT_STATS_NEEDS_REFRESH = "GetModifierUnitStatsNeedsRefresh",
}

_G.GenericModifier = function(definition, states, properties)
    local modifier = class({})

    for property, value in pairs(definition) do
        modifier[property] = function(self)
            if type(value) == "function" then
                return value(self)
            end

            return value
        end
    end

    modifier.CheckState = function()
        local finalState = {}

        for _, state in ipairs(states) do
            finalState[state] = true
        end

        return finalState
    end

    modifier.DeclareFunctions = function()
        local funcs = {}

        for property, _ in pairs(properties) do
            table.insert(funcs, _G[property])
        end

        return funcs
    end

    for property, value in pairs(properties) do
        modifier[modifierFunctions[property]] = function(self)
            if type(value) == "function" then
                return value(self)
            end

            return value
        end
    end

    return modifier
end

function FilterPassPlayers(players)
    local result = {}

    for _, player in pairs(players) do
        if PlayerResource:HasCustomGameTicketForPlayerID(player.id) or IsInToolsMode() then
            table.insert(result, tostring(PlayerResource:GetSteamID(player.id)))
        end
    end

    return result
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  local canCompare = true
  for k, v in pairs(t) do
    table.insert(l, k)
    if type(k) == "table" then
        canCompare = false
    end
  end

  if canCompare then
    table.sort(l)
  end
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

function PrintSchema(gameArray, playerArray)
    print("-------- GAME DATA --------")
    DeepPrintTable(gameArray)
    print("\n-------- PLAYER DATA --------")
    DeepPrintTable(playerArray)
    print("-------------------------------------")
end