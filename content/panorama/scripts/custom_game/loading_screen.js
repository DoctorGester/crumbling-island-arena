var hallOfFamePlayers = {
    "FFA_FOUR": 0,
    "DUEL": 1,
    "TWO_TEAMS": 3
};

// BIG THANKS TO VALVE PANORAMA TEAM
function StyleAvatar(avatar, style) {
    for (var property in style) {
        avatar.style[property] = style[property];
    }
}

function StyleAvatarDefault(avatar) {
    StyleAvatar(avatar, {
        width: "100%",
        height: "100%",
    });
}

function HallOfFameChanged(data) {
    if (!data) {
        return;
    }

    var parent = $("#HallOfFamePlayers");

    for (var mode in data) {
        var players = data[mode];

        if (hallOfFamePlayers[mode] == 0) {
            continue;
        }

        for (var i = 0; i < hallOfFamePlayers[mode] && i < players.length; i++) {
            var player = players[i];

            var playerPanel = $.CreatePanel("Panel", $("#RankedTopPlayers"), "");
            playerPanel.AddClass("RankedSeasonCongratulationsPlayer");

            var avatarParent = $.CreatePanel("Panel", playerPanel, "");
            avatarParent.AddClass("RankedSeasonCongratulationsPlayerAvatar");

            var avatar = $.CreatePanel("DOTAAvatarImage", avatarParent, "");
            avatar.steamid = player.steamId64.toString();
            avatar.AddClass("RankedSeasonCongratulationsPlayerAvatar");
            StyleAvatarDefault(avatar);

            var modePanel = $.CreatePanel("Panel", avatarParent, "");
            modePanel.AddClass("RankedMode");

            var modeName = $.CreatePanel("Label", modePanel, "");
            modeName.text = $.Localize("RankMode_" + mode).toUpperCase();
            modeName.AddClass("RankedModeName");

            CreateRankPanelSmall(playerPanel, player, "HallOfFameRank");
        }
    }
}

function UpdateTime(label, seasonEndTime) {
    $.Schedule(1, function() {
        UpdateTime(label, seasonEndTime);
    });

    label.text = moment.unix(seasonEndTime).locale($.Localize("locale")).fromNow();
}

function RankedInfoChanged(info) {
    HallOfFameChanged(info.topPlayers);

    var seasonRewardToShow = info.currentSeason;

    // $("#RankedRewardImage").BLoadLayoutSnippet("reward" + seasonRewardToShow);
    // $("#RankedRewardText").SetDialogVariableInt("season", seasonRewardToShow + 1);
    $("#RankedSeasonEndHeader").SetDialogVariableInt("season", info.currentSeason + 1);

    var parent = $("#RankedSeasonCongratulationsPlayers");

    for (var mode in info.previousTopPlayers) {
        var players = info.previousTopPlayers[mode];

        if (hallOfFamePlayers[mode] == 0) {
            continue;
        }

        for (var i = 0; i < hallOfFamePlayers[mode] && i < players.length; i++) {
            var player = players[i];

            var playerPanel = $.CreatePanel("Panel", parent, "");
            playerPanel.AddClass("RankedSeasonCongratulationsPlayer");

            var avatarParent = $.CreatePanel("Panel", playerPanel, "");
            avatarParent.AddClass("RankedSeasonCongratulationsPlayerAvatar");

            var avatar = $.CreatePanel("DOTAAvatarImage", avatarParent, "");
            avatar.steamid = player.steamId64.toString();
            StyleAvatarDefault(avatar);

            var icon = $.CreatePanel("Panel", playerPanel, "");
            icon.AddClass("TopPlayerIcon");
            icon.AddClass("RankedSeasonCongratulationsPlayerIcon");
        }
    }

    UpdateTime($("#RankedSeasonEndText"), info.seasonEndTime);
    $("#RankedInfoLoading").AddClass("Hidden");
    $("#RankedInfoContainer").RemoveClass("Hidden");
}

function PassTopChanged(top) {
    var players = $("#PassLeaderboards");

    $("#PassInfoLoading").DeleteAsync(0);

    players.RemoveAndDeleteChildren();

    for (var player of top) {
        var avatarParent = $.CreatePanel("Panel", players, "");
        avatarParent.AddClass("PassPlayer");

        var avatar = $.CreatePanel("DOTAAvatarImage", avatarParent, "");
        avatar.steamid = player.steamId64.toString();
        StyleAvatarDefault(avatar);

        avatarParent.BCreateChildren("<DOTAScenePanel class='EliteEffect' hittest='false' map='maps/scenes/vr_theater/vr_background_particle.vmap'/>");

        var level = $.CreatePanel("Label", avatarParent, "");
        level.AddClass("EliteText");
        level.AddClass("RankLabel");
        level.hittest = false;
        level.text = Math.floor(parseInt(player.experience) / 1000) + 1;
    }
}

function ProcessNews() {
    var actualNews = moment({ years: 2017, months: 1, date: 21 }).add(7, "days").isAfter(moment.now());

    $("#PassInfo").SetHasClass("Hidden", actualNews);
    $("#NewsInfo").SetHasClass("Hidden", !actualNews);

    if (actualNews) {
        $("#NewsInfoContainer").RemoveAndDeleteChildren();
        $("#NewsInfoContainer").BLoadLayoutSnippet("arcanaTournament");
    }
}

$.AsyncWebRequest("http://138.68.73.132:3637/ranks/info", { type: "GET", 
    success: function( data ) {
        var info = JSON.parse(data);
        RankedInfoChanged(info);
    }
});

$.AsyncWebRequest("http://138.68.73.132:3637/pass/top", { type: "GET", 
    success: function( data ) {
        var info = JSON.parse(data);
        PassTopChanged(info);
    }
});

var tips = 13;
var tip = Math.floor(Math.random() * (tips + 1));

$("#GameTipText").SetDialogVariable("tip", $.Localize("GameTip" + tip));
$("#GameTipText").text = $.Localize("GameTip", $("#GameTipText"));

var hittestBlocker = $.GetContextPanel().GetParent().FindChild("SidebarAndBattleCupLayoutContainer");

if (hittestBlocker) {
    hittestBlocker.hittest = false;
    hittestBlocker.hittestchildren = false;
}

ProcessNews();

GameEvents.Subscribe("game_rules_state_change", function(data) {
    if (Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD)) {
        $("#PassInfo").SetHasClass("Hidden", true);
        $("#RankedInfo").SetHasClass("Hidden", true);
        $("#GameTip").SetHasClass("Hidden", true);
        $("#NewsInfo").SetHasClass("Hidden", true);
    }
});
