angular.module("beamjoy").component("icon", {
    bindings: {
        name: "@",
    },
    controller: function ($element, $http, $templateCache, $scope) {
        const setIcon = () => {
            $element.html("");
            if (!this.name || this.name === "") return;
            const path = `/ui/modModules/beamjoy/icons/${this.name}.svg`;
            $http.get(path, { cache: $templateCache }).then(
                (res) => {
                    $element.html(res.data);
                    const svg = $element[0].querySelector("svg");
                    if (svg) {
                        svg.setAttribute("height", "100%");
                        svg.setAttribute("width", "100%");
                    }
                },
                (err) => {
                    console.error(`Failed to load icon: ${this.name}`, err);
                }
            );
        };
        this.$onInit = setIcon;
        $scope.$watch(() => this.name, setIcon);
    },
});
