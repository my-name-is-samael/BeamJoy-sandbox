angular.module("beamjoy").component("bjSlider", {
    bindings: {
        ngModel: "=",
        min: "<?",
        max: "<?",
        step: "<?",
        disabled: "<?",
    },
    templateUrl: "/ui/modModules/beamjoy/cmps/slider/app.html",
    controller: function ($timeout, $scope, $element) {
        const updatePercent = () => {
            const min = this.min || 0;
            const max = this.max || 100;
            this.percent = Math.round(
                ((this.ngModel - min) / (max - min)) * 100
            );
        };
        const roundModel = () => {
            this.ngModel = Math.round(Number(this.ngModel) * 10) / 10;
        };
        $scope.$watch(
            () => ({ model: this.ngModel, min: this.min, max: this.max }),
            () => {
                roundModel();
                updatePercent();
            },
            true
        );
        roundModel();
        updatePercent();

        this.$onInit = () => {
            const slider = $element[0].querySelector("input[type=range]");
            slider.addEventListener("wheel", (evt) => {
                evt.preventDefault();
                const step = this.step || 1;
                const offset = evt.deltaY < 0 ? step : -step;
                this.ngModel = Number(this.ngModel) + offset;
                if (this.ngModel < this.min) this.ngModel = this.min;
                if (this.ngModel > this.max) this.ngModel = this.max;
                slider.dispatchEvent(new Event("input", { bubbles: true }));
            });
        };
    },
});
