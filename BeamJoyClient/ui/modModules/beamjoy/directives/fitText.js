function fitTextWithWrap(el, maxFontSize = 200, minFontSize = 17) {
    let size = maxFontSize;
    const parentWidth = el.clientWidth;
    const parentHeight = el.clientHeight;

    el.style.whiteSpace = "normal";
    el.style.wordWrap = "break-word";
    el.style.fontSize = size + "px";

    while (
        (el.scrollHeight > parentHeight || el.scrollWidth > parentWidth) &&
        size > minFontSize
    ) {
        size -= 1;
        el.style.fontSize = size + "px";
    }
}

angular.module("beamjoy").directive("fitText", function ($timeout) {
    return {
        restrict: "A",
        link: function (scope, elem) {
            function applyFit() {
                $timeout(() => fitTextWithWrap(elem[0]), 0);
            }

            scope.$watch(() => elem.text(), applyFit);
            scope.$watch(() => elem[0].clientWidth + 'x' + elem[0].clientHeight, applyFit);
        },
    };
});
