angular.module("beamjoy").component("bjConfigGeneralWhitelist", {
    templateUrl:
        "/ui/modModules/beamjoy/windows/config/general/whitelist/app.html",
    controller: function ($scope, beamjoyStore) {
        this.init = false;
        this.canToggleState = false;
        this.default = {};
        this.data = {
            state: false,
            list: [],
        };
        this.connectedPlayers = [];
        this.playerList = [];
        this.canAddAll = false;
        this.offlinePlayer = "";
        this.validOfflinePlayer = false;

        $scope.$watch(
            () => this.data.state,
            () => {
                if (!this.init) return;
                if (this.data.state === this.default.state) return;
                beamjoyStore.send("BJDirectSend", [
                    "whitelist",
                    this.data.state,
                ]);
            }
        );
        $scope.$watch(
            () => this.offlinePlayer,
            () => {
                if (!this.init) return;
                this.validOfflinePlayer = true;
                const name = this.offlinePlayer.trim();
                if (name.length < 2) this.validOfflinePlayer = false;
                if (this.data.list.includes(name))
                    this.validOfflinePlayer = false;
            }
        );
        this.togglePlayer = (evt, playerName) => {
            if (evt) evt.stopPropagation();
            beamjoyStore.send("BJDirectSend", ["whitelistPlayer", playerName]);
        };
        this.addAll = (evt) => {
            evt.stopPropagation();
            this.playerList
                .filter((p) => !p.state)
                .forEach((p) => {
                    this.togglePlayer(null, p.playerName);
                });
        };
        this.addOfflinePlayer = (evt) => {
            evt.stopPropagation();
            beamjoyStore.send("BJDirectSend", [
                "whitelistPlayer",
                this.offlinePlayer.trim(),
            ]);
            this.offlinePlayer = "";
        };

        const updatePlayerList = () => {
            this.playerList = angular.copy(this.data.list).map((playerName) => {
                return {
                    playerName,
                    state: true,
                };
            });
            this.connectedPlayers.forEach((playerName) => {
                if (!this.playerList.some((p) => p.playerName === playerName)) {
                    this.playerList.push({
                        playerName,
                        state: false,
                    });
                }
            });
            this.playerList.sort((a, b) =>
                a.playerName.localeCompare(b.playerName)
            );
            this.canAddAll = this.playerList.some((p) => !p.state);
        };

        const updateData = (data) => {
            this.data = data;
            if (!Array.isArray(this.data.list)) this.data.list = [];
            this.default = angular.copy(this.data);
            updatePlayerList();
            this.init = true;
        };
        $scope.$on("BJSendWhitelistData", (_, data) => {
            updateData(data);
        });

        const updatePermissionsAndPlayers = () => {
            this.canToggleState = beamjoyStore.permissions.hasAllPermissions(
                beamjoyStore.players.self.playerName,
                beamjoyStore.permissions.PERMISSIONS.SetConfig
            );
            this.connectedPlayers = beamjoyStore.players.players.map(
                (p) => p.playerName
            );
            updatePlayerList();
        };
        [
            "BJUpdatePlayers",
            "BJUpdateSelf",
            "BJUpdatePermissions",
            "BJUpdateGroups",
        ].forEach((event) => {
            $scope.$on(event, updatePermissionsAndPlayers);
        });
        updatePermissionsAndPlayers();

        this.$onInit = () => {
            beamjoyStore.send("BJRequestWhitelistData");
        };
    },
});
