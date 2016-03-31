function AddTableHeaders(row, cl) {
    _(arguments).chain().rest(2).each(function(header) {
        var panel = $.CreatePanel("Panel", row, "");
        panel.AddClass(cl);

        var label = $.CreatePanel("Label", panel, "");
        label.AddClass("TableColumnHeaderText");
        label.text = $.Localize(header);
    });
}

function AddTableCell(row, color, callback) {
    var panel = $.CreatePanel("Panel", row, "");
    panel.AddClass("TableCell");
    panel.style.backgroundColor = LuaColorA(color, 200);

    callback(panel);

    return panel;
}

function AddTextCell(row, color, text) {
    return AddTableCell(row, color, function(panel) {
        var label = $.CreatePanel("Label", panel, "");
        label.AddClass("TableCellText");
        label.text = text ? text : "None";
    })
}

function AddNumberCell(row, color, number) {
    AddTextCell(row, color, (number ? number : 0).toString()).AddClass("TableCellNumber");
}

function AddPlayerRow(scoreboard, player, stats, winner, runnerUp) {
    var row = $.CreatePanel("Panel", scoreboard, "");
    row.AddClass("TableRow");
    var color = player.color;

    var amountPlayed = _(stats.playedHeroes).keys().length;
    var mostPlayed = 
        _(stats.playedHeroes)
            .chain()
            .pairs()
            .max(function (arr) {
                return arr[1];
            })
            .value();

    var nameCell = AddTextCell(row, color, Players.GetPlayerName(player.id));
    nameCell.AddClass("TableCellString");
    nameCell.AddClass("TableNameCell");

    if (winner || runnerUp) {
        var icon = $.CreatePanel("Panel", nameCell, "");
        var tooltip = "";
        icon.AddClass("TableIcon");

        if (winner) {
            icon.AddClass("WinnerIcon");
            tooltip = "SbWinner";
        }

        if (runnerUp) {
            icon.AddClass("RunnerUpIcon");
            tooltip = "SbRunnerUp";
        }

        icon.SetPanelEvent("onmouseover", function() {
            $.DispatchEvent("DOTAShowTextTooltip", icon, $.Localize(tooltip));
        });

        icon.SetPanelEvent("onmouseout", function() {
            $.DispatchEvent("DOTAHideTextTooltip");
        });
    }

    AddNumberCell(row, color, player.score);
    AddNumberCell(row, color, stats.damageDealt);
    AddNumberCell(row, color, stats.roundsWon);
    AddNumberCell(row, color, stats.projectilesFired);
    AddNumberCell(row, color, amountPlayed);
    AddTableCell(row, color, function(panel) {
        var img = $.CreatePanel("DOTAHeroImage", panel, "");

        img.AddClass("TableCellText");
        img.heroimagestyle = "icon";
        img.heroname = mostPlayed[0];
    });
}

function AddHeaders(scoreboard) {
    var row = $.CreatePanel("Panel", scoreboard, "");
    row.AddClass("TableRow");
    AddTableHeaders(row, "TableColumnHeaderWide", "SbName");
    AddTableHeaders(row, "TableColumnHeader", "SbScore", "SbDamage", "SbRounds", "SbProj", "SbAmountPlayed", "SbMostPlayed");
}

function AddFooter(scoreboard) {
    var label = $.CreatePanel("Label", scoreboard, "");
    label.AddClass("TableFooter");
    label.text = $.Localize("SbExit");
}

function GameInfoUpdated(gameInfo) {
    var scoreboard = $("#GameOverScoreboard");
    var players = gameInfo.players;
    var stats = gameInfo.statistics;

    var winners = _(gameInfo.runnerUps).values();
    winners.unshift(gameInfo.winner);

    var playerIds = _(players).map(function(k, v) { return parseInt(v) });
    var nonWinners = _(playerIds).without.apply(_(playerIds), winners);
    nonWinners = _(nonWinners).sortBy(function(id) { return players[id].score }).reverse();

    winners.push.apply(winners, nonWinners); // All players combined and sorted

    AddHeaders(scoreboard);

    _(winners).each(function(id) {
        var winner = id == gameInfo.winner;
        var runnerUp = _(gameInfo.runnerUps).values().indexOf(id) != -1;

        AddPlayerRow(scoreboard, players[id.toString()], stats[id.toString()], winner, runnerUp);
    });

    AddFooter(scoreboard);
}

function GameStateChanged(data){
    var scoreboard = $("#GameOverScoreboard");

    if (data.state == GAME_STATE_GAME_OVER){
        scoreboard.style.visibility = "visible";
        SwitchClass(scoreboard, "GameOverScoreboardInvisible", "GameOverScoreboardVisible");
    } else {
        SwitchClass(scoreboard, "GameOverScoreboardVisible", "GameOverScoreboardInvisible");
    }
}

SubscribeToNetTableKey("main", "gameInfo", true, GameInfoUpdated);
SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);