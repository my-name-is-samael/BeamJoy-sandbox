await import(`/ui/modModules/beamjoy/windows/config/permissions/groups/app.js`);
await import(`/ui/modModules/beamjoy/windows/config/permissions/assign/app.js`);

angular.module("beamjoy").component("bjConfigPermissions", {
    templateUrl: "/ui/modModules/beamjoy/windows/config/permissions/app.html",
    controller: function () {},
});
