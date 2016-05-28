var scoreboardConnectionStates = {};

function PlayersUpdated(players) {
    var scoreboard = $("#Scoreboard");
    DeleteChildrenWithClass(scoreboard, "ScoreboardTeam");

    scoreboardConnectionStates = {};

    for (var key in players) {
        players[key].ids = [ players[key].id ];
        players[key].heroes = [ players[key].hero ];
        players[key].names = [ Players.GetPlayerName(players[key].id) ];
    }

    var teams = _(players).groupBy(function(player) { return player.team });

    for (var key in teams){
        var team = teams[key];

        var player = _.reduce(team, function(p1, p2){
            return {
                color: p2.color,
                ids: p1.ids.concat(p2.ids),
                names: p1.names.concat(p2.names),
                heroes: p1.heroes.concat(p2.heroes),
                score: p1.score + p2.score
            };
        }, {
            ids: [],
            heroes: [],
            names: [],
            score: 0
        });

        var panel = $.CreatePanel("Panel", scoreboard, "");
        panel.AddClass("ScoreboardTeam");
        panel.style.backgroundColor = LuaColor(player.color);

        var playersPanel = $.CreatePanel("Panel", panel, "");
        playersPanel.AddClass("ScoreboardPlayers");

        for (var index in player.names) {
            var playerPanel = $.CreatePanel("Panel", playersPanel, "");
            playerPanel.AddClass("ScoreboardPlayer")

            var hero = $.CreatePanel("DOTAHeroImage", playerPanel, "");
            hero.heroname = "npc_dota_" + player.heroes[index];
            hero.heroimagestyle = "icon";
            hero.AddClass("ScoreboardPlayerHero")
            hero.SetScaling("stretch-to-fit-y-preserve-aspect");

            var namePanel = $.CreatePanel("Panel", playerPanel, "");
            namePanel.AddClass("ScoreboardPlayerNameContainer");

            var playerName = player.names[index];
            var name = $.CreatePanel("Label", namePanel, "");
            name.AddClass("ScoreboardPlayerName");
            name.text = playerName;

            var connectionStatePanel = $.CreatePanel("Panel", namePanel, "");
            connectionStatePanel.AddClass("ConnectionStatePanel")

            scoreboardConnectionStates[player.ids[index]] = connectionStatePanel;
        }

        var score = $.CreatePanel("Label", panel, "");
        score.AddClass("ScoreboardTeamScore");
        score.text = player.score.toString();
    }

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

SubscribeToNetTableKey("main", "players", true, PlayersUpdated);
SubscribeToNetTableKey("main", "gameInfo", true, GameInfoUpdated);

ScheduleScoreboardUpdateConnectionStates();