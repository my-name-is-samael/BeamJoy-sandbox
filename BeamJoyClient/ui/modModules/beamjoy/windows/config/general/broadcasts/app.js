angular.module("beamjoy").component("bjConfigGeneralBroadcasts", {
    templateUrl:
        "/ui/modModules/beamjoy/windows/config/general/broadcasts/app.html",
    controller: function ($rootScope, beamjoyStore, $filter, $timeout) {
        const translate = $filter("translate");
        this.langs = ["en-US"];
        this.default = {};
        this.data = {
            enabled: false,
            delay: 120,
            messages: [],
        };
        this.computed = {
            delayError: false,
            delayPreview: "30 seconds",
            messagesError: [],
        };

        this.init = false;
        this.dirty = false;
        this.valid = true;
        const updateDirty = () => {
            if (!this.init) return;
            this.dirty = !angular.equals(this.data, this.default);
        };

        const parseBroadcasts = (rawData) => {
            const messages = Array.isArray(rawData.messages)
                ? rawData.messages
                : [];
            return {
                enabled: rawData.enabled === true,
                delay: rawData.delay,
                messages: messages.map((entry) => {
                    return this.langs.map((lang) => {
                        return {
                            lang: lang,
                            message: entry[lang] || "",
                        };
                    });
                }),
            };
        };
        const updateComputedAndValidate = () => {
            this.valid = true;
            this.computed.delayError =
                isNaN(this.data.delay) ||
                this.data.delay < 30 ||
                this.data.delay > 1800;
            if (this.computed.delayError) {
                this.computed.delayPreview = translate(
                    "beamjoy.common.invalid"
                );
                this.valid = false;
            } else {
                const minutes = Math.floor(this.data.delay / 60);
                const seconds = this.data.delay - minutes * 60;
                this.computed.delayPreview = ``;
                if (minutes > 0) {
                    this.computed.delayPreview += `${minutes} ${translate(
                        "beamjoy.time.minutes"
                    )}`;
                }
                if (seconds > 0) {
                    if (minutes > 0) {
                        this.computed.delayPreview += ` ${translate(
                            "beamjoy.common.and"
                        )} `;
                    }
                    this.computed.delayPreview += `${seconds} ${translate(
                        "beamjoy.time.seconds"
                    )}`;
                }
            }
            this.computed.messagesError = [];
            this.data.messages.forEach((entry, i) => {
                if (entry.every((msg) => msg.message.trim().length === 0)) {
                    this.computed.messagesError[i] = true;
                    this.valid = false;
                }
            });
        };

        const updateData = (payload) => {
            if (!payload.data) return;
            this.langs = payload.langs.sort((a, b) => {
                if (a === "en-US") return -1;
                if (b === "en-US") return 1;
                return a.localeCompare(b);
            });
            this.default = parseBroadcasts(payload.data);
            if (!this.dirty) {
                this.data = angular.copy(this.default);
            }
            this.init = true;
            updateDirty();
        };
        $rootScope.$watch(
            () => this.data,
            () => {
                updateDirty();
                updateComputedAndValidate();
            },
            true
        );
        $rootScope.$on("BJSendBroadcastsData", (_, payload) => {
            $rootScope.$applyAsync(() => updateData(payload));
        });
        this.addMessage = () => {
            this.data.messages.push(
                this.langs.map((lang) => ({
                    lang: lang,
                    message: "",
                }))
            );
            $timeout(() => {
                $rootScope.$broadcast(
                    "BJToggleAccordion",
                    `broadcast-message-${this.data.messages.length - 1}`
                );
            }, 500);
        };
        this.removeMessage = (evt, index) => {
            evt.stopPropagation();
            this.data.messages.splice(index, 1);
        };
        this.save = () => {
            const payload = {
                enabled: this.data.enabled,
                delay: this.data.delay,
                messages: this.data.messages
                    .filter((entry) => {
                        // removes all langs empty messages
                        return (
                            entry.filter((msg) => msg.message.trim().length > 0)
                                .length > 0
                        );
                    })
                    .map((entry) => {
                        const res = {};
                        entry.forEach((msg) => {
                            if (msg.message.trim().length > 0) {
                                res[msg.lang] = msg.message;
                            }
                        });
                        return res;
                    }),
            };

            beamjoyStore.send("BJDirectSend", [
                "setConfig",
                "Broadcasts",
                payload,
            ]);
            this.dirty = false;
        };
        this.cancel = () => {
            this.data = angular.copy(this.default);
            updateDirty();
        };

        this.$onInit = () => {
            beamjoyStore.send("BJRequestBroadcastsData");
        };
    },
});
