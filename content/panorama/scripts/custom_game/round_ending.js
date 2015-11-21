function dec2hex(i) {
   return (i+0x10000).toString(16).substr(-4).toUpperCase();
}

function GameInfoUpdated(data){
    var label = $("#ResultMessage");
    if (data.state == GAME_STATE_ROUND_ENDED){
        var winner = data.roundWinner;

        if (winner.id == -1){
            label.text = $.Localize("#RoundEndingWasted");
        } else {
            var color = LuaColor(winner.color);
            label.SetDialogVariable("name", Players.GetPlayerName(winner.id));
            label.SetDialogVariable("color", color);
            label.text = $.Localize("#RoundEnding", label);
        }

        label.style.visibility = "visible";
        SwitchClass(label, "AnimationMessageInvisible", "AnimationMessageVisible");
        Game.EmitSound("UI.RoundOver")
    } else {
        SwitchClass(label, "AnimationMessageVisible", "AnimationMessageInvisible");
    }
}

(function () {
    SubscribeToNetTableKey("main", "gameInfo", true, GameInfoUpdated);
})();