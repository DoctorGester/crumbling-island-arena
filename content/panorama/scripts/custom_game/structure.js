var Structure = new (function(){
    this.structures = new Map();
    this.events = [ "onactivate", "onmouseover", "onmouseout" ];
    this.functionKeys = [ "onactivate", "onmouseover", "onmouseout", "onChange" ];
    this.structurePanelMap = new Map();
    this.localizeTargetMap = new Map();

    this.Create = function(parent, structure) {
        var oldStructure = this.structures.get(parent);

        structure = this.Clone(structure);

        if (!!oldStructure) {
            // It just works :)
            var differences = odiff(oldStructure, structure);

            for (var change of differences.reverse()) {
                var result = this.FollowPath(oldStructure, change.path);
                var property = result[1][0];
                var remainingPath = result[1].slice(1);
                var structurePanel = result[0];
                var panel = this.structurePanelMap.get(structurePanel);

                var originalValuePath = change.path.slice(0, change.path.length - remainingPath.length);
                var originalValue = this.OriginalValue(oldStructure, originalValuePath);

                var parentPath = change.path.slice(0, change.path.length - remainingPath.length - 1);
                var parentStruct = this.FollowPath(oldStructure, parentPath)[0];
                var parentPanel;

                if (parentStruct == oldStructure) {
                    parentStruct = { children: parentStruct };
                    parentPanel = parent;
                } else {
                    parentPanel = this.structurePanelMap.get(parentStruct);
                }

                if (change.type === "set") {
                    var val = change.val;

                    if (property === undefined || property === "children") {
                        var index = change.path[change.path.length - 1];
                        var p = this.structurePanelMap.get(parentStruct.children[index]);
                        this.structurePanelMap.delete(parentStruct.children[index]);
                        this.localizeTargetMap.delete(p);

                        parentStruct.children[index] = val;

                        Structure.CreateStructureInternal(parentPanel, val, p);
                        p.DeleteAsync(0);
                    } else {
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

                        structurePanel[property] = val;
                    }
                }

                if (change.type === "rm") {
                    if (property === undefined || property === "children") {
                        for (var i = change.index; i < change.index + change.num; i++) {
                            var p = this.structurePanelMap.get(structurePanel.children[i]);
                            p.DeleteAsync(0);

                            this.structurePanelMap.delete(parentStruct.children[i]);
                            this.localizeTargetMap.delete(p);
                        }

                        structurePanel.children.splice(change.index, change.num);
                    } else {
                        var newValue = this.OriginalValue(structure, originalValuePath);

                        this.SetProperty(panel, property, newValue, originalValue);

                        delete structurePanel[property];
                    }
                }

                if (change.type === "add") {
                    if (property === undefined || property === "children") {
                        var parent = this.structurePanelMap.get(structurePanel);
                        var atIndex = structurePanel.children.length > change.index ? this.structurePanelMap.get(structurePanel.children[change.index]) : null;

                        for (var val of change.vals) {
                            Structure.CreateStructureInternal(parent, val, atIndex);
                        }

                        structurePanel.children.splice.apply(structurePanel.children, [change.index, 0].concat(change.vals));
                    } else {
                        var newValue = this.OriginalValue(structure, originalValuePath);

                        this.SetProperty(panel, property, newValue, originalValue);

                        structurePanel[property] = newValue;
                    }
                }
            }

            return;
        }

        Structure.CreateStructureInternal(parent, structure);
        this.structures.set(parent, structure);
    }

    this.Clone = function(obj) {
        if (Array.isArray(obj)) {
            obj = _.compact(obj);
        }

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
            } else if (key == "children") {
                temp[key] = this.AlwaysArray(this.Clone(obj[key]));
            } else {
                temp[key] = this.Clone(obj[key]);
            }
        }
     
        return temp;
    }

    this.OriginalValue = function(structure, path) {
        var current = structure;

        for (var index of path) {
            current = current[index];
        }

        return current;
    }

    this.FollowPath = function(structure, path) {
        var current = structure;
        var prevElement = "children";
        var lastIndex = 0;
        var lastPanel = structure;

        for (var index in path) {
            var pathElement = path[index];

            if (prevElement === "children"){
                var inArr = Number.isInteger(pathElement);

                lastPanel = inArr ? current[pathElement] : current;
                lastIndex = parseInt(index) + (inArr ? 1 : 0);
            }

            current = current[pathElement];

            prevElement = pathElement;
        }

        return [ lastPanel, path.slice(lastIndex) ];
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
                if (cls) {
                    panel.AddClass(cls);
                }
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
                    panel.style[key] = null;
                }
            }

            for (var key in value) {
                panel.style[key] = value[key];
            }
        } else if (property == "dvars") {
            var dvar = value;

            for (var key in dvar) {
                var val = dvar[key];

                if (Number.isInteger(val)) {
                    panel.SetDialogVariableInt(key, val);
                } else {
                    panel.SetDialogVariable(key, val);
                }

                var txt = this.localizeTargetMap.get(panel);

                if (txt) {
                    panel.text = $.Localize(txt, panel);
                }
            }
        } else {
            if (property === "text" && typeof value === "string" && StartsWith(value, "#")) {
                this.localizeTargetMap.set(panel, value);
                value = $.Localize(value, panel);
            }

            panel[property] = value;
        }
    }

    this.CreateStructureInternal = function(parent, structure, insertBefore) {
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

                this.structurePanelMap.set(value, panel);

                if (!!insertBefore) {
                    parent.MoveChildBefore(panel, insertBefore);
                }

                for (var key of Object.keys(value)) {
                    Structure.SetProperty(panel, key, value[key]);
                }
            }
        }
    }
 
});