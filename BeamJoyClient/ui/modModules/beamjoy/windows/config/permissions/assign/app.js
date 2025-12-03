angular.module("beamjoy").component("bjConfigPermissionsAssign", {
    templateUrl:
        "/ui/modModules/beamjoy/windows/config/permissions/assign/app.html",
    controller: function ($rootScope, beamjoyStore, $timeout, $filter) {
        const translate = $filter("translate");
        this.dirty = false;
        this.owner = false;
        this.selfGroupIndex = 0;
        this.orderedGroups = [];
        this.defaultPerms = [];
        this.perms = [];

        const createGroupsOrder = () => {
            this.orderedGroups = angular
                .copy(beamjoyStore.groups.data)
                .map((group) => {
                    const label = translate("beamjoy.groups." + group.name);
                    if (label && label !== "beamjoy.groups." + group.name) {
                        group.label = label;
                    } else {
                        group.label = group.name;
                    }
                    return group;
                });
        };

        let skipWatch = false;
        const updateDirty = () => {
            if (skipWatch) return;
            this.dirty = !angular.equals(this.perms, this.defaultPerms);
        };

        const updateData = () => {
            this.selfGroupIndex = beamjoyStore.groups.getGroupIndex(
                beamjoyStore.players.self.group
            );
            this.owner = beamjoyStore.players.self.group === "owner";
            createGroupsOrder();
            this.defaultPerms = [];
            Object.entries(beamjoyStore.permissions.data).forEach(
                ([name, groupName]) => {
                    const groupIndex =
                        beamjoyStore.groups.getGroupIndex(groupName);
                    this.defaultPerms.push({ name, groupIndex });
                }
            );
            this.defaultPerms.sort((a, b) => a.name.localeCompare(b.name));
            if (!this.dirty) {
                this.perms = angular.copy(this.defaultPerms);
            }
            updateDirty();
        };

        updateData();
        $rootScope.$watch(() => this.perms, updateDirty, true);

        ["BJUpdateGroups", "BJUpdatePermissions", "BJUpdateSelf"].forEach(
            (eventName) => {
                $rootScope.$on(eventName, updateData);
            }
        );

        this.save = () => {
            const payload = {};
            this.perms.forEach((p) => {
                const groupName = beamjoyStore.groups.data[p.groupIndex].name;
                payload[p.name] = groupName;
            });
            beamjoyStore.send("BJSavePermissions", [payload]);
        };
        this.cancel = () => {
            skipWatch = true;
            this.perms = angular.copy(this.defaultPerms);
            this.dirty = false;
            $timeout(() => (skipWatch = false), 0);
        };
    },
});
