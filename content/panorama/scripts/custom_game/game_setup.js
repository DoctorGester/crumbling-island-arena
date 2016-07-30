var playerToggles = {};
var playerRanks = {};
var banButtons = {};

var stagePanels = {
    stage_mode: "ModeVoteDialog",
    stage_team: "TeamSelectDialog",
    stage_bans: "BansDialog"
};

var lastStage = "stage_mode";

function OnTimerTick(args){
    var timers = $.GetContextPanel().FindChildrenWithClassTraverse("VotingTimer");

    for (var timer of timers) {
        if (args["time"] != -1) {
            timer.text = args["time"].toString();
            Game.EmitSound("UI.TimerTick");
        } else {
            timer.text = $.Localize("#GameInfoTimesUp");
        }
    }
}

function ModeVotesChanged(players) {
    players = players.inputs;

    var panel = $("#ModeVoteDialog");

    var votes = panel.FindChildrenWithClassTraverse("PlayerVotes")[0];

    for (var index in players) {
        var player = players[index];
        var id = player.id;
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

        if (player.input != null) {
            playerVotes[id].front.SetHasClass("PlayerVote" + player.input, true);
        }
    }
}

function GameSetupChanged(data){
    var newStage = data.stage;

    if (newStage != lastStage && newStage) {
        $.Msg(lastStage + "->" + newStage);
        $("#" + stagePanels[lastStage]).SetHasClass("ShowVotingPanel", false);
        $("#" + stagePanels[lastStage]).SetHasClass("HideVotingPanel", true);
        $("#" + stagePanels[newStage]).SetHasClass("VotingPanelHidden", false);
        $("#" + stagePanels[newStage]).SetHasClass("ShowVotingPanel", true);

        lastStage = newStage;

        Game.EmitSound("UI.Whoosh");
    }

    var stageMode = data.outputs.stage_mode;

    if (stageMode && stageMode.selectedMode) {
        $("#ModeSelectHeader").text = $.Localize("GameSetupHeader_" + stageMode.selectedMode);
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
        GameEvents.SendCustomGameEventToServer("stage_mode", { input: mode });
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

function AddTeammateSelectionEvent(toggle) {
    toggle.SetPanelEvent("onactivate", function() {
        var selectedPlayers = [];

        for (var id in playerToggles) {
            if (playerToggles[id].checked) {
                selectedPlayers.push(id);
            }
        }

        GameEvents.SendCustomGameEventToServer("stage_team", { input: selectedPlayers });
    });
}

function TeamsChanged(data) {
    data = data.inputs;

    var buttonParent = $("#TeamSelectionButtons");

    for (var key in data) {
        var player = data[key];

        if (player.id != Game.GetLocalPlayerID()) {
            if (!playerToggles[player.id]) {
                var parent = $.CreatePanel("Panel", buttonParent, "");
                parent.AddClass("TeamSelectionPanel");

                var rank = $.CreatePanel("Panel", parent, "");
                rank.AddClass("TeamSelectionRankContainer");

                playerRanks[player.id] = rank;

                var avatar = $.CreatePanel("DOTAAvatarImage", parent, "");
                avatar.AddClass("TeamSelectionAvatar");

                TryFetchSteamId(player.id, avatar);

                var name = $.CreatePanel("Label", parent, "");
                name.AddClass("TeamSelectionName");
                name.text = Players.GetPlayerName(player.id);

                var toggle = $.CreatePanel("ToggleButton", parent, "");

                playerToggles[player.id] = toggle;

                AddTeammateSelectionEvent(toggle);
            } else {
                playerToggles[player.id].checked = false;
            }
        }
    }

    var checked = 0;

    for (var key in data) {
        var player = data[key];

        if (player.id == Game.GetLocalPlayerID()) {
            if (player.input) {
                for (var index in player.input) {
                    var id = player.input[index];

                    if (playerToggles[id]) {
                        playerToggles[id].checked = true;
                        checked++;
                    }
                }
            }
        }
    }

    var state = CustomNetTables.GetTableValue("gameSetup", "state");

    if (state && state.outputs.stage_mode) {
        for (var k in playerToggles) {
            var toggle = playerToggles[k];

            if (checked + 1 >= state.outputs.stage_mode.playersInTeam) {
                toggle.enabled = toggle.checked
            } else {
                toggle.enabled = true;
            }
        }
    }
}

function RanksChanged(ranks) {
    for (var k in playerRanks) {
        if (ranks[k]) {
            playerRanks[k].RemoveAndDeleteChildren();

            CreateRankPanelSmall(playerRanks[k], ranks[k], "PlayerRank");
        }
    }
}

function MiscInfoChanged(data) {
    var labels = $.GetContextPanel().FindChildrenWithClassTraverse("MatchModeHeader");

    if (data.rankedMode != null){
        for (var label of labels) {
            label.text = $.Localize("#Ranked");
        }

        for (var k in playerRanks) {
            if (playerRanks[k].Children().length == 0) {
                var loading = $.CreatePanel("Panel", playerRanks[k], "");
                loading.AddClass("LoadingImage");
            }
        }
    } else {
        for (var k in playerRanks) {
            playerRanks[k].AddClass("Hidden");
        }
    }
}

function AddBanEvent(button, ban) {
    button.SetPanelEvent("onactivate", function() {
        GameEvents.SendCustomGameEventToServer("stage_bans", { input: ban });
    });
}

function HeroesChanged(heroes) {
    var panel = $("#BanButtons");
    var heroNames = Object.keys(heroes);

    heroNames = _(heroNames).sortBy(function(hero) { return heroes[hero].order });

    for (var hero of heroNames) {
        var data = heroes[hero];

        if (data.disabled) {
            continue;
        }

        var button = $.CreatePanel("DOTAHeroImage", panel, "");
        button.heroname = hero;
        button.AddClass("BanButton");
        button.SetScaling("stretch-to-fit-x-preserve-aspect");

        AddBanEvent(button, hero);

        banButtons[hero] = button;
    }
}

function BansChanged(bans) {
    bans = bans.inputs;

    var localTeam = Game.GetPlayerInfo(Game.GetLocalPlayerID()).player_team_id;

    for (var index in bans) {
        var player = bans[index];
        var team = Game.GetPlayerInfo(player.id).player_team_id;

        if (player.input && team == localTeam) {
            banButtons[player.input].enabled = false;
        }
    }
}

(function () {
    SubscribeToNetTableKey("main", "heroes", true, HeroesChanged);

    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("gameSetup", "modes", true, GameModesChanges);
    SubscribeToNetTableKey("gameSetup", "stage_mode", true, ModeVotesChanged);
    SubscribeToNetTableKey("gameSetup", "stage_team", true, TeamsChanged);
    SubscribeToNetTableKey("gameSetup", "stage_bans", true, BansChanged);

    SubscribeToNetTableKey("gameSetup", "state", true, GameSetupChanged);
    SubscribeToNetTableKey("gameSetup", "misc", true, MiscInfoChanged);
    SubscribeToNetTableKey("ranks", "current", true, RanksChanged);

    GameEvents.Subscribe("setup_timer_tick", OnTimerTick);
    //$("#GameSetupChat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);
    //$("#GameSetupChat").RegisterListener("GameSetupEnter");
})();