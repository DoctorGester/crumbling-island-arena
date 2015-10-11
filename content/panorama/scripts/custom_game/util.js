GAME_STATE_NONE = 0
GAME_STATE_HERO_SELECTION = 1
GAME_STATE_ROUND_IN_PROGRESS = 2
GAME_STATE_ROUND_ENDED = 3

function GetTexture(data, customIcons) {
	var icon = "file://{images}/spellicons/" + (data.texture || data) + ".png";
	var name = data.name;

	if (customIcons[name]){
		icon = "file://{images}/custom_game/" + customIcons[name];
	}

	return icon;
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
	return "rgb(" + [color[1], color[2], color[3]].join(",") + ")";
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