angular.module("beamjoy").component("bjToggle", {
    bindings: {
        ngModel: "=",
        disabled: "<?",
        customEnabled: "@?",
        customDisabled: "@?",
    },
    templateUrl: "/ui/modModules/beamjoy/cmps/toggle/app.html",
    controller: function () {
        this.toggle = () => {
            if (!this.disabled) {
                this.ngModel = !this.ngModel;
            }
        };
    },
});
