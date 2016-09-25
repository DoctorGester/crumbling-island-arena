var Structure = new (function(){
    this.structureList = [];
    this.events = [ "onactivate", "onmouseover", "onmouseout" ];
    this.functionKeys = [ "onactivate", "onmouseover", "onmouseout", "onChange" ];

    this.Create = function(parent, structure) {
        var pair = this.FindStructure(parent);

        structure = this.Clone(structure);

        if (!!pair) {
            var differences = odiff(pair[0], structure);

            for (var change of differences) {
                if (change.type === "set") {
                    var result = this.FollowPath(parent, change.path);
                    var property = result[1][0];
                    var remainingPath = result[1].slice(1);
                    var panel = result[0];

                    var originalValuePath = change.path.slice(0, change.path.length - remainingPath.length);
                    var originalValue = this.OriginalValue(pair[0], originalValuePath);
                    var val = change.val;

                    if (!!originalValue && !!val && remainingPath.length > 0) {
                        var current = this.Clone(originalValue);

                        for (var index in remainingPath) {
                            var part = remainingPath[index];

                            if (index < remainingPath.length - 1) {
                                current = current[part];
                            } else {
                                current[part] = val;
                            }
                        }

                        val = current;
                    }

                    var newPanel = this.OriginalValue(structure, change.path.slice(0, change.path.length - remainingPath.length - 1));
                    
                    if (!!newPanel && !!newPanel.onChange) {
                        newPanel.onChange(panel, property, val);
                    }

                    this.SetProperty(panel, property, val, originalValue);
                }

                if (change.type === "rm") {
                    var result = this.FollowPath(parent, change.path);
                    var panel = result[0];
                    var property = result[1][0];
                    var remainingPath = result[1].slice(1);

                    if (property === undefined || property === "children") {
                        for (var i = change.index; i < change.num; i++) {
                            panel.GetChild(i).DeleteAsync(0);
                        }
                    } else {
                        $.Msg(change);
                    }
                }

                if (change.type === "add") {
                    $.Msg(change)
                }
            }

            pair[0] = structure;

            return;
        }

        Structure.CreateStructureInternal(parent, structure);

        pair = [ structure, parent ];
        this.structureList.push(pair);
    }

    this.Clone = function(obj) {
        if (obj === null || typeof obj !== 'object') {
            if (typeof obj === 'function') {
                return obj();
            }

            return obj;
        }
     
        var temp = obj.constructor();
        for (var key in obj) {
            if (this.functionKeys.indexOf(key) !== -1 && typeof obj[key] === 'function') {
                temp[key] = obj[key];
            } else {
                temp[key] = this.Clone(obj[key]);
            }
        }
     
        return temp;
    }

    this.FindStructure = function(parent) {
        for (var pair of this.structureList) {
            if (pair[1] == parent) {
                return pair;
            }
        }
    }

    this.OriginalValue = function(structure, path) {
        var current = structure;

        for (var index of path) {
            current = current[index];
        }

        return current;
    }

    this.FollowPath = function(parent, path) {
        var currentPanel = parent;
        var prevElement = "children";
        var lastIndex = 0;

        for (var index in path) {
            var pathElement = path[index];

            if (prevElement === "children"){
                var inArr = Number.isInteger(pathElement);

                currentPanel = currentPanel.GetChild(inArr ? pathElement : 0);
                lastIndex = parseInt(index) + (inArr ? 1 : 0);
            }

            prevElement = pathElement;
        }

        return [ currentPanel, path.slice(lastIndex) ];
    }

    this.AlwaysArray = function(v) {
        if (!Array.isArray(v)) {
            return v = [ v ];
        }

        return v;
    }

    this.SetProperty = function(panel, property, value, prevValue) {
        if (property == "children") {
            panel.RemoveAndDeleteChildren();

            for (var child of this.AlwaysArray(value)) {
                Structure.CreateStructureInternal(panel, child);
            }

        } else if (property == "class") {
            if (!!prevValue) {
                for (var cls of this.AlwaysArray(prevValue)) {
                    panel.RemoveClass(cls);
                }
            }

            for (var cls of this.AlwaysArray(value)) {
                panel.AddClass(cls);
            }

        } else if (property == "scaling") {
            panel.SetScaling(value);
        } else if (this.events.indexOf(property) !== -1) {
            if (!!prevValue) {
                panel.ClearPanelEvent(property);
            }

            panel.SetPanelEvent(property, function() { value(panel); });
        } else if (property == "style") {
            if (!!prevValue) {
                for (var key in prevValue) {
                    panel.style[key] = undefined;
                }
            }

            for (var key in value) {
                panel.style[key] = value[key];
            }
        } else if (property == "dvars") {
            var dvar = value;

            for (var key in dvar) {
                var val = dvar[key];

                if (!val) {
                    continue;
                }

                if (Number.isInteger(val)) {
                    panel.SetDialogVariableInt(key, val);
                } else {
                    panel.SetDialogVariable(key, val);
                }
            }
        } else {
            if (property === "text" && typeof value === "string" && StartsWith(value, "#")) {
                value = $.Localize(value, panel);
            }

            panel[property] = value;
        }
    }

    this.CreateStructureInternal = function(parent, structure) {
        if (!structure) {
            return;
        }

        if (!Array.isArray(structure)) {
            structure = [ structure ];
        }

        for (var value of structure) {
            if (typeof value === 'object') {
                var panel = null;

                if (!!value.custom && typeof value.custom === "string") {
                    parent.BCreateChildren(value.custom);

                    if (!!value.id && typeof value.id === "string") {
                        panel = parent.FindChild(value.id);
                    }

                    if (panel === null) {
                        continue;
                    }
                } else {
                    panel = $.CreatePanel(value.tag || "Panel", parent, value.id || "");
                }

                for (var key of Object.keys(value)) {
                    Structure.SetProperty(panel, key, value[key]);
                }
            }
        }
    }
 
});