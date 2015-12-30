function PlayersUpdated(players) {
    var scoreboard = $("#Scoreboard");
    DeleteChildrenWithClass(scoreboard, "ScoreboardPlayer");

    for (var key in players){
        var player = players[key];
        var info = Game.GetPlayerInfo(player.id) || {};

        var result = {
            id: player.id,
            score: player.score,
            steamId: info.player_steamid,
            name: Players.GetPlayerName(player.id),
            color: LuaColor(player.color)
        };

        var panel = $.CreatePanel("Panel", scoreboard, "");
        panel.AddClass("ScoreboardPlayer");
        panel.style.backgroundColor = LuaColor(player.color);

        var mouseOver = (function(element, id) {
            return function() {
                $.DispatchEvent("DOTAShowProfileCardTooltip", element, id, false);
            }
        } (panel, player.steamId || 0));

        var mouseOut = function(){
            $.DispatchEvent("DOTAHideProfileCardTooltip");
        }

        panel.SetPanelEvent("onmouseover", mouseOver);
        panel.SetPanelEvent("onmouseout", mouseOut);

        var name = $.CreatePanel("Label", panel, "");
        name.AddClass("ScoreboardPlayerName");
        name.text = Players.GetPlayerName(player.id);

        var score = $.CreatePanel("Label", panel, "");
        score.AddClass("ScoreboardPlayerScore");
        score.text = player.score.toString();
    }
}

(function () {
    SubscribeToNetTableKey("main", "players", true, PlayersUpdated);
})();
$.Msg($("#Scoreboard").GetParent().GetParent().GetParent().GetParent().GetParent().GetParent().GetParent())