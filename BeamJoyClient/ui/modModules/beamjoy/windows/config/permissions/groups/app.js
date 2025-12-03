angular.module("beamjoy").component("bjConfigPermissionsGroups", {
    templateUrl:
        "/ui/modModules/beamjoy/windows/config/permissions/groups/app.html",
    controller: function ($rootScope, beamjoyStore, $timeout, $filter) {
        const translate = $filter("translate");
        this.selfGroupIndex = 0;
        this.default = [];
        this.groups = [];
        this.protectedGroups = [];
        this.labels = {};
        this.dirty = false;
        this.valid = true;
        this.errors = {};
        const getPermissions = () => {
            return Object.keys(beamjoyStore.permissions.data).sort();
        };
        const parseGroups = (groups) => {
            const permissions = getPermissions();
            return groups.map((g) => {
                const readonly = ["default", "owner"].includes(g.name);
                const readOnlyPermissions = g.name === "owner";
                if (!Array.isArray(g.permissions)) g.permissions = [];
                const group = Object.assign(
                    {
                        readonly: readonly,
                        newPermission: readOnlyPermissions ? null : "",
                        permissionOptions: readOnlyPermissions
                            ? null
                            : permissions
                                  .filter((p) => !g.permissions.includes(p))
                                  .map((p) => ({ value: p, label: p })),
                    },
                    g
                );
                if (Array.isArray(g.nameColor)) {
                    Object.assign(group, {
                        nameColor: beamjoyStore.utils.rgbToHex({
                            r: g.nameColor[0] || 1,
                            g: g.nameColor[1] || 1,
                            b: g.nameColor[2] || 1,
                        }),
                    });
                }
                if (Array.isArray(g.textColor)) {
                    Object.assign(group, {
                        textColor: beamjoyStore.utils.rgbToHex({
                            r: g.textColor[0] || 1,
                            g: g.textColor[1] || 1,
                            b: g.textColor[2] || 1,
                        }),
                    });
                }
                group.canDelete = !this.protectedGroups.includes(g.name);
                return group;
            });
        };

        let skipWatch = false;
        const updateDirtyAndValid = () => {
            if (skipWatch) return;
            const parse = (g) => {
                delete g.readonly;
                delete g.permissionOptions;
                delete g.newPermission;
                delete g.canDelete;
                return g;
            };
            const defaultGroups = angular.copy(this.default).map(parse);
            const groups = angular.copy(this.groups).map(parse);
            this.dirty = !angular.equals(groups, defaultGroups);
            this.errors = this.groups.reduce((acc, g) => {
                acc[g.name] = {};
                if (typeof g.vehicleCap !== "number" || g.vehicleCap < -1) {
                    acc[g.name].vehicleCap = true;
                }
                acc[g.name].total = Object.entries(acc[g.name]).length;
                return acc;
            }, {});
            this.valid = Object.values(this.errors).every((e) => e.total === 0);
        };

        const updateLabels = () => {
            this.labels = [];
            this.groups.forEach((g) => {
                const label = translate("beamjoy.groups." + g.name);
                if (label && label !== "beamjoy.groups." + g.name) {
                    this.labels[g.name] = label;
                } else {
                    this.labels[g.name] = g.name;
                }
            });
        };

        const updateData = () => {
            this.selfGroupIndex = beamjoyStore.groups.getGroupIndex(
                beamjoyStore.players.self.group
            );
            this.protectedGroups = angular.copy(
                beamjoyStore.groups.defaultGroups
            );
            this.default = parseGroups(angular.copy(beamjoyStore.groups.data));
            if (!this.dirty) {
                this.groups = angular.copy(this.default);
            }
            updateLabels();
            updateDirtyAndValid();
        };

        updateData();
        $rootScope.$watch(
            () => this.groups,
            () => {
                this.groups = parseGroups(this.groups);
                updateLabels();
                updateDirtyAndValid();
            },
            true
        );

        ["BJUpdateGroups", "BJUpdatePermissions", "BJUpdateSelf"].forEach(
            (eventName) => {
                $rootScope.$on(eventName, updateData);
            }
        );

        this.removeGroup = (evt, group) => {
            evt.stopPropagation();
            if (!this.protectedGroups.includes(group)) {
                this.groups = this.groups.filter((g) => g.name !== group);
            }
        };
        this.removePermission = (group, permission) => {
            group.permissions = group.permissions.filter(
                (p) => p !== permission
            );
        };
        this.addPermission = (group) => {
            group.permissions.push(group.newPermission);
            group.newPermission = "";
        };
        this.sortUpdate = (index, newIndex) => {
            const group = this.groups.splice(index, 1)[0];
            const finalIndex = newIndex > index ? newIndex - 1 : newIndex;
            this.groups.splice(finalIndex, 0, group);
        };

        this.addGroupData = {
            name: "",
            errorName: true,
        };
        const updateAddData = () => {
            this.addGroupData.errorName = false;
            if (
                this.addGroupData.name.length < 3 ||
                this.addGroupData.name.length > 50
            ) {
                // invalid name length
                this.addGroupData.errorName = true;
            } else if (
                this.groups.some(
                    (g) =>
                        String(g.name)
                            .toLowerCase()
                            .localeCompare(
                                this.addGroupData.name.toLowerCase().trim()
                            ) === 0
                )
            ) {
                // name already assigned
                this.addGroupData.errorName = true;
            }
        };
        updateAddData();
        $rootScope.$watch(() => this.addGroupData, updateAddData, true);
        this.createGroup = () => {
            if (this.addGroupData.errorName) return;
            this.groups.splice(1, 0, {
                name: this.addGroupData.name,
                nameColor: "#ffffff",
                textColor: "#ffffff",
            });
            const name = this.addGroupData.name;
            closeCreateAccordion();
            $timeout(() => {
                $rootScope.$broadcast(
                    "BJToggleAccordion",
                    "group-" + name,
                    true
                );
            }, 200);
        };
        const closeCreateAccordion = () => {
            this.addGroupData.name = "";
            $rootScope.$broadcast("BJToggleAccordion", "add-group", false);
        };

        this.save = () => {
            const groups = [];
            this.groups.forEach((g) => {
                const group = angular.copy(g);
                delete group.readonly;
                delete group.newPermission;
                delete group.permissionOptions;

                let col = beamjoyStore.utils.hexToRgb(g.nameColor);
                group.nameColor = [col.r, col.g, col.b];
                col = beamjoyStore.utils.hexToRgb(g.textColor);
                group.textColor = [col.r, col.g, col.b];
                groups.push(group);
            });
            beamjoyStore.send("BJDirectSend", ["saveGroups", groups]);
            this.dirty = false;
        };
        this.cancel = () => {
            skipWatch = true;
            angular.copy(this.default, this.groups);
            this.dirty = false;
            closeCreateAccordion();
            $timeout(() => (skipWatch = false), 0);
        };
    },
});
