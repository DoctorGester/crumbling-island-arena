function dec2hex(i) {
   return (i+0x10000).toString(16).substr(-4).toUpperCase();
}

function RoundStateChanged(data){
    if (data) {
        var label = $("#ResultMessage");
        var winner = data.roundWinner;
        var winnerAmount = Object.keys(winner).length;

        if (winnerAmount == 0){
            label.text = $.Localize("#RoundEndingWasted");
        } else {
            var first = Object.keys(winner)[0];
            var text = "";

            if (winnerAmount == 1) {
                text = Players.GetPlayerName(winner[first].id)
            } else {
                text = $.Localize(Game.GetTeamDetails(winner[first].team).team_name);
            }

            var color = LuaColor(winner[first].color);
            label.SetDialogVariable("name", text);
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