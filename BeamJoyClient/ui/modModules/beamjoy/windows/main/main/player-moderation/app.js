angular.module("beamjoy").component("bjPlayerModeration", {
    bindings: {
        player: "<",
    },
    templateUrl:
        "/ui/modModules/beamjoy/windows/main/main/player-moderation/app.html",
    controller: function ($scope, beamjoyStore, $filter) {
        const translate = $filter("translate");

        this.showMute = false;
        this.showKick = false;
        this.showBan = false;
        this.showTempban = false;

        this.muteReason = "";
        this.kickReason = "";
        this.banReason = "";
        this.tempbanDuration = 300;
        this.tempbanDurationLabel = "";
        let updateTempbanDurationLabel = () => {
            this.tempbanDurationLabel = beamjoyStore.utils.prettyDelay(
                this.tempbanDuration
            );
        };
        updateTempbanDurationLabel();
        $scope.$watch(() => this.tempbanDuration, updateTempbanDurationLabel);
        let update = () => {
            this.demoteLabel = undefined;
            this.promoteLabel = undefined;
            // GROUP MODERATION
            const previousGroup = beamjoyStore.groups.getPrevious(
                this.player.group
            );
            let previousGroupLabel;
            if (previousGroup && previousGroup !== "owner") {
                previousGroupLabel =
                    translate("beamjoy.groups." + previousGroup) ||
                    previousGroup;
            }
            this.demoteLabel = previousGroupLabel
                ? translate("beamjoy.window.main.moderation.demote").replace(
                      "{groupName}",
                      previousGroupLabel
                  )
                : undefined;

            const nextGroup = beamjoyStore.groups.getNext(this.player.group);
            let nextGroupLabel;
            if (
                nextGroup &&
                nextGroup !== "owner" &&
                nextGroup !== this.player.group
            ) {
                nextGroupLabel =
                    translate("beamjoy.groups." + nextGroup) || nextGroup;
            }
            this.promoteLabel = nextGroupLabel
                ? translate("beamjoy.window.main.moderation.promote").replace(
                      "{groupName}",
                      nextGroupLabel
                  )
                : undefined;
        };
        $scope.$on("BJUpdateSelf", update);
        $scope.$watch(() => this.player, update, true);

        this.$onInit = () => {
            this.showMute =
                beamjoyStore.permissions.isStaff() ||
                beamjoyStore.permissions.hasAllPermissions(
                    null,
                    beamjoyStore.permissions.PERMISSIONS.Mute
                );
            this.showKick =
                beamjoyStore.permissions.isStaff() ||
                beamjoyStore.permissions.hasAllPermissions(
                    null,
                    beamjoyStore.permissions.PERMISSIONS.Kick
                );
            this.showBan =
                beamjoyStore.permissions.isStaff() ||
                beamjoyStore.permissions.hasAllPermissions(
                    null,
                    beamjoyStore.permissions.PERMISSIONS.Ban
                );
            this.showTempban =
                beamjoyStore.permissions.isStaff() ||
                beamjoyStore.permissions.hasAllPermissions(
                    null,
                    beamjoyStore.permissions.PERMISSIONS.TempBan
                );

            update();
        };

        this.demote = () => {
            if (this.demoteLabel) {
                beamjoyStore.send("BJModerationDemote", [
                    this.player.playerName,
                ]);
            }
        };
        this.promote = () => {
            if (this.promoteLabel) {
                beamjoyStore.send("BJModerationPromote", [
                    this.player.playerName,
                ]);
            }
        };

        this.mute = () => {
            beamjoyStore.send("BJModerationMute", [
                this.player.playerName,
                this.muteReason.length > 0 ? this.muteReason : null,
            ]);
            this.muteReason = "";
        };

        this.kick = () => {
            beamjoyStore.send("BJModerationKick", [
                this.player.playerName,
                this.kickReason.length > 0 ? this.kickReason : null,
            ]);
        };

        this.updateTempbanDuration = (offset) => {
            this.tempbanDuration += offset;
            // clamp to 2 minutes -> 1 year range
            this.tempbanDuration = Math.max(
                120,
                Math.min(this.tempbanDuration, 60 * 60 * 24 * 30 * 12)
            );
        };
        this.resetTempbanDuration = () => {
            this.tempbanDuration = 300; // 5 minutes
        };
        this.ban = () => {
            beamjoyStore.send("BJModerationBan", [
                this.player.playerName,
                this.banReason.length > 0 ? this.banReason : null,
            ]);
        };
        this.tempban = () => {
            beamjoyStore.send("BJModerationTempBan", [
                this.player.playerName,
                this.tempbanDuration,
                this.banReason.length > 0 ? this.banReason : null,
            ]);
        };
    },
});
