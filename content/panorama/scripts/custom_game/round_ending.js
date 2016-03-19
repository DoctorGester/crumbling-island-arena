function dec2hex(i) {
   return (i+0x10000).toString(16).substr(-4).toUpperCase();
}

function RoundStateChanged(data){
    if (data) {
        var label = $("#ResultMessage");
        var winner = data.roundWinner;

        if (winner.id == -1){
            label.text = $.Localize("#RoundEndingWasted");
        } else {
            var color = LuaColor(winner.color);
            label.SetDialogVariable("name", Players.GetPlayerName(winner.id));
            label.SetDialogVariable("color", color);
            label.text = $.Localize("#RoundEnding", label);
        }
    }
}

function GameStateChanged(data){
    var label = $("#ResultMessage");

    if (data.state == GAME_STATE_ROUND_ENDED){
        label.style.visibility = "visible";
        SwitchClass(label, "AnimationMessageInvisible", "AnimationMessageVisible");
        Game.EmitSound("UI.RoundOver")
    } else {
        SwitchClass(label, "AnimationMessageVisible", "AnimationMessageInvisible");
    }
}

(function () {
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("main", "roundState", true, RoundStateChanged);
})();