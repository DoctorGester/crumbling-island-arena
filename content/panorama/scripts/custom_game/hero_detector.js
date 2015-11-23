var dummy = "npc_dota_hero_wisp";
var heroPanels = {};

function UpdateHeroDetector(){
    $.Schedule(0.025, UpdateHeroDetector);

    var mainPanel = $("#MainPanel");
    var all = Entities.GetAllHeroEntities();
    var notOnScreen = _
        .chain(all)
        .reject(function(entity) {
            return Entities.GetUnitName(entity) == dummy;
        })
        .map(function(entity) {
            var abs = Entities.GetAbsOrigin(entity);
            var x = Game.WorldToScreenX(abs[0], abs[1], abs[2]);
            var y = Game.WorldToScreenY(abs[0], abs[1], abs[2]);

            return { id: entity, x: x, y: y };
        })
        .reject(function(mapped) {
            return mapped.x == -1 || mapped.y == -1;
        })
        .filter(function(mapped) {
            return GameUI.GetScreenWorldPosition(mapped.x, mapped.y) == null;
        })
        .each(function(entity) {
            if (_.has(heroPanels, entity.id)) {
                var panel = heroPanels[entity.id]
                var realW = Clamp(entity.x, 0, mainPanel.actuallayoutwidth - panel.actuallayoutwidth) / mainPanel.actuallayoutwidth;
                var realH = Clamp(entity.y, 0, mainPanel.actuallayoutheight - panel.actuallayoutwidth) / mainPanel.actuallayoutheight;

                panel.style.position = parseInt(realW * 100) + "% " + parseInt(realH * 100) + "% 0px";

                if (!panel.BHasClass("HeroMarkerTransition")) {
                    panel.AddClass("HeroMarkerTransition");
                }
            } else {
                var panel = $.CreatePanel("DOTAHeroImage", mainPanel, "");
                panel.heroname = Entities.GetUnitName(entity.id);
                panel.heroimagestyle = "icon";
                panel.hittest = false;

                heroPanels[entity.id] = panel;
            }
        })
        .value();

    var oldEntities = _.omit(heroPanels, function(value, key) {
        return _.some(notOnScreen, function(entity) { return entity.id == key });
    });

    _.each(oldEntities, function(panel, key) {
        panel.DeleteAsync(0);
        delete heroPanels[key];
    });
}

UpdateHeroDetector();