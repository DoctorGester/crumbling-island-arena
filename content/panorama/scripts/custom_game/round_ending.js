function dec2hex(i) {
   return (i+0x10000).toString(16).substr(-4).toUpperCase();
}

function DelayAnimation(delay, panel, from, to) {
    $.Schedule(delay, function() {
        AnimateScoreTo(panel, from, to);
    });
}

function AnimateScoreTo(panel, from, to) {
    panel.text = from.toString();

    if (from < to) {
        $.Schedule(0.05, function() {
            AnimateScoreTo(panel, from + 1, to);
        });
    }
}

function RoundStateChanged(data){
    if (data) {
        var parent = $("#TeamScores");
        var goal = data.goal;
        var players = data.roundData;

        parent.RemoveAndDeleteChildren();

        for (var key in players) {
            players[key].ids = [ players[key].id ];
            players[key].heroes = [ players[key].hero ];
            players[key].names = [ Players.GetPlayerName(players[key].id) ];
        }

        var teams = _(players).groupBy(function(player) { return player.team });
        var teamsGrouped = [];

        for (var key in teams){
            var team = teams[key];

            var player = _.reduce(team, function(p1, p2){
                return {
                    color: p2.color,
                    ids: p1.ids.concat(p2.ids),
                    names: p1.names.concat(p2.names),
                    heroes: p1.heroes.concat(p2.heroes),
                    earned: (p1.earned || 0) + (p2.earned || 0),
                    score: p1.score + p2.score,
                    winner: p2.winner
                };
            }, {
                ids: [],
                heroes: [],
                names: [],
                earned: 0,
                score: 0
            });

            var teamData = [];

            for (var index in player.names) {
                teamData.push({ hero: player.heroes[index], name: player.names[index], id: player.ids[index] });
            }

            teamsGrouped.push({ color: LuaColor(player.color), score: player.score, earned: player.earned, winner: player.winner, id: key, players: teamData });
        }

        teamsGrouped = _(teamsGrouped).sortBy(function(t) { return -t.earned * (t.winner + 1) });

        for (var team of teamsGrouped) {
            var won = false;
            var shownScore = Math.min(team.score, goal);
            
            if (team.score - team.earned >= goal) {
                won = team.winner;
            }

            if (team.score > goal) {
                team.earned = Math.max(0, goal - (team.score - team.earned));
            }

            var name = team.players[0].name;

            if (team.players.length > 1) {
                name = $.Localize(Game.GetTeamDetails(parseInt(team.id)).team_name);
            }

            var teamPanel = $.CreatePanel("Panel", parent, "");
            teamPanel.AddClass("TeamPanel");

            var teamNameAndHeroes = $.CreatePanel("Panel", teamPanel, "");
            teamNameAndHeroes.AddClass("TeamNameAndHeroes");

            var teamNameContainer = $.CreatePanel("Panel", teamNameAndHeroes, "");
            teamNameContainer.AddClass("TeamName");

            var teamName = $.CreatePanel("Label", teamNameContainer, "");
            teamName.text = name;
            teamName.style.color = team.color;

            var teamHeroes = $.CreatePanel("Panel", teamNameAndHeroes, "");
            teamHeroes.AddClass("TeamHeroes");

            for (var player of team.players) {
                var heroIcon = $.CreatePanel("DOTAHeroImage", teamHeroes, "");
                heroIcon.heroname = player.hero;
                heroIcon.heroimagestyle = "icon";
            }

            var score = $.CreatePanel("Label", teamPanel, "");
            score.AddClass("TeamScore");
            score.text = (shownScore - team.earned).toString();

            var earned = $.CreatePanel("Label", teamPanel, "");
            earned.AddClass("TeamEarned");

            if (!won) {
                DelayAnimation(1.5, score, (shownScore - team.earned), shownScore);

                if (shownScore == goal) {
                    earned.AddClass("TeamEarnedGoingToWin");

                    var surviveToWin = $.CreatePanel("Label", teamPanel, "");
                    surviveToWin.AddClass("SurviveToWin");
                    surviveToWin.text = $.Localize("#SurviveToWin");
                }

                earned.text = "+" + team.earned.toString();
            } else {
                earned.AddClass("TeamEarnedWon");
                earned.text = "Win!";
            }
        }

        if (data.firstBlood) {
            var fbPanel = $.CreatePanel("Panel", parent, "");
            fbPanel.AddClass("Award");

            $.CreatePanel("Panel", fbPanel, "").AddClass("FirstBloodIcon");

            var fbText = $.CreatePanel("Label", fbPanel, "");
            fbText.html = true;
            fbText.AddClass("AwardText");

            fbText.SetDialogVariable("name", Players.GetPlayerName(data.firstBlood.id));
            fbText.SetDialogVariable("color", LuaColor(data.firstBlood.color));
            fbText.text = $.Localize("FirstBlood", fbText);

            var fbHero = $.CreatePanel("DOTAHeroImage", fbPanel, "");
            fbHero.heroname = data.firstBlood.hero;
            fbHero.heroimagestyle = "icon";
            fbHero.AddClass("AwardHero");

            var fbScore = $.CreatePanel("Label", fbPanel, "");
            fbScore.AddClass("TeamEarned");
            fbScore.text = "+1";
        }

        if (data.mvp) {
            var mvpPanel = $.CreatePanel("Panel", parent, "");
            mvpPanel.AddClass("Award");

            $.CreatePanel("Panel", mvpPanel, "").AddClass("MvpIcon");

            var mvpText = $.CreatePanel("Label", mvpPanel, "");
            mvpText.html = true;
            mvpText.AddClass("AwardText");

            mvpText.SetDialogVariable("name", Players.GetPlayerName(data.mvp.id));
            mvpText.SetDialogVariable("color", LuaColor(data.mvp.color));
            mvpText.text = $.Localize("MVP", mvpText);

            var mvpHero = $.CreatePanel("DOTAHeroImage", mvpPanel, "");
            mvpHero.heroname = data.mvp.hero;
            mvpHero.heroimagestyle = "icon";
            mvpHero.AddClass("AwardHero");

            var mvpScore = $.CreatePanel("Label", mvpPanel, "");
            mvpScore.AddClass("TeamEarned");
            mvpScore.text = "+1";
        }
    }
}

function GameStateChanged(data){
    var label = $("#RoundResults");

    if (data.state == GAME_STATE_ROUND_ENDED){
        label.style.visibility = "visible";
        SwitchClass(label, "AnimationMessageInvisible", "AnimationMessageVisible");
        Game.EmitSound("UI.RoundOver")

        $.Schedule(1.5, function() {
            Game.EmitSound("UI.RoundScores");
        });
    } else {
        SwitchClass(label, "AnimationMessageVisible", "AnimationMessageInvisible");
    }
}


function GameInfoUpdated(gameInfo) {
    if (gameInfo && gameInfo.goal) {
        var label = $("#GameGoalNumber");
        label.text = gameInfo.goal.toString();
    }
}

DelayStateInit(GAME_STATE_ROUND_ENDED, function () {
    SubscribeToNetTableKey("main", "gameInfo", true, GameInfoUpdated);
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("main", "roundState", true, RoundStateChanged);
});