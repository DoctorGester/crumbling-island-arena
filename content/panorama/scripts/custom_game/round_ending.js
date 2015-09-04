function dec2hex(i) {
   return (i+0x10000).toString(16).substr(-4).toUpperCase();
}

function GameInfoUpdated(data){
	var label = $("#ResultMessage");
	if (data.state == GAME_STATE_ROUND_ENDED){
		var winner = data.roundWinner;

		if (winner.id == -1){
			label.text = "round wasted!";
		} else {
			var color = LuaColor(winner.color);
			label.text = "<font color='" + color + "'>" + Players.GetPlayerName(winner.id) + "</font> wins!";
		}
		
		label.style.visibility = "visible";
		AnimatePanel(label, { "opacity": "1.0" }, 0.5);
	} else {
		AnimatePanel(label, { "opacity": "0.0" }, 0.5);
	}
}

(function () {
	SubscribeToNetTableKey("main", "gameInfo", true, GameInfoUpdated);
})();