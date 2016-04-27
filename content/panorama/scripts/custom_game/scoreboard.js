function PlayersUpdated(players) {
    var scoreboard = $("#Scoreboard");
    DeleteChildrenWithClass(scoreboard, "ScoreboardPlayer");

    for (var key in players) {
        players[key].name = [ Players.GetPlayerName(players[key].id) ];
    }

    var teams = _(players).groupBy(function(player) { return player.team });

    for (var key in teams){
        var team = teams[key];

        var player = _.reduce(team, function(p1, p2){
            return {
                color: p2.color,
                names: p1.name.concat(p2.name),
                score: p1.score + p2.score
            };
        });

        var panel = $.CreatePanel("Panel", scoreboard, "");
        panel.AddClass("ScoreboardPlayer");
        panel.style.backgroundColor = LuaColor(player.color);

        var names = player.names || player.name;
        for (var index in names) {
            var playerName = names[index];
            var name = $.CreatePanel("Label", panel, "");
            name.AddClass("ScoreboardPlayerName");
            name.text = playerName;
        }

        var score = $.CreatePanel("Label", panel, "");
        score.AddClass("ScoreboardPlayerScore");
        score.text = player.score.toString();
    }
}

function GameInfoUpdated(gameInfo) {
    if (gameInfo && gameInfo.goal) {
        var label = $("#ScoreboardGoal");
        label.SetDialogVariableInt("goal", gameInfo.goal);
        label.text = $.Localize("#GameGoal", label);
    }
}

SubscribeToNetTableKey("main", "players", true, PlayersUpdated);
SubscribeToNetTableKey("main", "gameInfo", true, GameInfoUpdated);