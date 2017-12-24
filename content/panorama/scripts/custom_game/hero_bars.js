var heroPanels = {};
var heroBars = {};
var mainPanel = $("#HeroBarsContainer");

function darken(color, percent) {
    return [ color[0] * percent, color[1] * percent, color[2] * percent ];
}

function clr(color) {
    return "rgb(" + color[0] + "," + color[1] + "," + color[2]+ ")";
}

$("#HeroBarsContainer").RemoveAndDeleteChildren();

function UpdateBar(entity, spawn) {
    var panel = heroBars[entity.id];
    var w = 100;

    var shieldAmount = 0;
    var hidden = false;
    var ethereal = false;
    var statusEffect;
    var statusEffectPriority = 0;
    var statusEffectTime = 0;
    var statusEffectProgress;
    var statusEffectRecast = false;
    var statusEffectAbility;

    var attackSpeedProgress;
    var attackSpeedStacks;

    for (var i = 0; i < Entities.GetNumBuffs(entity.id); i++) {
        var buff = Entities.GetBuff(entity.id, i);
        var name = Buffs.GetName(entity.id, buff);

        if (name == "modifier_attack_speed") {
            attackSpeedProgress = Buffs.GetRemainingTime(entity.id, buff) / Buffs.GetDuration(entity.id, buff);
            attackSpeedStacks = Buffs.GetStackCount(entity.id, buff);
            continue;
        }

        if (shieldModifiers.indexOf(name) != -1){
            shieldAmount += Buffs.GetStackCount(entity.id, buff);
        }

        if (hideBarModifiers.indexOf(name) != -1) {
            hidden = true;
        }

        if (etherealModifiers.indexOf(name) != -1) {
            ethereal = true;
        }

        var fx = statusEffects[name];
        var rc = recastModifiers.indexOf(name) != -1;

        if (rc && Entities.GetTeamNumber(entity.id) !== Players.GetTeam(Players.GetLocalPlayer())) {
            continue;
        }

        if (fx && fx.priority >= statusEffectPriority && Buffs.GetCreationTime(entity.id, buff) >= statusEffectTime) {
            var dur = Buffs.GetDuration(entity.id, buff);

            statusEffect = fx;
            statusEffectPriority = fx.priority;
            statusEffectTime = Buffs.GetCreationTime(entity.id, buff);
            statusEffectProgress = dur <= 0.15 ? 0 : Math.round(Buffs.GetRemainingTime(entity.id, buff) / dur * 100);
            statusEffectRecast = rc;
            statusEffectAbility = Buffs.GetAbility(entity.id, buff);
        }
    }

    if (panel.cached && panel.cached.attackTimer) {
        panel.cached.attackTimer.SetHasClass("TimerHidden", !attackSpeedProgress);

        if (attackSpeedProgress) {
            var pg = -Math.round(attackSpeedProgress * 360);
            panel.cached.attackTimer.style.clip = "radial(50% 50%, 0deg, " + pg + "deg)";
            panel.cached.attackTimer.SetHasClass("DangerZone", attackSpeedStacks == 3);
            panel.cached.attackTimer.SetHasClass("MaxReached", attackSpeedStacks == 4);
        }
    }

    for (var name of Object.keys(ultimateAbilities)) {
        var ability = Entities.GetAbilityByName(entity.id, name);

        if (ability && Abilities.GetChannelStartTime(ability) > 0) {
            statusEffect = ultimateAbilities[name];
            statusEffectProgress = Math.round(100 - (Game.GetGameTime() - Abilities.GetChannelStartTime(ability)) / Abilities.GetChannelTime(ability) * 100);
        }
    }

    var screenHR = Game.GetScreenHeight() / 1080;

    entity.x /= screenHR;
    entity.y /= screenHR;

    var health = Entities.GetHealth(entity.id) + shieldAmount;
    var max = Entities.GetMaxHealth(entity.id) + shieldAmount;

    if (entity.light) {
        panel.style.x = (Math.floor(entity.x) - 40) + "px";
        panel.style.y = (Math.floor(entity.y) - 48) + "px";

        var bar = panel.FindChild("HealthBar");
        bar.max = max;
        bar.value = health;
        bar.SetHasClass("WithTransition", entity.light.dur <= 0);
        panel.SetHasClass("Expiring", entity.light.dur > 0 && entity.light.rem < 0.25);
        panel.SetHasClass("Ethereal", ethereal);
        panel.FindChild("HealthValue").SetHasClass("Low", health <= max / 2);
        panel.FindChild("HealthValue").text = health.toString();

        return;
    }

    var bar = panel.FindChildTraverse("HealthBar");
    var teamColor = colors[Entities.GetTeamNumber(entity.id)];
    var pieceSize = Math.round(w / max);
    pieceSize = 5;

    if (max >= 30) {
        pieceSize = 4;
    }

    if (max >= 40) {
        pieceSize = 3;
    }

    panel.style.x = (Math.floor(entity.x) - Math.round(Math.max(pieceSize * max, 140) / 2)) + "px";
    panel.style.y = (Math.floor(entity.y) - 50) + "px";

    var callback = specialLayoutCallbacks[Entities.GetUnitName(entity.id)];

    if (callback) {
        callback(entity, panel);
    }

    bar.SetHasClass("Ethereal", ethereal);
    panel.SetHasClass("NotVisible", hidden);

    if (panel.cached.statusFx !== statusEffect) {
        panel.cached.statusFx = statusEffect;

        var top = panel.FindChildTraverse("StatusEffectContainer");
        var prog = top.FindChildTraverse("StatusEffectProgress");
        var recast = top.FindChildTraverse("StatusEffectRecast");

        if (statusEffect) {
            var name = top.FindChildTraverse("StatusEffectName");
            name.text = $.Localize(statusEffect.token).toUpperCase();
            name.style.color = statusEffect.color;
            prog.style.backgroundColor = statusEffect.color;

            if (statusEffectRecast) {
                recast.SetImage(GetTexture({
                    texture: Abilities.GetAbilityTextureName(statusEffectAbility),
                    name: Abilities.GetAbilityName(statusEffectAbility)
                }, customIcons));

                top.FindChildTraverse("RecastHotkey").text = Abilities.GetKeybind(statusEffectAbility);
            }
        } else {
            prog.style.width = "100px";
        }

        top.SetHasClass("RecastVisible", statusEffectRecast);
        recast.SetHasClass("Hidden", !statusEffectRecast);
        panel.SetHasClass("StatusEffect", !!statusEffect);
    }

    if (statusEffect) {
        panel.FindChildTraverse("StatusEffectProgress").style.width = statusEffectProgress + "px"
    }

    if (panel.cached.health === health && panel.cached.max === max && panel.cached.shieldAmount === shieldAmount) {
        return;
    }

    panel.cached.health = health;
    panel.cached.max = max;
    panel.cached.shieldAmount = shieldAmount;

    var valueMaxColor = [ 142, 231, 45 ];
    var valueLabel = panel.FindChildTraverse("HealthValue");
    var pc = (1 - health / max);
    valueLabel.text = health.toString();
    valueMaxColor[0] = valueMaxColor[0] + (255 - valueMaxColor[0]) * pc;
    valueMaxColor[1] = valueMaxColor[1] - valueMaxColor[1] * pc;

    valueLabel.style.color = clr(valueMaxColor);

    var healthChildren = bar.FindChildrenWithClassTraverse("Health");
    var shieldChildren = bar.FindChildrenWithClassTraverse("Shield");
    var diff = (health - shieldAmount) - healthChildren.length;
    var shieldDiff = shieldAmount - shieldChildren.length;;

    var missing = bar.FindChild("MissingHealth");
    var delim = bar.FindChild("ShieldDelim");

    // To go in line with .DeleteAsync
    $.Schedule(0, function() {
        missing.style.width = ((max - health) * pieceSize).toString() + "px";
    });

    if (diff > 0) {
        for (var i = 0; i < diff; i++) {
            $.Schedule(0, function() {
                var p = $.CreatePanel("Panel", bar, "");
                p.AddClass("Health");
                p.style.width = pieceSize.toString() + "px";
                p.style.backgroundColor =
                    "gradient(linear, 0% 0%, 0% 95%, from(" +
                    clr(teamColor) +
                    "), to(" +
                    clr(darken(teamColor, 0.5)) +
                    "));";

                bar.MoveChildBefore(p, delim);
            });
        }
    } else if (diff < 0) {
        var i = 0;
        for (var child of healthChildren) {
            if (i >= -diff) { break; }
            child.DeleteAsync(0);
            i++;
        }
    }

    if (shieldDiff > 0) {
        for (var i = 0; i < shieldDiff; i++) {
            $.Schedule(0, function() {
                var p = $.CreatePanel("Panel", bar, "");
                p.AddClass("Shield");
                p.style.width = pieceSize.toString() + "px";

                bar.MoveChildBefore(p, missing);
            })
        }
    } else if (shieldDiff < 0) {
        var i = 0;
        for (var child of shieldChildren) {
            if (i >= -shieldDiff) { break; }
            child.DeleteAsync(0);
            i++;
        }
    }

    healthChildren = bar.FindChildrenWithClassTraverse("Health");
    shieldChildren = bar.FindChildrenWithClassTraverse("Shield");

    for (var child of healthChildren.concat(shieldChildren)) {
        child.style.width = pieceSize.toString() + "px";
    }
}

function DetectAndPushSpecialEntities(all) {
    var special = {};

    // Special handing of jugg swords
    var h = Players.GetLocalPlayerPortraitUnit();
    if (Entities.GetUnitName(h) == "npc_dota_hero_juggernaut") {
        var owner = GetPlayerOwnerID(h);

        for (var ent of Entities.GetAllEntitiesByClassname("npc_dota_creep_neutral")) {
            if (Entities.GetUnitName(ent) == "jugg_sword" && GetPlayerOwnerID(ent) == owner) {
                all.push({
                    id: ent,
                    isRealHero: false
                });

                var count = GetStackCount(h, "modifier_jugger_sword");
                var level = 1;

                if (count >= 500) level++;
                if (count >= 800) level++;
                if (count >= 1300) level++;

                special[ent] = level;
                ent.isSpecial = true;
                break;
            }
        }
    }

    return special;
}

function CreateBar(entityId, lightBar) {
    var panel = $.CreatePanel("Panel", mainPanel, "");
    var special = specialLayouts[Entities.GetUnitName(entityId)];

    panel.BLoadLayoutSnippet(lightBar ? "HealthBarLight" : "HealthBar");

    if (special) {
        panel.FindChildTraverse("SpecialBar").BLoadLayoutSnippet(special);
        panel.FindChildTraverse("SpecialBar").SetHasClass("Hidden", false);
    }

    panel.light = !!lightBar;

    if (!lightBar) {
        panel.cached = {};

        var bar = panel.FindChildTraverse("HealthBar");
        var teamColor = colors[Entities.GetTeamNumber(entityId)];
        var name = panel.FindChildTraverse("PlayerName");
        name.text = Players.GetPlayerName(GetPlayerOwnerID(entityId));
        name.style.color = clr(teamColor);

        var missing = bar.FindChild("MissingHealth");
        var bg = "gradient(linear, 0% 0%, 0% 95%, from(" +
            clr(darken(teamColor, 0.1)) +
            "), to(" +
            clr(darken(teamColor, 0.2)) +
            "));";

        missing.style.backgroundColor = bg;
        bar.style.backgroundColor = bg;

        panel.cached.attackTimer = panel.FindChildTraverse("AttackTimer");
    } else {
        var team = Entities.GetTeamNumber(entityId);

        if (team != DOTATeam_t.DOTA_TEAM_NOTEAM) {
            var teamColor = colors[team];
            panel.FindChildTraverse("HealthBar_Left").style.backgroundColor =
                "gradient(linear, 0% 0%, 0% 95%, from(" +
                clr(teamColor) +
                "), to(" +
                clr(darken(teamColor, 0.3)) +
                "));";
        }
    }

    return panel;
}

function ValidateAndUpdateOnScreenEntity(entityId, screenX, screenY, lightBar) {
    var changedBarTypeAndNeedsRecreation = _.has(heroBars, entityId) && heroBars[entityId].light !== !!lightBar;

    if (changedBarTypeAndNeedsRecreation) {
        return false;
    }

    if (_.has(heroBars, entityId)) {
        UpdateBar({ id: entityId, x: screenX, y: screenY, light: lightBar });
    } else {
        heroBars[entityId] = CreateBar(entityId, lightBar);

        UpdateBar({ id: entityId, x: screenX, y: screenY, light: lightBar });
    }

    return true;
}

function UpdateHeroDetectorPanel(entityId, screenX, screenY) {
    var panel = heroPanels[entityId];
    var screenWidth = Game.GetScreenWidth();
    var screenHeight = Game.GetScreenHeight();
    var realW = Clamp(screenX, 0, screenWidth - panel.actuallayoutwidth) / screenWidth;
    var realH = Clamp(screenY, 0, screenHeight - panel.actuallayoutwidth) / screenHeight;

    if (isNaN(realW) || isNaN(realH)) {
        return;
    }

    panel.style.position = parseInt(realW * 100) + "% " + parseInt(realH * 100) + "% 0px";

    if (!panel.BHasClass("HeroMarkerTransition")) {
        panel.AddClass("HeroMarkerTransition");
    }
}

function CreateHeroDetectorPanel(entityId, specialLevel) {
    var panel;

    if (specialLevel) {
        panel = $.CreatePanel("Panel", mainPanel, "");
        panel.AddClass("HeroMarkerJuggSwordContainer");

        var bg = $.CreatePanel("Panel", panel, "");
        bg.AddClass("HeroMarkerJuggSwordBG");

        var sw = $.CreatePanel("Panel", panel, "");
        sw.AddClass("HeroMarkerJuggSword");
        sw.AddClass("T" + specialLevel);
    } else {
        panel = $.CreatePanel("DOTAHeroImage", mainPanel, "");
        panel.heroname = Entities.GetUnitName(entityId);
        panel.heroimagestyle = "icon";
    }

    panel.hittest = false;

    return panel;
}

function ValidateAndUpdateOffScreenEntity(entityId, screenX, screenY, isRealHero, specialLevel) {
    if (!isRealHero && !specialLevel) {
        return false;
    }

    if (_.has(heroPanels, entityId)) {
        UpdateHeroDetectorPanel(entityId, screenX, screenY);
    } else {
        heroPanels[entityId] = CreateHeroDetectorPanel(entityId, specialLevel);

        UpdateHeroDetectorPanel(entityId, screenX, screenY);
    }

    return true;
}

function DetermineOffsetAndLightBarData(entityId) {
    var lightBar = HasModifier(entityId, "modifier_custom_healthbar");
    var offset;

    if (lightBar) {
        offset = 150;

        lightBar = {
            rem: GetRemainingModifierTime(entityId, "modifier_custom_healthbar"),
            dur: GetModifierDuration(entityId, "modifier_custom_healthbar")
        }
    } else {
        var nm = Entities.GetUnitName(entityId);
        offset = Entities.GetHealthBarOffset(entityId);

        var specialModifier = specialOffsetModifiers[nm];

        if (specialModifier) {
            offset += (specialModifier(entityId) || 0);
        }
    }

    return {
        offset: offset,
        lightBar: lightBar
    }
}

function UpdateHeroBars(){
    $.Schedule(1 / 120, UpdateHeroBars);

    var classes = [ "npc_dota_creep_neutral", "npc_dota_creature" ];
    var all = [];

    for (var heroEntity of Entities.GetAllHeroEntities()) {
        var isSelectable = !Entities.IsUnselectable(heroEntity);
        var hasCustomHealthbar = HasModifier(heroEntity, "modifier_custom_healthbar");

        if (isSelectable || hasCustomHealthbar) {
            all.push({
                id: heroEntity,
                isRealHero: isSelectable
            })
        }
    }

    for (var cl of classes) {
        var dataArray = Entities.GetAllEntitiesByClassname(cl)
            .filter(function(entity) {
                return HasModifier(entity, "modifier_custom_healthbar");
            })
            .map(function(id) {
                return {
                    id: id,
                    isRealHero: false
                }
            });

        all = all.concat(dataArray);
    }

    mainPanel.SetHasClass("AltPressed", GameUI.IsAltDown());

    var special = DetectAndPushSpecialEntities(all);
    var trulyOnScreen = [];
    var trulyNotOnScreen = [];

    for (var entityData of all) {
        var entityId = entityData.id;

        if (Entities.IsOutOfGame(entityId) || !Entities.IsAlive(entityId)) {
            continue;
        }

        var abs = Entities.GetAbsOrigin(entityId);
        var offsetAndLightBarData = DetermineOffsetAndLightBarData(entityId);

        var offset = offsetAndLightBarData.offset;
        var lightBar = offsetAndLightBarData.lightBar;

        var screenX = Game.WorldToScreenX(abs[0], abs[1], abs[2] + offset);
        var screenY = Game.WorldToScreenY(abs[0], abs[1], abs[2] + offset);

        if (screenX == -1 || screenY == -1) {
            continue
        }

        var isOnScreen = GameUI.GetScreenWorldPosition(screenX, screenY) != null;

        if (isOnScreen) {
            if (!special[entityId] && ValidateAndUpdateOnScreenEntity(entityId, screenX, screenY, lightBar)) {
                trulyOnScreen.push(entityId);
            }
        } else {
            if (ValidateAndUpdateOffScreenEntity(entityId, screenX, screenY, entityData.isRealHero, special[entityId])) {
                trulyNotOnScreen.push(entityId);
            }
        }
    }

    // Everything around there is crap code, but this is extra crap, unreadable!
    {
        var oldEntities = _.omit(heroBars, function(value, key) {
            return _.some(trulyOnScreen, function(entityId) { return entityId == key });
        });

        _.each(oldEntities, function(panel, key) {
            panel.DeleteAsync(0);
            delete heroBars[key];
        });
    }

    {
        var oldEntities = _.omit(heroPanels, function(value, key) {
            return _.some(trulyNotOnScreen, function(entityId) { return entityId == key });
        });

        _.each(oldEntities, function(panel, key) {
            panel.DeleteAsync(0);
            delete heroPanels[key];
        });
    }
}

UpdateHeroBars();