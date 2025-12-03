angular
    .module("beamjoy")
    .directive("tooltip", function () {
        return {
            restrict: "A",
            link: function (scope, element, attrs) {
                let el;

                function showTooltip() {
                    if (!attrs.tooltip) return;
                    const parent = element[0].getBoundingClientRect();
                    if (!el) {
                        el = document.querySelector("beamjoy-tooltip");
                    }
                    el.querySelector("tooltip-content").innerText =
                        attrs.tooltip;
                    const viewport = {
                        x: window.innerWidth,
                        y: window.innerHeight,
                    };
                    const parentCenter = {
                        x: parent.left + parent.width / 2,
                        y: parent.top + parent.height / 2,
                    };
                    el.style.inset = "unset";
                    el.style.top = `${parentCenter.y}px`;
                    if (parentCenter.x < viewport.x / 2) {
                        el.style.left = `${parent.right}px`;
                    } else {
                        el.style.right = `${viewport.x - parent.left}px`;
                    }
                    el.classList.add("show");
                }

                function hideTooltip() {
                    if (el) {
                        el.classList.remove("show");
                        setTimeout(() => {
                            if (el.classList.contains("show")) return;
                            el.querySelector("tooltip-content").innerText = "";
                        }, 200);
                    }
                }

                element.on("mouseenter", showTooltip);
                element.on("mouseleave", hideTooltip);
                element.on("click", hideTooltip);
                scope.$on("$destroy", hideTooltip);
            },
        };
    })
    .run(function ($rootScope, $timeout, $compile) {
        if (document.querySelector("beamjoy-tooltip")) return;

        const tooltip = document.createElement("beamjoy-tooltip");
        tooltip.appendChild(document.createElement("tooltip-content"));
        document.body.prepend(tooltip);

        function processTitles() {
            document.querySelectorAll("[title]").forEach((el) => {
                const title = el.getAttribute("title");
                if (!title) return;
                el.removeAttribute("title");
                el.setAttribute("tooltip", title);
                $compile(el)($rootScope);
            });
        }

        // init
        processTitles();

        const observer = new MutationObserver(() => {
            $timeout(processTitles, 0);
        });
        observer.observe(document.body, { childList: true, subtree: true });

        $rootScope.$on("BJUnload", () => {
            document.querySelector("beamjoy-tooltip").remove();
        });
    });
