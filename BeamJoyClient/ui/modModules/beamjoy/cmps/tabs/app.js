angular.module("beamjoy").component("bjTabs", {
    bindings: {
        tabs: "<",
        activeTabIndex: "<",
        onTabChange: "&",
        onTabClose: "&",
    },
    templateUrl: "/ui/modModules/beamjoy/cmps/tabs/app.html",
});
