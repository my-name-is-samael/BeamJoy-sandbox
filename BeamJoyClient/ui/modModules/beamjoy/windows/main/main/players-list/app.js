await import(`/ui/modModules/beamjoy/windows/main/main/player-line/app.js`);
await import(
    `/ui/modModules/beamjoy/windows/main/main/player-moderation/app.js`
);
await import(`/ui/modModules/beamjoy/windows/main/main/vehicle-line/app.js`);

angular.module("beamjoy").component("bjPlayersList", {
    templateUrl:
        "/ui/modModules/beamjoy/windows/main/main/players-list/app.html",
    controller: function ($rootScope, beamjoyStore, $filter) {
        const translate = $filter("translate");
        this.players = [];
        this.moderationInputs = {};

        this.updateList = () => {
            if (beamjoyStore.groups.data.length == 0) return;
            if (beamjoyStore.players.players.length == 0) return;
            if (beamjoyStore.players.self.playerName.length == 0) return;

            const selfGroupIndex = beamjoyStore.groups.getGroupIndex(
                beamjoyStore.players.self.group
            );
            const selfStaff = beamjoyStore.permissions.isStaff();
            const canModerate =
                selfStaff ||
                beamjoyStore.permissions.hasAnyPermission(
                    null,
                    beamjoyStore.permissions.PERMISSIONS.Mute,
                    beamjoyStore.permissions.PERMISSIONS.Kick,
                    beamjoyStore.permissions.PERMISSIONS.Ban,
                    beamjoyStore.permissions.PERMISSIONS.TempBan
                );
            this.players = beamjoyStore.players.players.map((p) => {
                const playerGroupIndex = beamjoyStore.groups.getGroupIndex(
                    p.group
                );
                if (!this.moderationInputs[p.playerName]) {
                    this.moderationInputs[p.playerName] = {
                        kickReason: "",
                        banReason: "",
                        tempBanDuration: 300,
                        muteReason: "",
                    };
                }

                // prettier-ignore
                const res = Object.assign(
                    {
                        showModeration:
                            selfGroupIndex > playerGroupIndex &&
                            canModerate,
                        showVehicles:
                            selfStaff &&
                            Object.keys(p.vehicles).length > 0 &&
                            (selfGroupIndex > playerGroupIndex ||
                                p.playerID ==
                                    beamjoyStore.players.self.playerID),
                    }, p);
                res.vehicles = Object.values(p.vehicles).filter((v) => !v.isAi);
                const countTraffic = Object.values(p.vehicles).filter(
                    (v) => v.isAi
                ).length;
                if (res.vehicles.length + countTraffic > 0) {
                    const parts = [];
                    if (res.vehicles.length > 0) {
                        parts.push(String(res.vehicles.length));
                    }
                    if (countTraffic > 0) {
                        parts.push(
                            translate(
                                "beamjoy.window.main.playerlist.vehicles.trafficCount"
                            ).replace("{count}", countTraffic)
                        );
                    }
                    res.vehicleInfo = `(${parts.join(" + ")})`;
                }
                return res;
            });
        };
        this.updateList();
        [
            "BJUpdatePlayers",
            "BJUpdatePlayer",
            "BJUpdateGroups",
            "BJUpdateSelf",
        ].forEach((event) => {
            $rootScope.$on(event, this.updateList);
        });
    },
});
