var NotificationQueue = new (function() {
    this.queue = [];
    this.busy = false;

    this.AddNotification = function(snippetName, callback, data) {
        this.queue.push({ snippet: snippetName, callback: callback, data: data });

        if (!this.busy) {
            this.ShowNextNotification();
        }
    }

    this.ShowNextNotification = function() {
        var notification = this.queue.shift();

        this.busy = true;

        //$("#GameOverBlur").SetHasClass("Blurred", true);
        $("#NotificationArea").SetHasClass("Hidden", false);
        $("#NotificationArea").BLoadLayoutSnippet(notification.snippet);
        notification.callback(notification.data);

        $.Schedule(2, function() {
            $("#NotificationArea").SetPanelEvent("onactivate", function() {
                NotificationQueue.HideNotification();
            });
        })
    }

    this.HideNotification = function() {
        $("#GameOverBlur").SetHasClass("Blurred", false);
        $("#NotificationArea").SetHasClass("Hidden", true);
        $("#NotificationArea").ClearPanelEvent("onactivate");
        $("#NotificationArea").RemoveAndDeleteChildren();

        this.busy = this.queue.length > 0;

        if (this.busy) {
            this.ShowNextNotification();
        } else {
            Game.EmitSound("UI.NotificationClose");
        }
    }
});

function UpdateLabelFromRank(label, rankData) {
    if (rankData.rank == 1 && rankData.elo) {
        label.AddClass("EliteRankLabel");
        label.text = rankData.elo;
    } else {
        label.AddClass("NormalText");
        label.text = rankData.rank;
    }
}

function RankNotification(ranks) {
    var previous = ranks.previous;
    var updated = ranks.updated;

    var lostElo = (updated.elo && previous.elo && updated.elo < previous.elo);

    var rankPanel = $("#RankContainer");
    var newRankPanel = $("#RankNewContainer");

    var elements = $("#RankElements");

    elements.SetHasClass("Hidden", true);

    $.Schedule(0.4, function() {
        Game.EmitSound("UI.RankAppear");
        elements.SetHasClass("Hidden", false);
        elements.RemoveClass("RankOpenAnimationClass");
        elements.AddClass("RankOpenAnimationClass");
    });

    $("#GameOverBlur").AddClass("Blurred");
    $("#Rank").SetImage("file://{images}/profile_badges/level_" + (100 - previous.rank) + ".png");
    rankPanel.SetHasClass("Hidden", false);
    
    $("#RankNew").SetImage("file://{images}/profile_badges/level_" + (100 - updated.rank) + ".png");
    newRankPanel.SetHasClass("Hidden", true);

    UpdateLabelFromRank($("#RankLabel"), previous);
    UpdateLabelFromRank($("#RankLabelNew"), updated);

    $.Schedule(1.8, function() {
        rankPanel.RemoveClass("RankEndAnimationClass");
        rankPanel.AddClass("RankEndAnimationClass");
    });

    $.Schedule(2, function() {
        if (updated.rank > previous.rank || lostElo) {
            Game.EmitSound("UI.RankDecrease");
        } else if (updated.rank > 20) {
            Game.EmitSound("UI.RankLow");
        } else if (updated.rank > 10) {
            Game.EmitSound("UI.RankMedium");
        } else {
            Game.EmitSound("UI.RankHigh");
        }
        
        newRankPanel.SetHasClass("Hidden", false);
        rankPanel.SetHasClass("Hidden", true);
        newRankPanel.RemoveClass("RankAnimationClass");
        newRankPanel.AddClass("RankAnimationClass");

        if (updated.rank <= previous.rank && !lostElo){
            $("#RankEffect").SetHasClass("Hidden", false);
        }
    });
}

function RewardNotification(data) {
    var season = data.season;
    var area = $("#RewardArea");

    const rewardModel = $.CreatePanelWithProperties("DOTAScenePanel", area, "RewardModel", {
        particleonly: "false",
        map: "maps/rewards/" + season + ".vmap",
        light: "light",
        camera: "default"
    });

    area.MoveChildBefore(rewardModel, $("#RewardTip"));
    area.SetHasClass("RewardHidden", true);

    Game.EmitSound("UI.PreRewardReceived");

    $.Schedule(2.0, function() {
        Game.EmitSound("UI.RewardReceived");

        area.SetHasClass("RewardHidden", false);
        area.RemoveClass("RankOpenAnimationClass");
        area.AddClass("RankOpenAnimationClass");
    });
}

function PassRewardNotification(data) {
    var season = data.season;
    var area = $("#RewardArea");
    area.SetHasClass("RewardHidden", true);

    Game.EmitSound("UI.PassRewardReceived");

    $.Schedule(0.3, function() {
        var asset = Pass.UpdateRewardImage(data.level - 1, "#PassRewardImage", "#PassRewardHeroImage");

        if (!asset) {
            return;
        }

        area.SetHasClass("RewardHidden", false);
        area.RemoveClass("RankOpenAnimationClass");
        area.AddClass("RankOpenAnimationClass");

        if (!!asset.emote) {
            $.Schedule(1.2, function() {
                Game.EmitSound(asset.hero);
            });
        }
    });
}

function PassNotification(results) {
    results = results.results;

    var area = $("#PassNotification");

    area.RemoveClass("RankOpenAnimationClass");
    area.AddClass("RankOpenAnimationClass");

    Game.EmitSound("UI.RankAppear");

    if (results.experience || results.experience === 0) {
        Pass.UpdateExperience(results.experience, true);
        var asset = Pass.UpdateRewardImage(Pass.GetExpAndLevel(results.experience).l, "#NextLevelRewardImage", "#NextLevelRewardHeroImage");

        $("#NextLevelReward").SetHasClass("Hidden", !asset);

        var to = Pass.GetExpAndLevel(results.experience + (results.earnedExperience || 0));

        if (Pass.GetExpAndLevel(results.experience).l < to.l && asset) {
            NotificationQueue.AddNotification("PassRewardNotification", PassRewardNotification, { level: to.l });
        }
    }

    $.Schedule(0.5, function() {
        if (results.completedQuests) {
            Pass.QuestsCompleted(results.completedQuests);
        }

        if (results.experience || results.experience === 0) {
            $.Schedule(results.completedQuests ? 3 : 1.5, function() {
                Pass.UpdateExperienceAnimated(results.experience, results.earnedExperience);
            });
        }
    });
}