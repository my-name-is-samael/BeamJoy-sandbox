angular.module("beamjoy").directive("ngHtml", function ($compile) {
    return {
        restrict: "A",
        scope: {
            ngHtml: "@",
        },
        link: function (scope, element) {
            let currScope;
            scope.$watch("ngHtml", (newValue) => {
                if (currScope) currScope.$destroy();

                if (newValue) {
                    currScope = scope.$parent.$new();
                    element.html(newValue);
                    $compile(element.contents())(currScope);
                }
            });

            scope.$on("$destroy", () => {
                if (currScope) currScope.$destroy();
            });
        },
    };
});
