var scoreboardConnectionStates = {};
var lastScoreboardData = null;

function CreatePlayerStructure(data, color, score, team, teamId, playedId) {
    var survive = data.goal == score && !data.isDeathMatch;
    var diff = Math.abs(data.goal - Math.min(data.goal, score));

    var close = {
        tag: "Label",
        class: [ "ScoreboardScoreClose", survive ? "ScoreboardScoreSurvive" : undefined ],
        dvars: { kills: diff },
        text: survive ? "#Survive" : "#ScoreboardClose"
    };

    var players = [];

    for (var player of team) {
        players.push({
            class: "ScoreboardPlayer",
            children: { tag: "DOTAHeroImage", class: "ScoreboardPlayerHero", heroname: player.hero, heroimagestyle: "icon" }
        });
    }

    var state = Game.GetPlayerInfo(parseInt(playedId)).player_connection_state;
    var dc = state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED;
    var ab = state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED;

    return {
        class: "ScoreboardTeamContainer",
        children: [
            {
                class: "ScoreboardTeam",
                style: { backgroundColor: color },
                children: [
                    { class: "ScoreboardPlayers", children: players },
                    {
                        class: "ScoreboardTeamScoreContainer",
                        children: {
                            tag: "Label",
                            class: [
                                "ScoreboardTeamScore",
                                dc ? "ConnectionStateDisconnected" : undefined,
                                ab ? "ConnectionStateAbandoned" : undefined
                            ],
                            text: Math.min(data.goal, score).toString(),
                            onChange: function(panel, property, value) {
                                panel.SetHasClass("AnimationScoreBoardScoreIncrease", false);
                                panel.SetHasClass("AnimationScoreBoardScoreIncrease", true);
                            }
                        }
                    }
                ]
            },

            diff <= 6 ? close : undefined
        ]
    };
}

function CreateScoreboardStructure(data) {
    var structure = [];

    CreateScoreboardFromData(data.players, function(color, score, team, teamId, playerId) {
        structure.push(CreatePlayerStructure(data, color, score, team, teamId, playerId));
    });

    return structure;
}

function PlayersUpdated(data) {
    Structure.Create($("#Scoreboard"), CreateScoreboardStructure(data));
    $("#VictoryGoal").text = data.goal.toString();

    lastScoreboardData = data;
}

function UpdateScoreboardConnectionStates() {
    if (!!lastScoreboardData) {
        Structure.Create($("#Scoreboard"), CreateScoreboardStructure(lastScoreboardData));
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