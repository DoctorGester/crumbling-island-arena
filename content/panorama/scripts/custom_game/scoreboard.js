var scoreboardConnectionStates = {};

function PlayersUpdated(data) {
    var scoreboard = $("#Scoreboard");
    scoreboardConnectionStates = {};

    CreateScoreboardFromData(data.players, function(color, score, team, teamId) {
        var teamParent = $.P(scoreboard, null, "T" + teamId.toString(), "ScoreboardTeamContainer");
        var panel = $.P(teamParent, null, null, "ScoreboardTeam");
        panel.style.backgroundColor = color;

        var playersPanel = $.P(panel, null, null, "ScoreboardPlayers");

        for (var player of team) {
            var playerPanel = $.P(playersPanel, null, player.id, "ScoreboardPlayer");
            var hero = $.P(playerPanel, "DOTAHeroImage", null, "ScoreboardPlayerHero");
            hero.heroname = player.hero;
            hero.heroimagestyle = "icon";
            hero.SetScaling("stretch-to-fit-y-preserve-aspect");

            var connectionStatePanel = $.P(playerPanel, "Panel", null, "ConnectionStatePanel");

            scoreboardConnectionStates[player.id] = connectionStatePanel;
        }

        var scoreContainer = $.P(panel, "Panel", null, "ScoreboardTeamScoreContainer");
        var scorePanel = $.P(scoreContainer, "Label", null, "ScoreboardTeamScore");
        var prevText = scorePanel.text;
        scorePanel.text = Math.min(data.goal, score).toString();

        var diff = Math.abs(data.goal - score);

        if (diff < 5) {
            var close = $.P(teamParent, "Label", null, "ScoreboardScoreClose");
            close.SetDialogVariableInt("kills", diff);
            close.text = $.Localize("ScoreboardClose", close);
        }

        if (prevText != scorePanel.text) {
            scorePanel.SetHasClass("AnimationScoreBoardScoreIncrease", false);
            scorePanel.SetHasClass("AnimationScoreBoardScoreIncrease", true);
        }
    });

    $("#VictoryGoal").text = data.goal.toString();

    UpdateScoreboardConnectionStates();
}

function UpdateScoreboardConnectionStates() {
    for (var id in scoreboardConnectionStates) {
        var panel = scoreboardConnectionStates[id];
        var state = Game.GetPlayerInfo(parseInt(id)).player_connection_state;

        panel.SetHasClass("ConnectionStateDisconnected", state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
        panel.SetHasClass("ConnectionStateAbandoned", state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
    }
}

function ScheduleScoreboardUpdateConnectionStates() {
    $.Schedule(0.1, ScheduleScoreboardUpdateConnectionStates);

    UpdateScoreboardConnectionStates();
}

DelayStateInit(GAME_STATE_ROUND_IN_PROGRESS, function () {
    SubscribeToNetTableKey("main", "players", true, PlayersUpdated);

    ScheduleScoreboardUpdateConnectionStates();
});