var Pass = new (function(){
    this.QuestsUpdated = function(data) {
        var quests = data[Game.GetLocalPlayerID()];
        var parent = $("#QuestList");
        var structure = [];

        if (!quests) {
            return;
        }

        for (var quest of _.values(quests)) {
            structure.push(Pass.CreateQuestStructure(quest, true));
        }

        Structure.Create(parent, structure);

        var index = 0;

        for (var quest of _.values(quests)) {
            if (quest.isNew == 1 && parent.FindChild("Quest" + quest.id)) {
                Pass.QueueAnimation(2 + index * 0.5, parent.FindChild("Quest" + quest.id));

                index = index + 1;
            }
        }

        if (index > 0) {
            Game.EmitSound("announcer_ann_custom_adventure_alerts_09");
        }
    }

    this.QuestsCompleted = function(quests) {
        var parent = $("#QuestList");
        var structure = [];

        for (var quest of _.values(quests)) {
            structure.push(this.CreateQuestStructure(quest, false));
        }

        Structure.Create(parent, structure);

        var index = 0;

        for (var quest of _.values(quests)) {
            Pass.QueueAnimation(1 + index * 0.5, parent.FindChild("Quest" + quest.id));
            index = index + 1;
        }

        $.Schedule(3, function() {
            for (var quest of _.values(quests)) {
                var panel = parent.FindChild("Quest" + quest.id);
                panel.AddClass("QuestComplete");
            }

            Game.EmitSound("UI.Whoosh")
        });

        $.Schedule(3.6, function() {
            for (var quest of _.values(quests)) {
                var panel = parent.FindChild("Quest" + quest.id);

                panel.SetHasClass("Hidden", true);
            }
        });


        Game.EmitSound("announcer_ann_custom_adventure_alerts_11");
    }

    this.CreateQuestStructure = function(quest, showCompletion) {
        var isCompleted = showCompletion && quest.progress == quest.goal;

        return {
            class: "QuestPanel",
            id: "Quest" + quest.id,
            children: [
                {
                    class: [ "QuestContainer", isCompleted ? "QuestContainerComplete" : undefined ],
                    children: [
                        {
                            id: "QuestPointsScene",
                            custom: "<DOTAScenePanel id='QuestPointsScene' map='maps/scenes/battlepass_ti6_rewardintro.vmap'/>"
                        },
                        {
                            class: "QuestTextContainer",
                            children: {
                                tag: "Label",
                                id: "QuestText",
                                html: true,
                                dvars: {
                                    goal: quest.goal,
                                    hero: quest.hero ? quest.hero.toLowerCase() : null,
                                    shero: quest.secondaryHero ? quest.secondaryHero.toLowerCase() : null
                                },
                                text: "#Quest" + quest.type
                            }
                        },
                        Label("QuestReward", quest.reward),
                        {
                            class: [ "QuestProgressBadge", "Test" ],
                            children: Label("QuestProgress", quest.progress + "/" + quest.goal),
                        }
                    ]
                },
                {
                    class: [ "QuestCompleteOverlay", !isCompleted ? "Hidden" : undefined ]
                }
            ]
        };
    }

    this.QueueAnimation = function(delay, panel) {
        panel.SetHasClass("Hidden", true);

        $.Schedule(delay, function() {
            panel.SetHasClass("Hidden", false);
            panel.AddClass("QuestNew");
        });
    }

    this.ExperienceUpdated = function(data) {
        var exp = data[Game.GetLocalPlayerID()];

        if (!exp && exp !== 0) {
            return;
        }

        Pass.UpdateExperience(exp);
    }

    this.GetExpAndLevel = function(exp) {
        exp = parseInt(exp);

        var experience = exp % 1000;
        var level = Math.floor(exp / 1000);

        return { e: experience, l: level, t: exp };
    }

    this.UpdateExperience = function(exp, expandedLevelText) {
        var e = this.GetExpAndLevel(exp);

        $("#LevelProgress").value = e.e;
        $("#LevelProgressText").text = e.e + "/1000";

        if (expandedLevelText) {
            this.SetLevelText(e.l + 1);
        } else {
            $("#LevelText").text = e.l + 1;
        }
    }

    this.SetLevelText = function(level) {
        $("#LevelText").SetDialogVariableInt("level", level);
        var text = $.Localize("PassLevel", $("#LevelText"));
        $("#LevelText").text = text.toUpperCase();
    }

    this.UpdateRewardImage = function(level, rewardImage, rewardHeroImage) {
        var asset = CustomNetTables.GetTableValue("pass", "cosmetics")[(level + 1).toString()];
        var panel = $(rewardImage);

        $(rewardHeroImage).heroname = "npc_dota_hero_" + asset.hero;
        panel.SetHasClass("RewardItemBorder", !!asset.item);
        panel.SetHasClass("RewardEmote", !!asset.emote);
        panel.SetHasClass("RewardTaunt", !!asset.taunt);

        $.DispatchEvent("DOTAHideTextTooltip");

        if (asset.item && asset.images) {
            var image = asset.images.split(",")[0];
            panel.SetImage("file://{images}/" + image + ".png");
            panel.ClearPanelEvent("onmouseover");
        } else {
            panel.SetImage(null);
            panel.SetPanelEvent("onmouseover", function() {
                $.DispatchEvent("DOTAShowTextTooltip", panel, $.Localize(!!asset.taunt ? "AbilityTooltip_taunt_static" : "AbilityTooltip_emote"));
            });
        }

        return asset;
    }

    this.UpdateExperienceAnimated = function(exp, earned) {
        var from = this.GetExpAndLevel(exp);
        var to = this.GetExpAndLevel(exp + earned);
        var textFunc = function(value) { return value + "/1000"; };
        var label = $("#LevelProgressText");
        var barParent = $("#LevelBar");
        var bar = $("#LevelProgress");

        if (from.l !== to.l) {
            to = { e: 1000, l: from.l + 1 };

            $.Schedule(2, function() {
                var remaining = (exp + earned) % 1000;

                $("#LevelText").SetHasClass("LevelIncrease", false);
                $("#LevelText").SetHasClass("LevelIncrease", true);

                Pass.UpdateRewardImage(to.l, "#NextLevelRewardImage", "#NextLevelRewardHeroImage");

                Pass.AnimateTo(label, 0, remaining, 2.0, textFunc, true);
                barParent.SetHasClass("Animated", false);
                bar.value = 0;

                Game.EmitSound("UI.LevelUp");

                $.Schedule(0, function() {
                    Game.EmitSound("announcer_ann_custom_adventure_alerts_01");

                    barParent.SetHasClass("Animated", true);
                    bar.value = remaining;
                });

                $.Schedule(2, function() {
                    Game.EmitSound("UI.ExpComplete");
                });
            });

            Pass.AnimateTo($("#LevelText"), from.l + 1, from.l + 2, 2.0, function(value) { Pass.SetLevelText(value); });
        } else {
            $.Schedule(2, function() {
                Game.EmitSound("UI.ExpComplete");
            });
        }

        this.AnimateTo(label, from.e, Math.min(to.e, 1000), 2, textFunc, true);
        barParent.SetHasClass("Animated", true);
        bar.value = to.e;
    }

    this.AnimateTo = function(panel, from, to, time, textFunc, withSound, startTime) {
        if (!startTime) {
            startTime = Game.Time();
        }

        var progress = Math.min(1.0, (Game.Time() - startTime) / time);
        var value = from + Math.floor((to - from) * progress);

        if (!!textFunc) {
            var value = textFunc(value);

            if (value) {
                panel.text = value;
            }
        } else {
            panel.text = value.toString();
        }

        if (!!withSound) {
            Game.EmitSound("UI.Exp");
        }
        
        if (progress < 1) {
            $.Schedule(0.05, function() {
                Pass.AnimateTo(panel, from, to, time, textFunc, withSound, startTime);
            });
        }
    }

})();