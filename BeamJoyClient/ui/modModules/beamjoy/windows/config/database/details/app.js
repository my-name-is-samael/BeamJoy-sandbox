angular.module("beamjoy").component("bjConfigDatabaseDetails", {
    bindings: {
        player: "<",
    },
    templateUrl:
        "/ui/modModules/beamjoy/windows/config/database/details/app.html",
    controller: function ($scope, beamjoyStore, $filter) {
        const translate = $filter("translate");

        this.init = false;

        this.readOnly = true;
        this.readOnlyData = true;
        const updateReadOnly = () => {
            if (this.player && this.player.group) {
                if (beamjoyStore.players.self.group === "owner") {
                    this.readOnly =
                        beamjoyStore.players.self.playerName ===
                        this.player.playerName;
                    this.readOnlyData = false;
                } else {
                    const selfLevel = beamjoyStore.groups.getGroupIndex(
                        beamjoyStore.players.self.group
                    );
                    const playerLevel = beamjoyStore.groups.getGroupIndex(
                        this.player.group
                    );
                    this.readOnly = selfLevel <= playerLevel;
                    this.readOnlyData = this.readOnly;
                }
            }
        };

        // group
        this.groupLabels = {};
        this.groupOptions = [];
        this.groupSelected = null;
        const updateGroupData = () => {
            const selfLevel = beamjoyStore.groups.getGroupIndex(
                beamjoyStore.players.self.group
            );
            // group labels
            this.groupLabels = {};
            beamjoyStore.groups.data.forEach((g) => {
                this.groupLabels[g.name] = translate(
                    "beamjoy.groups." + g.name
                );
                if (
                    !this.groupLabels[g.name] ||
                    this.groupLabels[g.name] === "beamjoy.groups." + g.name
                ) {
                    this.groupLabels[g.name] = g.name;
                }
            });
            // group select dropdown
            if (!this.readOnly) {
                this.groupOptions = beamjoyStore.groups.data
                    .filter((_, i) => i < selfLevel)
                    .map((g) => ({
                        value: g.name,
                        label: this.groupLabels[g.name],
                    }));
                this.groupSelected = this.player.group;
                if (
                    !this.groupOptions.some(
                        (o) => o.value === this.groupSelected
                    )
                ) {
                    this.groupSelected = this.groupOptions[0]
                        ? this.groupOptions[0].value
                        : null;
                }
            }
        };
        ["BJUpdateGroups", "BJUpdatePermissions", "BJUpdateSelf"].forEach(
            (eventName) => {
                $scope.$on(eventName, () => {
                    updateReadOnly();
                    updateGroupData();
                });
            }
        );
        $scope.$watch(
            () => this.groupSelected,
            () => {
                if (!this.readOnly && this.groupSelected) {
                    if (this.groupSelected === this.player.group) return;
                    beamjoyStore.send("BJDirectSend", [
                        "setGroup",
                        this.player.playerName,
                        this.groupSelected,
                    ]);
                }
            }
        );

        // mute
        this.newMuteReason = "";
        this.unmute = () => {
            beamjoyStore.send("BJDirectSend", [
                "mute",
                this.player.playerName,
                false,
            ]);
        };
        this.mute = () => {
            beamjoyStore.send("BJDirectSend", [
                "mute",
                this.player.playerName,
                true,
                this.newMuteReason.length > 0 ? this.newMuteReason : null,
            ]);
            this.newMuteReason = "";
        };

        // ban
        this.newBanReason = "";
        this.unban = () => {
            beamjoyStore.send("BJDirectSend", [
                "unban",
                this.player.playerName,
            ]);
        };
        this.ban = () => {
            beamjoyStore.send("BJDirectSend", [
                "ban",
                this.player.playerName,
                this.newBanReason.length > 0 ? this.newBanReason : null,
            ]);
            this.newBanReason = "";
        };

        // custom data
        this.data = [];
        this.newData = {
            type: "boolean",
            value: true,
            disabled: false,
            TYPES: ["boolean", "number", "string"].map((t) => ({
                value: t,
                label: translate("beamjoy.types." + t),
            })),
        };
        const updateData = () => {
            this.data = Object.entries(this.player.data).map(([key, value]) => {
                let v;
                if (typeof value === "string") {
                    v = `"${value}" (${translate("beamjoy.types.string")})`;
                } else if (typeof value === "number") {
                    v = `${value} (${translate("beamjoy.types.number")})`;
                } else {
                    // boolean
                    v = `${translate(
                        value
                            ? "beamjoy.common.enabled"
                            : "beamjoy.common.disabled"
                    )} (${translate("beamjoy.types.boolean")})`;
                }
                return { key, value: v };
            });
        };
        $scope.$watch(
            () => this.newData.type,
            () => {
                if (
                    this.newData.type === "number" &&
                    typeof this.newData.value !== "number"
                ) {
                    this.newData.value = 0;
                } else if (
                    this.newData.type === "boolean" &&
                    typeof this.newData.value !== "boolean"
                ) {
                    this.newData.value = true;
                } else if (
                    this.newData.type === "string" &&
                    typeof this.newData.value !== "string"
                ) {
                    this.newData.value = "";
                }
            }
        );
        $scope.$watch(
            () => this.newData.value,
            () => {
                if (this.newData.type === "number") {
                    this.newData.disabled =
                        typeof this.newData.value !== "number";
                } else if (this.newData.type === "boolean") {
                    this.newData.disabled = false;
                } else if (this.newData.type === "string") {
                    this.newData.disabled =
                        typeof this.newData.value !== "string";
                }
            }
        );
        this.addData = () => {
            beamjoyStore.send("BJDirectSend", [
                "setData",
                this.player.playerName,
                this.newData.key,
                this.newData.value,
            ]);
            this.newData.type = "boolean";
            this.newData.key = "";
            this.newData.value = true;
        };
        this.removeData = (key) => {
            beamjoyStore.send("BJDirectSend", [
                "setData",
                this.player.playerName,
                key,
            ]);
        };

        const updatePlayer = () => {
            updateReadOnly();
            updateGroupData();
            updateData();
        };
        $scope.$watch(() => this.player, updatePlayer, true);

        this.$onInit = () => {
            updatePlayer();
            this.init = true;
        };
    },
});
