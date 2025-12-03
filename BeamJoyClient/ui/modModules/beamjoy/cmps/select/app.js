angular.module("beamjoy").component("bjSelect", {
    bindings: {
        ngModel: "=",
        options: "<",
        ngChange: "&?",
    },
    templateUrl: "/ui/modModules/beamjoy/cmps/select/app.html",
    controller: function ($scope, $timeout) {
        this.renderKey = 1;
        $scope.$watch(
            () => this.options,
            () => {
                const next = this.renderKey + 1;
                this.renderKey = undefined;
                $timeout(() => (this.renderKey = next), 0);
            },
            true
        );
        this.handleChange = () => {
            if (this.ngChange) this.ngChange(this.ngModel);
        };
    },
});
