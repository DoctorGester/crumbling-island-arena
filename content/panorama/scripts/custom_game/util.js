Error.prototype.toString = function () {
    this.stack = this.stack.replace(/\.vjs_c/g, '.js');

    // toString is called by panorama with empty call stack
    if (new Error().stack.match(/\n/g).length !== 1) return this.stack;

    return this.stack;
};

GAME_STATE_NONE = 0
GAME_STATE_GAME_SETUP = 1
GAME_STATE_HERO_SELECTION = 2
GAME_STATE_ROUND_IN_PROGRESS = 3
GAME_STATE_ROUND_ENDED = 4
GAME_STATE_GAME_OVER = 5
GAME_STATE_GAME_OVER_DM = 6

if (!Game.enterListeners) {
    Game.enterListeners = {};
}

Game.OnEnterPressed = function() {
    for (var key in Game.enterListeners) {
        Game.enterListeners[key]();
    }
};

function AbilityTooltip(data, element) {
    var description = $.Localize("AbilityTooltip_" + data.name);
    var bottom = "";

    if (data.cooldown != null){
        if (bottom.length == 0) {
            bottom = "<br/>"
        }

        element.SetDialogVariable("cooldown", data.cooldown.toFixed(1).toString());
        bottom += "<br/>" + $.Localize("AbilityCooldown", element);
    }

    var tableData = (CustomNetTables.GetTableValue("static", "abilities") || {})[data.name] || {};

    if (tableData.damage) {
        if (bottom.length == 0) {
            bottom = "<br/>"
        }

        element.SetDialogVariable("damage", tableData.damage);
        bottom += "<br/>" + $.Localize("AbilityDamage", element);
    }

    if (EndsWith(data.name, "_a")) {
        description = $.Localize("AbilityBasicAttack") + (description.length > 0 ? ("<br/><br/>" + description) : "");
    }

    $.DispatchEvent("DOTAShowTextTooltip", element, description + bottom)
}

function Label(id, cl, text) {
    if (arguments.length < 3) {
        text = cl;
        cl = null;
    }

    if (arguments.length < 2) {
        text = id;
        id = null;
    }

    return { tag: "Label", id: id, class: cl, text: text };
}

function AddEnterListener(name, callback) {
    Game.enterListeners[name] = callback;
}

function TryFetchSteamId(id, avatar) {
    var info = Game.GetPlayerInfo(Number(id));

    if (!info) {
        $.Schedule(0.1, function() {
            TryFetchSteamId(id, avatar);
        });
    } else {
        avatar.steamid = info.player_steamid;
    }
}

function StartsWith(str, searchString) {
    return str.substring(0, searchString.length) === searchString;
}

function FindOrCreate(parent, type, id, cl) {
    if (type == null) {
        type = "Panel";
    }

    if (!Array.isArray(cl)) {
        cl = [ cl ];
    }

    for (var child of parent.Children()) {
        out: {
            if (child.paneltype == type && (!id || child.id == id)) {
                for (var c of cl) {
                    if (cl && !child.BHasClass(c)) {
                        break out;
                    }
                }

                return child;
            }
        }
    }

    var child = $.CreatePanel(type, parent, id || "");

    for (var c of cl) {
        child.AddClass(c);
    }

    return child;
}

$.P = FindOrCreate;

function GetTexture(data, customIcons) {
    var icon = "file://{images}/spellicons/" + (data.texture || data) + ".png";
    var name = data.name;

    if (customIcons && customIcons[name]){
        icon = "file://{images}/custom_game/" + customIcons[name];
    }

    return icon;
}

function CreateRankPanelSmall(parent, rankData, style) {
    var container = $.CreatePanel("Panel", parent, "");

    var rank = $.CreatePanel("Image", container, "");
    rank.AddClass(style);
    rank.SetImage("file://{images}/profile_badges/level_" + (100 - rankData.rank) + ".png");

    if (rankData.rank == 1 && rankData.elo) {
        $.CreatePanelWithProperties("DOTAScenePanel", rank, "", {
            class: "EliteEffect",
            map: "maps/scenes/shining_default.vmap",
        });
    }

    var rankNumber = $.CreatePanel("Label", container, "");
    rankNumber.AddClass("RankLabel");

    if (rankData.rank == 1 && rankData.elo) {
        rankNumber.text = rankData.elo;
        rankNumber.AddClass("EliteText");
    } else {
        rankNumber.text = rankData.rank;
        rankNumber.AddClass("NormalText");
    }

    container.SetPanelEvent("onmouseover", function() {
        var text = $.Localize("RankTip");

        if (rankData.rank == 1 && rankData.elo) {
            text = $.Localize("RankEliteTip");
        }

        $.DispatchEvent("DOTAShowTextTooltip", rank, text);
    });

    container.SetPanelEvent("onmouseout", function() {
        $.DispatchEvent("DOTAHideTextTooltip");
    });

    return container;
}

function UUID(){
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
    });
}

function IsNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function ToColor(num) {
    num >>>= 0;
    var b = num & 0xFF,
        g = (num & 0xFF00) >>> 8,
        r = (num & 0xFF0000) >>> 16,
        a = ( (num & 0xFF000000) >>> 24 ) / 255;
    return "rgba(" + [a, r, g, b].join(",") + ")";
}

function Hash(str) {
    var res = 0;
    var len = str.length;

    for (var i = 0; i < len; i++) {
        res = res * 31 + str.charCodeAt(i);
        res = res & res;
    }

    return res;
}

function LuaColor(color){
    color = color || [0, 128, 128, 128];

    return "rgb(" + [color[1], color[2], color[3]].join(",") + ")";
}

function LuaColorA(color, alpha) {
    color = color || [0, 128, 128, 128];

    return "rgba(" + [color[1], color[2], color[3], alpha].join(",") + ")";
}

function DeleteChildrenWithClass(panel, elClass){
    var elements = panel.FindChildrenWithClassTraverse(elClass);
    for (var i = 0; i < elements.length; i++) {
        elements[i].DeleteAsync(0);
    }
}

function WrapString(str){
    var result = {};
    result[str] = 0;
    return result;
}

function UnwrapString(table){
    var keys = Object.keys(table);
    return keys[0];
}

function SimpleTooltip(target, token) {
    target.onmouseover = function(panel) {
        $.DispatchEvent("DOTAShowTextTooltip", panel, $.Localize(token))
    };

    target.onmouseout = function(){
        $.DispatchEvent("DOTAHideTextTooltip");
    };
}

function AggregateNetTables(keys, callback) {
    var aggregator = function() {
        var result = {};

        for (var key of keys) {
            var value = CustomNetTables.GetTableValue(key.table, key.key);

            if (value) {
                result[key.name || key.key] = value;
            }
        }

        callback(result);
    };

    for (var key of keys) {
        SubscribeToNetTableKey(key.table, key.key, false, aggregator);
    }

    aggregator();

    return aggregator;
}

function SubscribeToNetTableKey(table, key, loadNow, callback){
    var listener = CustomNetTables.SubscribeNetTableListener(table, function(table, tableKey, data){
        if (key == tableKey){
            if (!data) {
                return;
            }

            callback(data, false);
        }
    });

    if (loadNow){
        var data = CustomNetTables.GetTableValue(table, key);

        if (data) {
            callback(data, true);
        }
    }

    return listener;
}

function DelayStateInit(state, callback) {
    var listener = SubscribeToNetTableKey("main", "gameState", true, function(data, immediate) {
        if (data.state == state){
            $.Msg("Delayed init triggered for state " + state);
            if (immediate) {
                $.Schedule(0, function() {
                    CustomNetTables.UnsubscribeNetTableListener(listener);
                });
            } else {
                CustomNetTables.UnsubscribeNetTableListener(listener);
            }
            
            callback();
        }
    });
}

function SwitchClass(element, class1, class2) {
    if (typeof element == "string") {
        element = $(element);
    }

    element.RemoveClass(class1);
    element.AddClass(class2)
}

function Degrees(rad) {
    return rad * (180 / Math.PI);
}

function Clamp(num, min, max) {
  return num < min ? min : num > max ? max : num;
}

function PrintPanelKeys(panel) {
    var keys = Object.keys(panel);
    var def = [
        "paneltype","rememberchildfocus","style","scrolloffset_x","scrolloffset_y","actualyoffset","actualxoffset","actuallayoutheight",
        "actuallayoutwidth","desiredlayoutheight","desiredlayoutwidth","contentheight","contentwidth","layoutfile","id","selectionpos_y","selectionpos_x",
        "tabindex","hittest","inputnamespace","defaultfocus","checked","enabled","visible","IsValid","AddClass","RemoveClass","BHasClass","SetHasClass",
        "ToggleClass","ClearPanelEvent","SetDraggable","IsDraggable","GetChildCount","GetChild","GetChildIndex","Children","FindChildrenWithClassTraverse",
        "GetParent","SetParent","FindChild","FindChildTraverse","FindChildInLayoutFile","RemoveAndDeleteChildren","MoveChildBefore","MoveChildAfter",
        "GetPositionWithinWindow","ApplyStyles","DeleteAsync","BIsTransparent","BAcceptsInput","BAcceptsFocus","SetFocus","BHasHoverStyle","SetAcceptsFocus",
        "SetDisableFocusOnMouseDown","BHasKeyFocus","SetScrollParentToFitWhenFocused","BScrollParentToFitWhenFocused","IsSelected","BHasDescendantKeyFocus",
        "BLoadLayout","BLoadLayoutFromString","LoadLayoutFromStringAsync","LoadLayoutAsync","BCreateChildren","SetTopOfInputContext","SetDialogVariable",
        "SetDialogVariableInt","ScrollToTop","ScrollToBottom","ScrollToLeftEdge","ScrollToRightEdge","ScrollParentToMakePanelFit","BCanSeeInParentScroll",
        "GetAttributeInt","GetAttributeString","GetAttributeUInt32","SetAttributeInt","SetAttributeString","SetAttributeUInt32","SetInputNamespace","data",
        "SetPanelEvent"
    ];

    for (key of def) {
        var index = keys.indexOf(key);

        if (index > -1) {
            keys.splice(index, 1);
        }
    }

    $.Msg(keys);
}

function EndsWith(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

function FindModifier(unit, modifier) {
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier){
            return Entities.GetBuff(unit, i);
        }
    }
}

function HasModifier(unit, modifier) {
    return !!FindModifier(unit, modifier);
}

function GetStackCount(unit, modifier) {
    var m = FindModifier(unit, modifier);
    return m ? Buffs.GetStackCount(unit, m) : 0;
}

function GetRemainingModifierTime(unit, modifier) {
    var m = FindModifier(unit, modifier);
    return m ? Buffs.GetRemainingTime(unit, m) : 0;
}

function GetModifierDuration(unit, modifier) {
    var m = FindModifier(unit, modifier);
    return m ? Buffs.GetDuration(unit, m) : 0;
}

function GetModifierCount(unit, modifier) {
    for (var i = 0, j = 0; i < Entities.GetNumBuffs(unit); i++) {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier){
            j++;
        }
    }

    return j;
}

function GetPlayerOwnerID(unit) {
    return GetStackCount(unit, "modifier_player_id")
}

function CreateScoreboardFromData(players, callback) {
    for (var key in players) {
        players[key].ids = [ players[key].id ];
        players[key].heroes = [ players[key].hero ];
        players[key].names = [ Players.GetPlayerName(players[key].id) ];
    }

    var teams = _(players).groupBy(function(player) { return player.team });

    for (var key in teams){
        var team = teams[key];

        var player = _.reduce(team, function(p1, p2){
            return {
                color: p2.color,
                ids: p1.ids.concat(p2.ids),
                names: p1.names.concat(p2.names),
                heroes: p1.heroes.concat(p2.heroes),
                score: p1.score + p2.score
            };
        }, {
            ids: [],
            heroes: [],
            names: [],
            score: 0
        });

        var data = [];

        for (var index in player.names) {
            data.push({ hero: player.heroes[index], name: player.names[index], id: player.ids[index] });
        }

        callback(LuaColor(player.color), player.score, data, key, player.ids[index]);
    }
}
