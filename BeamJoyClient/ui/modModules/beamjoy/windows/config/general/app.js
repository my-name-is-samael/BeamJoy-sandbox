await import(`/ui/modModules/beamjoy/windows/config/general/whitelist/app.js`);
await import(`/ui/modModules/beamjoy/windows/config/general/introPanel/app.js`);
await import(`/ui/modModules/beamjoy/windows/config/general/chat/app.js`);
await import(
    `/ui/modModules/beamjoy/windows/config/general/modelBlacklist/app.js`
);
await import(`/ui/modModules/beamjoy/windows/config/general/traffic/app.js`);
await import(
    `/ui/modModules/beamjoy/windows/config/general/environment/app.js`
);
await import(`/ui/modModules/beamjoy/windows/config/general/broadcasts/app.js`);

angular.module("beamjoy").component("bjConfigGeneral", {
    templateUrl: "/ui/modModules/beamjoy/windows/config/general/app.html",
    controller: function ($scope, beamjoyStore) {
        this.init = false;
        this.showConfigs = false;
        this.default = {};
        this.data = {
            AllowClientMods: true,
        };

        $scope.$watch(
            () => this.data.AllowClientMods,
            () => {
                if (!this.init) return;
                if (this.data.AllowClientMods === this.default.AllowClientMods)
                    return;
                beamjoyStore.send("BJDirectSend", [
                    "setConfig",
                    "AllowClientMods",
                    this.data.AllowClientMods,
                ]);
            }
        );
        $scope.$on("BJSendConfigData", (_, data) => {
            this.data = data;
            this.default = angular.copy(this.data);
            this.init = true;
        });
        this.$onInit = () => {
            beamjoyStore.send("BJRequestConfigData");
        };

        // ACCORDIONS
        this.display = {
            whitelist: false,
            introPanel: false,
            chat: false,
            modelBlacklist: false,
            traffic: false,
            environment: false,
            broadcasts: false,
        };
        const updateDisplayAndPermissions = () => {
            this.showConfigs = beamjoyStore.permissions.hasAllPermissions(
                beamjoyStore.players.self.playerName,
                beamjoyStore.permissions.PERMISSIONS.SetConfig
            );

            this.display.whitelist = beamjoyStore.permissions.hasAllPermissions(
                beamjoyStore.players.self.playerName,
                beamjoyStore.permissions.PERMISSIONS.Whitelist
            );
            this.display.introPanel =
                beamjoyStore.permissions.hasAllPermissions(
                    beamjoyStore.players.self.playerName,
                    beamjoyStore.permissions.PERMISSIONS.SetConfig
                );
            this.display.chat = beamjoyStore.permissions.hasAllPermissions(
                beamjoyStore.players.self.playerName,
                beamjoyStore.permissions.PERMISSIONS.SetConfig
            );
            this.display.modelBlacklist =
                beamjoyStore.permissions.hasAllPermissions(
                    beamjoyStore.players.self.playerName,
                    beamjoyStore.permissions.PERMISSIONS.SetConfig
                );
            this.display.traffic = beamjoyStore.permissions.hasAllPermissions(
                beamjoyStore.players.self.playerName,
                beamjoyStore.permissions.PERMISSIONS.SetConfig
            );
            this.display.environment =
                beamjoyStore.permissions.hasAllPermissions(
                    beamjoyStore.players.self.playerName,
                    beamjoyStore.permissions.PERMISSIONS.SetEnvironment
                );
            this.display.broadcasts =
                beamjoyStore.permissions.hasAllPermissions(
                    beamjoyStore.players.self.playerName,
                    beamjoyStore.permissions.PERMISSIONS.SetConfig
                );
        };

        ["BJUpdateSelf", "BJUpdatePermissions", "BJUpdateGroups"].forEach(
            (event) => {
                $scope.$on(event, updateDisplayAndPermissions);
            }
        );
        updateDisplayAndPermissions();
    },
});
