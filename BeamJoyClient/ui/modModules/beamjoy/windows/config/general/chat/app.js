angular.module("beamjoy").component("bjConfigGeneralChat", {
    templateUrl: "/ui/modModules/beamjoy/windows/config/general/chat/app.html",
    controller: function ($rootScope, beamjoyStore) {
        this.default = {};
        this.data = {
            ServerNameColor: "#ff0000",
            ServerTextColor: "#ff5959",
            EventColor: "#44ff44",
            BroadcastColor: "#9999ff",
            ShowStaffTag: true,
            WelcomeMessage: [],
        };
        this.resetValues = {
            ServerNameColor: this.data.ServerNameColor,
            ServerTextColor: this.data.ServerTextColor,
            EventColor: this.data.EventColor,
            BroadcastColor: this.data.BroadcastColor,
        };

        this.init = false;
        this.dirty = false;
        const updateDirty = () => {
            if (!this.init) return;
            this.dirty = !angular.equals(this.data, this.default);
        };

        const updateData = (data) => {
            this.default = angular.copy(data);
            this.default.ServerNameColor = beamjoyStore.utils.rgbToHex(
                this.default.ServerNameColor
            );
            this.default.ServerTextColor = beamjoyStore.utils.rgbToHex(
                this.default.ServerTextColor
            );
            this.default.EventColor = beamjoyStore.utils.rgbToHex(
                this.default.EventColor
            );
            this.default.BroadcastColor = beamjoyStore.utils.rgbToHex(
                this.default.BroadcastColor
            );
            this.default.WelcomeMessage = Object.keys(
                this.default.WelcomeMessage
            )
                .map((lang) => ({
                    lang,
                    message: this.default.WelcomeMessage[lang],
                }))
                .sort((a, b) => a.lang.localeCompare(b.lang));

            if (!this.dirty) {
                this.data = angular.copy(this.default);
            }
            this.init = true;
            updateDirty();
        };
        $rootScope.$watch(() => this.data, updateDirty, true);
        $rootScope.$on("BJSendChatData", (_, data) => {
            $rootScope.$applyAsync(() => updateData(data));
        });
        this.save = () => {
            const payload = angular.copy(this.data);
            let c = beamjoyStore.utils.hexToRgb(payload.ServerNameColor);
            payload.ServerNameColor = [c.r, c.g, c.b];
            c = beamjoyStore.utils.hexToRgb(payload.ServerTextColor);
            payload.ServerTextColor = [c.r, c.g, c.b];
            c = beamjoyStore.utils.hexToRgb(payload.EventColor);
            payload.EventColor = [c.r, c.g, c.b];
            c = beamjoyStore.utils.hexToRgb(payload.BroadcastColor);
            payload.BroadcastColor = [c.r, c.g, c.b];
            payload.WelcomeMessage = payload.WelcomeMessage.reduce(
                (acc, el) => {
                    if (el.message.length > 0) {
                        acc[el.lang] = el.message;
                    }
                    return acc;
                },
                {}
            );

            beamjoyStore.send("BJDirectSend", ["setConfig", "Chat", payload]);
            this.dirty = false;
        };
        this.cancel = () => {
            this.data = angular.copy(this.default);
            updateDirty();
        };

        this.$onInit = () => {
            beamjoyStore.send("BJRequestChatData");
        };
    },
});
