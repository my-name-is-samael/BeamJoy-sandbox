angular.module("beamjoy").component("bjAccordion", {
    bindings: {
        id: "@",
        noBorderBottom: "<?",
    },
    transclude: {
        header: "?accordionTitle",
        body: "accordionContent",
    },
    templateUrl: "/ui/modModules/beamjoy/cmps/accordion/app.html",
    controller: function ($rootScope, $timeout, beamjoyStore) {
        this.state = beamjoyStore.accordionStates[this.id];
        this.toggle = () => {
            beamjoyStore.accordionStates[this.id] =
                !beamjoyStore.accordionStates[this.id];
            this.state = beamjoyStore.accordionStates[this.id];
        };
        this.transition = false;
        $timeout(() => {
            this.transition = true;
        }, 500);

        $rootScope.$on("BJToggleAccordion", (_, id, state) => {
            if (id === this.id) {
                if (state === undefined) {
                    state = !this.state;
                }
                if (state !== this.state) {
                    this.toggle();
                }
            }
        });
        $rootScope.$watch(
            () => this.id,
            () => {
                this.transition = false;
                $timeout(() => {
                    this.state = beamjoyStore.accordionStates[this.id];
                }, 100);
                $timeout(() => {
                    this.transition = true;
                }, 500);
            }
        );
    },
});
