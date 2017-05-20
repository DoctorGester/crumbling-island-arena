var dummy = "npc_dota_hero_wisp";
var heroBars = {};
var heroes = null;

function darken(color, percent) {
    return [ color[0] * percent, color[1] * percent, color[2] * percent ];
}

function clr(color) {
    return "rgb(" + color[0] + "," + color[1] + "," + color[2]+ ")";
}

$("#HeroBarsContainer").RemoveAndDeleteChildren();

function UpdateHeroBars(){
    $.Schedule(1 / 120, UpdateHeroBars);

    var mainPanel = $("#HeroBarsContainer");
    var all = Entities.GetAllHeroEntities().filter(function(entity) {
        return !Entities.IsUnselectable(entity);
    });

    var classes = [ "npc_dota_creep_neutral", "npc_dota_creature" ];

    for (var cl of classes) {
        all = all.concat(Entities.GetAllEntitiesByClassname(cl).filter(function(entity) {
            return HasModifier(entity, "modifier_custom_healthbar");
        }));
    }

    if (heroes == null) {
        heroes = CustomNetTables.GetTableValue("static", "heroes");

        if (heroes == null) {
            return;
        }
    }

    mainPanel.SetHasClass("AltPressed", GameUI.IsAltDown());

    var onScreen = _
        .chain(all)
        .reject(function(entity) {
            return Entities.IsOutOfGame(entity);
        })
        .filter(function(entity) {
            return Entities.IsAlive(entity);
        })
        .map(function(entity) {
            var abs = Entities.GetAbsOrigin(entity);
            var lightBar = HasModifier(entity, "modifier_custom_healthbar");
            var offset;

            if (lightBar) {
                offset = 150;

                lightBar = {
                    rem: GetRemainingModifierTime(entity, "modifier_custom_healthbar"),
                    dur: GetModifierDuration(entity, "modifier_custom_healthbar")
                }
            } else {
                var nm = Entities.GetUnitName(entity);
                offset = heroes[nm].barOffset;

                var specialModifier = specialOffsetModifiers[nm];

                if (specialModifier) {
                    offset += (specialModifier(entity) || 0);
                }
            }

            var x = Game.WorldToScreenX(abs[0], abs[1], abs[2] + offset);
            var y = Game.WorldToScreenY(abs[0], abs[1], abs[2] + offset);

            return { id: entity, x: x, y: y, abs: abs, light: lightBar };
        })
        .reject(function(mapped) {
            return mapped.x == -1 || mapped.y == -1;
        })
        .filter(function(mapped) {
            return GameUI.GetScreenWorldPosition(mapped.x, mapped.y) != null;
        })
        .each(function(entity) {
            if (_.has(heroBars, entity.id)) {
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
            } else {
                var panel = $.CreatePanel("Panel", mainPanel, "");
                var special = specialLayouts[Entities.GetUnitName(entity.id)];

                panel.BLoadLayoutSnippet(entity.light ? "HealthBarLight" : "HealthBar");

                if (special) {
                    panel.FindChildTraverse("SpecialBar").BLoadLayoutSnippet(special);
                    panel.FindChildTraverse("SpecialBar").SetHasClass("Hidden", false);
                }

                if (!entity.light) {
                    panel.cached = {};

                    var bar = panel.FindChildTraverse("HealthBar");
                    var teamColor = colors[Entities.GetTeamNumber(entity.id)];
                    var name = panel.FindChildTraverse("PlayerName");
                    name.text = Players.GetPlayerName(GetPlayerOwnerID(entity.id));
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
                    var team = Entities.GetTeamNumber(entity.id);

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

                heroBars[entity.id] = panel;
            }
        })
        .value();

    var oldEntities = _.omit(heroBars, function(value, key) {
        return _.some(onScreen, function(entity) { return entity.id == key });
    });

    _.each(oldEntities, function(panel, key) {
        panel.DeleteAsync(0);
        delete heroBars[key];
    });
}

UpdateHeroBars();