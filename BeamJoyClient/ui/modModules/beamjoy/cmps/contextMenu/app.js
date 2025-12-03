angular.module("beamjoy").component("bjContextMenu", {
    bindings: {},
    transclude: true,
    templateUrl: "/ui/modModules/beamjoy/cmps/contextMenu/app.html",
    controller: function ($rootScope, beamjoyStore, $scope) {
        this.hide = () => {
            this.actions = null;
            this.position = { x: 0, y: 0 };
            this.transform = "translate(0%, 0%)";
        };
        this.hide();

        this.action = (evt, actionIndex) => {
            evt.stopPropagation();
            beamjoyStore.send("ContextMenuClicked", [actionIndex]);
            this.hide();
        };

        $rootScope.$on("BJContextMenu", (_, payload) => {
            if (payload.actions && payload.actions.length > 0) {
                this.actions = payload.actions;
                this.position = payload.position;
                this.transform = `translate(${
                    this.position.x > 50 ? "-100" : "0"
                }%, ${this.position.y > 50 ? "-100" : "0"}%)`;
            } else {
                this.hide();
            }
        });

        this.clickOut = (evt) => {
            evt.stopPropagation();
            $scope.$applyAsync(() => {
                if (this.actions) {
                    beamjoyStore.send("ContextMenuClosed");
                    this.hide();
                }
            });
        };
    },
});
