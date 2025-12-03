angular.module("beamjoy").component("bjConfigGeneralModelBlacklist", {
    templateUrl:
        "/ui/modModules/beamjoy/windows/config/general/modelBlacklist/app.html",
    controller: function ($scope, beamjoyStore) {
        this.models = []; // {key: string, label: string}[] all models constants
        this.labels = {}; // {[modelKey: string] = label: string} all models labels constants
        this.list = []; // string[] model keys
        this.default = []; // string[] saved model keys
        this.options = []; // { value: string, label: string }[]
        this.selected = undefined; // string?
        this.dirty = false;
        const updateDirty = () => {
            this.dirty = !angular.equals(this.list, this.default);
        };
        const updateLabels = () => {
            this.labels = {};
            this.models.forEach((model) => {
                this.labels[model.key] = model.label;
            });
        };
        const updateOptions = () => {
            this.options = angular
                .copy(this.models)
                .filter((m) => !this.list.includes(m.key))
                .map((m) => {
                    return {
                        value: m.key,
                        label: `${m.key} - ${m.label}`,
                    };
                })
                .sort((a, b) => a.label.localeCompare(b.label));
            if (
                !this.selected ||
                !this.options.some((o) => o.value === this.selected)
            ) {
                this.selected = this.options[0]
                    ? this.options[0].value
                    : undefined;
            }
        };
        $scope.$watch(
            () => this.list,
            () => {
                updateOptions();
                updateDirty();
            },
            true
        );
        const importData = (list, models) => {
            this.models = models;
            updateLabels();
            this.default = list;
            if (!Array.isArray(this.default)) this.default = [];
            if (!this.dirty) {
                this.list = angular.copy(this.default);
            } else {
                updateDirty();
            }
            if (this.options.length === 0) {
                updateOptions();
            }
        };
        beamjoyStore.send("BJRequestModelsBlacklist");
        $scope.$on("BJModelsBlacklist", (_, data) => {
            importData(data.list, data.models);
        });
        this.removeModel = (evt, el) => {
            evt.stopPropagation();
            const index = this.list.indexOf(el);
            if (index > -1) {
                this.list.splice(index, 1);
            }
        };
        this.addOption = (evt) => {
            evt.stopPropagation();
            if (this.selected) {
                this.list.push(this.selected);
                this.list.sort((a, b) => a.localeCompare(b));
                this.selected = undefined;
            }
        };
        this.save = () => {
            beamjoyStore.send("BJDirectSend", ["setConfig", "ModelBlacklist", this.list]);
        };
        this.cancel = () => {
            this.list = angular.copy(this.default);
            updateDirty();
        };
    },
});
