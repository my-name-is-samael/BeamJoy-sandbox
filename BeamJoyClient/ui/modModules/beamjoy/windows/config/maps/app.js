angular.module("beamjoy").component("bjConfigMaps", {
    templateUrl: "/ui/modModules/beamjoy/windows/config/maps/app.html",
    controller: function ($scope, beamjoyStore) {
        this.default = {
            active: [],
            ignored: [],
        };
        this.data = {
            active: [],
            ignored: [],
        };
        this.init = false;
        this.dirty = false;
        this.valid = false;
        this.errors = {};
        const updateDirty = () => {
            this.dirty = !angular.equals(this.data, this.default);
        };
        const updateValid = () => {
            this.valid = true;
            this.errors = {};
            const seenNames = [];
            this.data.active.forEach((map) => {
                if (map.label.length < 3) {
                    this.valid = false;
                    this.errors[map.name] = true;
                }
                if (seenNames.includes(map.label)) {
                    this.valid = false;
                    this.errors[map.name] = true;
                }
                seenNames.push(map.label);
            });
            this.data.ignored.forEach((map) => {
                if (map.label.length < 3) {
                    this.valid = false;
                    this.errors[map.name] = true;
                }
                if (seenNames.includes(map.label)) {
                    this.valid = false;
                    this.errors[map.name] = true;
                }
                seenNames.push(map.label);
            });
        };
        $scope.$watch(
            () => this.data,
            () => {
                if (!this.init) return;
                updateDirty();
                updateValid();
            },
            true
        );
        const parseMaps = (data) => {
            return {
                active: Object.entries(data)
                    .filter(([key, value]) => !value.ignore)
                    .map(([key, value]) => ({
                        name: key,
                        label: value.label,
                        enabled: value.enabled,
                        archive: value.archive,
                    })).sort((a,b) => String(a.name).localeCompare(b.name)),
                ignored: Object.entries(data)
                    .filter(([key, value]) => value.ignore)
                    .map(([key, value]) => ({
                        name: key,
                        label: value.label,
                        archive: value.archive,
                    })).sort((a,b) => String(a.name).localeCompare(b.name)),
            };
        };
        $scope.$on("BJSendMapsData", (_, data) => {
            this.default = parseMaps(data);
            if (!this.dirty) {
                this.data = angular.copy(this.default);
            }
            updateDirty();
            updateValid();
            this.init = true;
        });
        this.$onInit = () => {
            beamjoyStore.send("BJRequestMapsData");
        };
        this.removeIgnored = (name) => {
            this.data.ignored = this.data.ignored.filter(
                (map) => map.name !== name
            );
        };
        this.cancel = () => {
            this.data = angular.copy(this.default);
        };
        this.save = () => {
            if (!this.dirty) return;
            const payload = {};
            this.data.active.forEach((map) => {
                payload[map.name] = {
                    label: map.label,
                    enabled: map.enabled,
                    ignore: false,
                };
            });
            this.data.ignored.forEach((map) => {
                payload[map.name] = {
                    label: map.label,
                    ignore: true,
                };
            });
            beamjoyStore.send("BJDirectSend", ["setMaps", payload]);
        };
    },
});
