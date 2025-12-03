angular.module("beamjoy").component("bjWindow", {
    bindings: {
        label: "@",
        visible: "<",
        minimizable: "<",
        closable: "<",
        onClose: "&?",
        background: "<",
    },
    transclude: true,
    templateUrl: "/ui/modModules/beamjoy/cmps/window/app.html",
    controller: function () {
        this.minimized = false;
        this.toggleMinimized = () => {
            this.minimized = !this.minimized;
        };
    },
});
