angular
    .module("beamjoy")
    .directive("autoheight", function ($rootScope, $timeout) {
        return {
            restrict: "A",
            link: function (scope, element, attrs, ngModelCtrl) {
                const updateMinHeight = () => {
                    element[0].style.width = "";
                    element[0].style.height = "";
                        element[0].style.height =
                            element[0].scrollHeight + 3 + "px";
                    $timeout(() => {
                    }, 0);
                };

                element.on("input", updateMinHeight);
                element.on("focus", updateMinHeight);
                element.on("mouseenter", updateMinHeight);

                scope.$on("$destroy", () => {
                    element.off("input", updateMinHeight);
                    element.off("focus", updateMinHeight);
                    element.off("mouseenter", updateMinHeight);
                });
            },
        };
    });
