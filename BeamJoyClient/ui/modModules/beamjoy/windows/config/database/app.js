await import(`/ui/modModules/beamjoy/windows/config/database/details/app.js`);

angular.module("beamjoy").component("bjConfigDatabase", {
    templateUrl: "/ui/modModules/beamjoy/windows/config/database/app.html",
    controller: function ($scope, beamjoyStore) {
        this.data = {};
        this.playerOptions = [];
        this.selectedPlayer = null;
        this.init = false;

        this.filterEnabled = false;
        this.filter = "";

        this.toggleFilter = () => {
            this.filterEnabled = !this.filterEnabled;
        };

        const updatePlayersOptions = () => {
            if (!this.init) return;
            this.playerOptions = Object.keys(this.data)
                .sort()
                .map((name) => {
                    return {
                        value: name,
                        label: name,
                    };
                });
            if (this.filterEnabled && this.filter.length > 0) {
                this.playerOptions = this.playerOptions.filter((v) => {
                    return v.value
                        .toLowerCase()
                        .includes(this.filter.toLowerCase());
                });
            }
            if (
                !this.playerOptions.some((v) => v.value === this.selectedPlayer)
            ) {
                this.selectedPlayer = this.playerOptions[0]
                    ? this.playerOptions[0].value
                    : null;
            }
        };
        $scope.$watch(() => this.filterEnabled, updatePlayersOptions);
        $scope.$watch(() => this.filter, updatePlayersOptions);

        $scope.$on("BJDatabase", (_, payload) => {
            this.data = payload.players;
            this.init = true;
            updatePlayersOptions();
        });
        ["BJUpdatePlayer", "BJUpdateDBPlayer"].forEach((event) => {
            $scope.$on(event, (_, payload) => {
                if (!this.init) return;
                this.data[payload.playerName] = payload.data;
            });
        });

        this.$onInit = () => {
            beamjoyStore.send("BJDirectSend", ["requestDatabase"]);
        };
    },
});
