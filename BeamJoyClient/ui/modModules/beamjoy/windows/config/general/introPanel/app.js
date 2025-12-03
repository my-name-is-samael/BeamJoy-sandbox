angular.module("beamjoy").component("bjConfigGeneralIntropanel", {
    templateUrl:
        "/ui/modModules/beamjoy/windows/config/general/introPanel/app.html",
    controller: function ($rootScope, beamjoyStore) {
        this.imageOptions = [];
        this.default = {};
        this.data = {
            enabled: false,
            title: "",
            content: "",
            image: null,
            onlyFirstConnection: false,
        };

        this.init = false;
        this.dirty = false;
        this.updateDirty = () => {
            this.dirty =
                this.dirty ||
                JSON.stringify(this.data) !== JSON.stringify(this.default);
        };

        const updateData = (data) => {
            data.settings.content = data.settings.content
                .replaceAll("<br/>", "\n")
                .replaceAll("%%", "%");
            this.default = angular.copy(data.settings);
            this.imageOptions = data.images;
            if (!this.dirty) {
                this.data = data.settings;
            }
            if (!this.init) {
                $rootScope.$watch(() => this.data, this.updateDirty, true);
                this.init = true;
            }
        };
        $rootScope.$on("BJSendIntroPanelData", (_, data) => {
            $rootScope.$applyAsync(() => updateData(data));
        });
        this.preview = () => {
            beamjoyStore.send("BJOpenIntroPanel", [
                this.data.title,
                this.data.content
                    .replaceAll("\n", "<br/>")
                    .replaceAll("%", "%%"),
                this.data.image,
            ]);
        };
        this.save = () => {
            const payload = angular.copy(this.data);
            payload.content = payload.content
                .replaceAll("\n", "<br/>")
                .replaceAll("%", "%%");
            beamjoyStore.send("BJSaveIntroPanelData", [payload]);
            this.dirty = false;
        };
        this.cancel = () => {
            this.dirty = false;
            beamjoyStore.send("BJRequestIntroPanelData");
        };
        this.reset = () => {
            this.dirty = false;
            beamjoyStore.send("BJResetIntroPanelData");
        };

        this.$onInit = () => {
            beamjoyStore.send("BJRequestIntroPanelData");
        };
    },
});
