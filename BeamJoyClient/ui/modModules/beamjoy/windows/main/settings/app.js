angular.module("beamjoy").component("bjMainSettings", {
    templateUrl: "/ui/modModules/beamjoy/windows/main/settings/app.html",
    controller: function ($scope, $rootScope, beamjoyStore) {
        this.resetValues = angular.copy(beamjoyStore.settings.defaults);
        this.settings = angular.copy(beamjoyStore.settings.data);
        $rootScope.$on("BJUserSettings", () => {
           this.settings = angular.copy(beamjoyStore.settings.data)
        });

        $scope.$watch(
            () => this.settings,
            () => {
                beamjoyStore.settings.save(this.settings);
            },
            true
        );
    },
});
