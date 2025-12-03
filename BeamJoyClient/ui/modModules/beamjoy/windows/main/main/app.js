await import(`/ui/modModules/beamjoy/windows/main/main/players-list/app.js`);

angular.module("beamjoy").component("bjMainMain", {
    templateUrl: "/ui/modModules/beamjoy/windows/main/main/app.html",
    controller: function ($rootScope, beamjoyStore) {
        this.openSettings = () => {
            $rootScope.$broadcast("BJOpenTab", "settings");
        };

        this.stateNametags = !beamjoyStore.settings.data.nametags.hideNameTags;
        this.toggleNametags = () => {
            this.stateNametags = !this.stateNametags;
            beamjoyStore.send("BJToggleNametagsHideState");
        };
        $rootScope.$on("BJNametagsState", (_, data) => {
            this.stateNametags = !data.hideNameTags;
        });
    },
});
