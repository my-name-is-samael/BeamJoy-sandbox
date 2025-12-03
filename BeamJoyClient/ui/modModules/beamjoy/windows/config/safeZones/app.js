angular.module("beamjoy").component("bjConfigSafeZones", {
    templateUrl: "/ui/modModules/beamjoy/windows/config/safeZones/app.html",
    controller: function ($rootScope, $scope, beamjoyStore) {
        this.$onInit = () => {
            beamjoyStore.send("BJEditorSafeZoneOpen");
        };
        $scope.$on("$destroy", function () {
            beamjoyStore.send("BJEditorSafeZoneClose");
        });

        this.tool = "";
        $rootScope.$on("BJEditorChangeTool", (_, tool) => {
            this.tool = tool;
        });
        this.zones = [];
        $rootScope.$on("BJEditorSafeZonesUpdate", (_, zones) => {
            this.zones = zones;
        });
        this.activeZone = null;
        $rootScope.$on("BJEditorActiveUpdate", (_, activeZone) => {
            this.activeZone = activeZone ? activeZone - 1 : null;
        });
        this.dirty = false;
        $rootScope.$on("BJEditorDirty", (_, state) => {
            this.dirty = state === true;
        });
        this.changeTool = (event, tool) => {
            event.stopPropagation();
            beamjoyStore.send("BJEditorChangeTool", [tool]);
        };
        this.selectZone = (event, iZone) => {
            event.stopPropagation();
            beamjoyStore.send("BJEditorSafeZoneSelect", [iZone + 1]);
        };
        this.duplicateZone = (event, iZone) => {
            event.stopPropagation();
            beamjoyStore.send("BJEditorSafeZoneDuplicate", [iZone + 1]);
        }
        this.deleteZone = (event, iZone) => {
            event.stopPropagation();
            beamjoyStore.send("BJEditorSafeZoneDelete", [iZone + 1]);
        };
        this.createZone = (event) => {
            event.stopPropagation();
            beamjoyStore.send("BJEditorSafeZoneCreate");
        };
        this.save = (event) => {
            event.stopPropagation();
            beamjoyStore.send("BJEditorSafeZoneSave");
        };
    },
});
