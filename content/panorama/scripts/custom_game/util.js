GAME_STATE_NONE = 0
GAME_STATE_GAME_SETUP = 1
GAME_STATE_HERO_SELECTION = 2
GAME_STATE_ROUND_IN_PROGRESS = 3
GAME_STATE_ROUND_ENDED = 4
GAME_STATE_GAME_OVER = 5

if (!Game.enterListeners) {
    Game.enterListeners = {};
}

Game.OnEnterPressed = function() {
    for (var key in Game.enterListeners) {
        Game.enterListeners[key]();
    }
}

function AddEnterListener(name, callback) {
    Game.enterListeners[name] = callback;
}

function GetTexture(data, customIcons) {
    var icon = "file://{images}/spellicons/" + (data.texture || data) + ".png";
    var name = data.name;

    if (customIcons[name]){
        icon = "file://{images}/custom_game/" + customIcons[name];
    }

    return icon;
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

function SubscribeToNetTableKey(table, key, loadNow, callback){
    CustomNetTables.SubscribeNetTableListener(table, function(table, tableKey, data){
        if (key == tableKey){
            callback(data);
        }
    });

    if (loadNow){
        callback(CustomNetTables.GetTableValue(table, key));
    }
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

function HasModifier(unit, modifier) {
    for (var i = 0; i < Entities.GetNumBuffs(unit); i++) {
        if (Buffs.GetName(unit, Entities.GetBuff(unit, i)) == modifier){
            return true;
        }
    }

    return false;
}