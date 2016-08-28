(function() {
    function PlayersUpdated(data) {
        var parent = $("#MatchResults");
        var goal = data.goal;

        var players = _.sortBy(data.players, function(pl) { return pl.score });
        var index = 2;

        for (var player of players) {
            var playerPanel = $.P(parent, null, player.id.toString(), "PlayerPanel");
            var scorePanel = $.P(playerPanel, null, null, "ScorePanel");
            var scoreLabel = $.P(scorePanel, "Label");

            playerPanel.AddClass("Hidden");

            $.Schedule(index * 0.6, (function(playerPanel) {
                return function() {
                    playerPanel.SetHasClass("Hidden", false);
                    playerPanel.SetHasClass("PlayerPanelIn", true);

                    $.Schedule(0.2, function() {
                        Game.EmitSound("UI.DeathMatchScoreIn");
                    })
                }
            })(playerPanel));

            scoreLabel.text = player.score.toString();

            var playerName = $.P(playerPanel, "Label", null, "NamePanel");
            playerName.text = Players.GetPlayerName(player.id);
            playerName.style.color = LuaColor(player.color);

            if (goal == player.score) {
                $.Schedule(index * 0.6 + 0.8, function() {
                    playerName.SetHasClass("PlayerPanelVictory", true);
                    Game.EmitSound("UI.DeathMatchScoreWin");
                });


                scorePanel.SetHasClass("ScoreWon", true);
            }

            index++;
        }
    }

    DelayStateInit(GAME_STATE_GAME_OVER_DM, function () {
        SubscribeToNetTableKey("main", "players", true, PlayersUpdated);
    });
})();