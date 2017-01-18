var dummy = "npc_dota_hero_wisp";
var heroBars = {};
var heroes = null;

var colors = {
    2: [ 255, 82, 66 ],
    3: [ 48, 168, 255 ] ,
    6: [ 197, 77, 168 ],
    7: [ 199, 228, 13 ],
    8: [ 161, 127, 255 ],
    9: [ 101, 212, 19 ]
};

var shieldModifiers = [
    "modifier_gyro_w",
    "modifier_lc_w_shield",
    "modifier_undying_q_health"
];

var hideBarModifiers = [
    "modifier_tusk_e",
    "modifier_ember_e",
    "modifier_hidden",
    "modifier_omni_e",
    "modifier_gyro_e",
    "modifier_storm_spirit_e",
    "modifier_ursa_e",
    "modifier_ursa_r"
];

var etherealModifiers = [
    "modifier_invoker_w"
];

var specialLayouts = {
    "npc_dota_hero_ursa": "UrsaBar",
    //"npc_dota_hero_juggernaut": "JuggBar",
    "npc_dota_hero_undying": "UndyingBar"
};

var specialLayoutCallbacks = {};

specialLayoutCallbacks.npc_dota_hero_ursa = function(entity, panel) {
    var fury = FindModifier(entity.id, "modifier_ursa_fury");
    var frenzy = FindModifier(entity.id, "modifier_ursa_frenzy");
    var bar = panel.FindChildTraverse("UrsaRage");

    panel.FindChildTraverse("UrsaRage_Left").SetHasClass("UrsaFrenzy", !!frenzy);

    if (frenzy) {
        bar.value = 100;
    } else if (fury) {
        bar.value = Buffs.GetStackCount(entity.id, fury);
    }
};

specialLayoutCallbacks.npc_dota_hero_juggernaut = function(entity, panel) {

};

specialLayoutCallbacks.npc_dota_hero_undying = function(entity, panel) {
    var shield = FindModifier(entity.id, "modifier_undying_q_health");
    var bar = panel.FindChildTraverse("UndyingShield");

    if (shield) {
        bar.value = Math.round(Buffs.GetRemainingTime(entity.id, shield) / Buffs.GetDuration(entity.id, shield) * 100);
    } else {
        bar.value = 0;
    }
};

function GetUnitOwner(unit) {
    for (var i = 0; i < Players.GetMaxPlayers(); i++) {
        if (Players.IsValidPlayerID(i) && Entities.IsControllableByPlayer(unit, i)) {
            return i;
        }
    }

    return null;
}

function darken(color, percent) {
    return [ color[0] * percent, color[1] * percent, color[2] * percent ];
}

function clr(color) {
    return "rgb(" + color[0] + "," + color[1] + "," + color[2]+ ")";
}

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
            } else {
                offset = heroes[Entities.GetUnitName(entity)].barOffset;
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

                for (var i = 0; i < Entities.GetNumBuffs(entity.id); i++) {
                    var buff = Entities.GetBuff(entity.id, i);
                    var name = Buffs.GetName(entity.id, buff);

                    if (shieldModifiers.indexOf(name) != -1){
                        shieldAmount += Buffs.GetStackCount(entity.id, buff);
                    }

                    if (hideBarModifiers.indexOf(name) != -1) {
                        hidden = true;
                    }

                    if (etherealModifiers.indexOf(name) != -1) {
                        ethereal = true;
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

                    var team = Entities.GetTeamNumber(entity.id);
                    var bar = panel.FindChild("HealthBar");
                    bar.max = max;
                    bar.value = health;
                    panel.SetHasClass("Ethereal", ethereal);
                    panel.FindChild("HealthValue").SetHasClass("Low", health <= max / 2);
                    panel.FindChild("HealthValue").text = health.toString();

                    if (team != DOTATeam_t.DOTA_TEAM_NOTEAM) {
                        var teamColor = colors[team];
                        panel.FindChildTraverse("HealthBar_Left").style.backgroundColor =
                            "gradient(linear, 0% 0%, 0% 95%, from(" +
                            clr(teamColor) +
                            "), to(" +
                            clr(darken(teamColor, 0.3)) +
                            "));";
                    }

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

                var name = panel.FindChild("PlayerName");
                name.text = Players.GetPlayerName(GetUnitOwner(entity.id));
                name.style.color = clr(teamColor);

                bar.SetHasClass("Ethereal", ethereal);
                panel.SetHasClass("NotVisible", hidden);

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

                var bg = "gradient(linear, 0% 0%, 0% 95%, from(" +
                    clr(darken(teamColor, 0.1)) +
                    "), to(" +
                    clr(darken(teamColor, 0.2)) +
                    "));";

                missing.style.backgroundColor = bg;
                bar.style.backgroundColor = bg;

                panel.style.x = (Math.floor(entity.x) - Math.round(pieceSize * max / 2)) + "px";
                panel.style.y = (Math.floor(entity.y) - 70) + "px";

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

                var callback = specialLayoutCallbacks[Entities.GetUnitName(entity.id)];

                if (callback) {
                    callback(entity, panel);
                }
            } else {
                var panel = $.CreatePanel("Panel", mainPanel, "");
                var layout = specialLayouts[Entities.GetUnitName(entity.id)];

                if (!layout) {
                    layout = entity.light ? "HealthBarLight" : "HealthBar";
                }

                panel.BLoadLayoutSnippet(layout);

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