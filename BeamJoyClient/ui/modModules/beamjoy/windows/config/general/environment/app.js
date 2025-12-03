angular.module("beamjoy").component("bjConfigGeneralEnvironment", {
    templateUrl:
        "/ui/modModules/beamjoy/windows/config/general/environment/app.html",
    controller: function ($rootScope, beamjoyStore) {
        this.data = {
            timeSync: false,
            dayLength: 30, // minutes
            nightBrightnessMultiplier: 1,
            gravitySync: false,
        };
        this.default = {};
        this.init = false;
        this.dirty = false;
        const updateDirty = () => {
            this.dirty = !angular.equals(this.data, this.default);
        };
        $rootScope.$watch(
            () => this.data,
            () => {
                if (this.init) {
                    updateDirty();
                }
            },
            true
        );

        $rootScope.$on("BJEnvironment", (_, payload) => {
            this.default = {
                timeSync: payload.timeSync,
                dayLength: Math.round(payload.dayLength / 60),
                nightBrightnessMultiplier: payload.nightBrightnessMultiplier,
                gravitySync: payload.gravitySync,
            };
            if (!this.dirty) {
                this.data = angular.copy(this.default);
            }
            updateDirty();
            this.init = true;
        });
        this.$onInit = () => beamjoyStore.send("BJRequestEnv");

        this.openSettings = () => {
            $rootScope.$broadcast("ChangeState", { state: "menu.environment" });
        };

        this.save = () => {
            beamjoyStore.send("BJSetEnvironment", [
                {
                    timeSync: this.data.timeSync,
                    dayLength: this.data.dayLength * 60,
                    nightBrightnessMultiplier: this.data.nightBrightnessMultiplier,
                    gravitySync: this.data.gravitySync,
                },
            ]);
            this.dirty = false;
        };
        this.cancel = () => {
            this.data = angular.copy(this.default);
            updateDirty();
        };
    },
});
