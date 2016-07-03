function Vote(event, key, value) {
    var ev = {};
    ev[key] = value;
    GameEvents.SendCustomGameEventToServer(event, ev);
}

function OnTimerTick(args){
    var timers = $.GetContextPanel().FindChildrenWithClassTraverse("VotingTimer");
    Game.EmitSound("UI.TimerTick");

    for (var timer of timers) {
        if (args["time"] != -1) {
            timer.text = args["time"].toString();
        } else {
            timer.text = $.Localize("#GameInfoTimesUp");
        }
    }
}

function TryFetchSteamId(id, avatar) {
    var info = Game.GetPlayerInfo(Number(id));

    if (!info) {
        $.Schedule(0.1, function() {
            TryFetchSteamId(id, avatar);
        });
    } else {
        avatar.steamid = info.player_steamid;
    }
}

function UpdatePlayerVotes(panel, players, key, cl) {
    var votes = panel.FindChildrenWithClassTraverse("PlayerVotes")[0];

    for (var id in players) {
        var player = players[id];
        var playerVotes = votes.playerVotes;

        if (!playerVotes) {
            playerVotes = {};
            votes.playerVotes = playerVotes;
        }

        if (!playerVotes[id]) {
            playerVotes[id] = $.CreatePanel("DOTAAvatarImage", votes, "");
            playerVotes[id].AddClass("PlayerVote");

            TryFetchSteamId(id, playerVotes[id]);

            playerVotes[id].front = $.CreatePanel("Panel", playerVotes[id], "");
            playerVotes[id].front.AddClass("PlayerVoteFront");
        }

        if (player[key] != null) {
            playerVotes[id].front.SetHasClass(cl + player[key], true);
        }
    }
}

function GameSetupChanged(data){
    if (!data) {
        return;
    }

    UpdatePlayerVotes($("#ModeVoteDialog"), data.players, "selectedMode", "PlayerVote");
    UpdatePlayerVotes($("#TeamSelectDialog"), data.players, "selectedTeam", "PlayerVoteTeam");

    if (data.stage == 1) {
        $("#ModeVoteDialog").SetHasClass("HideVotingPanel", true);
        $("#TeamSelectDialog").SetHasClass("VotingPanelHidden", false);
        $("#TeamSelectDialog").SetHasClass("ShowVotingPanel", true);
    }

    if (data.selectedMode) {
        Game.EmitSound("UI.Whoosh");
        $("#ModeSelectHeader").text = $.Localize("GameSetupHeader_" + data.selectedMode);
    }
}

function GameStateChanged(data){
    var gameSetup = $.GetContextPanel();

    if (data.state == GAME_STATE_GAME_SETUP){
        gameSetup.style.visibility = "visible";
        SwitchClass(gameSetup, "AnimationGameSetupInvisible", "AnimationGameSetupVisible");
    } else {
        if (gameSetup.BHasClass("AnimationGameSetupVisible")) {
            Game.EmitSound("UI.SetupEnd");
        }
        
        SwitchClass(gameSetup, "AnimationGameSetupVisible", "AnimationGameSetupInvisible");
    }
}

function AddModeSelectionEvent(button, mode) {
    button.SetPanelEvent("onactivate", function() {
        Vote("setup_mode_select", "mode", mode);
    });
}

function AddTeamSelectionEvent(button, team) {
    button.SetPanelEvent("onactivate", function() {
        Vote("setup_team_select", "team", team);
    });
}

function GameModesChanges(data) {
    var modesPanel = $("#ModeVoteDialog");
    var buttons = modesPanel.FindChildrenWithClassTraverse("VotingButtons")[0];
    buttons.RemoveAndDeleteChildren();

    for (var key in data) {
        var mode = data[key];
        var button = $.CreatePanel("Button", buttons, mode + "Button");
        button.AddClass("VotingButton");

        var label = $.CreatePanel("Label", button, "");
        label.text = $.Localize("#GameSetup" + mode);

        AddModeSelectionEvent(button, mode);
    }
}

function GameTeamsChanges(data) {
    if (!data) {
        return;
    }

    var teamsPanel = $("#TeamSelectDialog");
    var buttons = teamsPanel.FindChildrenWithClassTraverse("VotingButtons")[0];
    var teamNumber = data.teamNumber;

    for (var i = 0; i < teamNumber; i++) {
        var button = $.CreatePanel("Button", buttons, "Team" + (i + 1) + "Button");
        button.AddClass("VotingButton");

        var label = $.CreatePanel("Label", button, "");
        label.text = $.Localize("#GameSetupTeam" + (i + 1));

        AddTeamSelectionEvent(button, i);
    }
}

function RanksChanged(ranks) {
    if (!ranks) {
        return;
    }

    var panel = $("#TeamSelectDialog").FindChildrenWithClassTraverse("PlayerRanks")[0];
    var votes = $("#TeamSelectDialog").FindChildrenWithClassTraverse("PlayerVotes")[0];

    panel.RemoveAndDeleteChildren();

    for (var id in votes.playerVotes) {
        var rank = $.CreatePanel("Image", panel, "");
        rank.AddClass("PlayerRank");
        rank.SetImage("file://{images}/profile_badges/level_" + (99 - ranks[id].rank) + ".png");

        var rankNumber = $.CreatePanel("Label", rank, "");
        rankNumber.text = ranks[id].rank;
    }
}

(function () {
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("gameSetup", "modes", true, GameModesChanges);
    SubscribeToNetTableKey("gameSetup", "teams", true, GameTeamsChanges);
    SubscribeToNetTableKey("gameSetup", "state", true, GameSetupChanged);
    SubscribeToNetTableKey("ranks", "current", true, RanksChanged);
    GameEvents.Subscribe("setup_timer_tick", OnTimerTick);

    //$("#GameSetupChat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);
    //$("#GameSetupChat").RegisterListener("GameSetupEnter");
})();