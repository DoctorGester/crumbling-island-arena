var scoreboardConnectionStates = {};

function PlayersUpdated(data) {
    var scoreboard = $("#Scoreboard");
    DeleteChildrenWithClass(scoreboard, "ScoreboardTeam");

    scoreboardConnectionStates = {};

    CreateScoreboardFromData(data.players, function(color, score, team) {
        var panel = $.CreatePanel("Panel", scoreboard, "");
        panel.AddClass("ScoreboardTeam");
        panel.style.backgroundColor = color;

        var playersPanel = $.CreatePanel("Panel", panel, "");
        playersPanel.AddClass("ScoreboardPlayers");

        for (var player of team) {
            var playerPanel = $.CreatePanel("Panel", playersPanel, "");
            playerPanel.AddClass("ScoreboardPlayer")

            var hero = $.CreatePanel("DOTAHeroImage", playerPanel, "");
            hero.heroname = player.hero;
            hero.heroimagestyle = "icon";
            hero.AddClass("ScoreboardPlayerHero")
            hero.SetScaling("stretch-to-fit-y-preserve-aspect");

            var namePanel = $.CreatePanel("Panel", playerPanel, "");
            namePanel.AddClass("ScoreboardPlayerNameContainer");

            var playerName = player.name;
            var name = $.CreatePanel("Label", namePanel, "");
            name.AddClass("ScoreboardPlayerName");
            name.text = playerName;

            var connectionStatePanel = $.CreatePanel("Panel", namePanel, "");
            connectionStatePanel.AddClass("ConnectionStatePanel")

            scoreboardConnectionStates[player.id] = connectionStatePanel;
        }

        var scorePanel = $.CreatePanel("Label", panel, "");
        scorePanel.AddClass("ScoreboardTeamScore");
        scorePanel.text = Math.min(data.goal, score).toString();
    });

    UpdateScoreboardConnectionStates();
}

function UpdateScoreboardConnectionStates() {
    for (var id in scoreboardConnectionStates) {
        var panel = scoreboardConnectionStates[id];
        var state = Game.GetPlayerInfo(parseInt(id)).player_connection_state;

        panel.SetHasClass("ConnectionStateDisconnected", state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
        panel.SetHasClass("ConnectionStateAbandoned", state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
        panel.GetParent().SetHasClass("ConnectionStateAbandonedName", state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
    }
}

function ScheduleScoreboardUpdateConnectionStates() {
    $.Schedule(0.1, ScheduleScoreboardUpdateConnectionStates);

    UpdateScoreboardConnectionStates();
}

function GameInfoUpdated(gameInfo) {
    if (gameInfo && gameInfo.goal) {
        var label = $("#ScoreboardGoal");
        label.SetDialogVariableInt("goal", gameInfo.goal);
        label.text = $.Localize("#GameGoal", label);
    }
}

SubscribeToNetTableKey("main", "gameInfo", true, GameInfoUpdated);
SubscribeToNetTableKey("main", "players", true, PlayersUpdated);

ScheduleScoreboardUpdateConnectionStates();