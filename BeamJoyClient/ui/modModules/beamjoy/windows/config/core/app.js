angular.module("beamjoy").component("bjConfigCore", {
    templateUrl: "/ui/modModules/beamjoy/windows/config/core/app.html",
    controller: function ($scope, beamjoyStore) {
        this.data = {
            Name: "",
            Description: "",
            MaxPlayers: 1,
            Private: true,
            Debug: false,
            InformationPacket: false,
        };
        this.default = {};
        this.init = false;
        this.dirty = false;
        this.valid = false;
        const updateDirty = () => {
            this.dirty = !angular.equals(this.data, this.default);
        };
        const updateValid = () => {
            this.valid = true;
            if (this.data.Name.length < 3 || this.data.Name.length > 150)
                this.valid = false;
            if (this.data.Description.length > 500) this.valid = false;
            if (!this.data.MaxPlayers) this.valid = false;
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
        const replaceLineBreaksIn = (str) => {
            while (str.includes("^p")) {
                str = str.replace("^p", "\n");
            }
            return str;
        };
        $scope.$on("BJSendCoreData", (_, data) => {
            this.default = data;
            this.default.Description = replaceLineBreaksIn(
                this.default.Description
            );
            if (!this.dirty) {
                Object.assign(this.data, this.default);
            }
            updateDirty();
            updateValid();
            this.init = true;
        });
        this.$onInit = () => {
            beamjoyStore.send("BJRequestCoreData");
        };
        this.cancel = () => {
            this.data = angular.copy(this.default);
        };
        this.save = () => {
            if (!this.dirty) return;
            Object.keys(this.data)
                .filter(
                    (key) => !angular.equals(this.data[key], this.default[key])
                )
                .forEach((key) => {
                    let value = this.data[key];
                    if (key === "Description") {
                        while (value.includes("\n")) {
                            value = value.replace("\n", "^p");
                        }
                    }
                    beamjoyStore.send("BJDirectSend", ["setCore", key, value]);
                });
        };

        const parsePreview = (str) => {
            const colors = {
                0: "rgb(0, 0, 0)",
                1: "rgb(0, 0, 170)",
                2: "rgb(0, 170, 0)",
                3: "rgb(0, 170, 170)",
                4: "rgb(170, 0, 0)",
                5: "rgb(170, 0, 170)",
                6: "rgb(255, 170, 0)",
                7: "rgb(170, 170, 170)",
                8: "rgb(85, 85, 85)",
                9: "rgb(85, 85, 255)",
                a: "rgb(85, 255, 85)",
                b: "rgb(85, 255, 255)",
                c: "rgb(255, 85, 85)",
                d: "rgb(255, 85, 255)",
                e: "rgb(255, 255, 85)",
                f: "rgb(255, 255, 255)",
            };

            const effects = {
                n: "underline",
                l: "bold",
                m: "strike",
                o: "italic",
            };

            let segments = [];
            let current = { text: "", styles: { color: "rgb(255, 255, 255)" } };

            for (let i = 0; i < str.length; i++) {
                const char = str[i];
                if (char === "^") {
                    const code = str[++i];
                    if (code === "r") {
                        // reset
                        if (current.text) segments.push(current);
                        current = {
                            text: "",
                            styles: { color: "rgb(255, 255, 255)" },
                        };
                    } else if (colors.hasOwnProperty(code)) {
                        if (current.text) segments.push(current);
                        current = { text: "", styles: { ...current.styles } };
                        current.styles = {
                            ...current.styles,
                            color: colors[code],
                        };
                    } else if (effects.hasOwnProperty(code)) {
                        if (current.text) segments.push(current);
                        current = { text: "", styles: { ...current.styles } };
                        current.styles = {
                            ...current.styles,
                            [effects[code]]: true,
                        };
                    } else {
                        // invalid code, does not add up
                    }
                } else if (char === "\n") {
                    if (current.text) segments.push(current);
                    segments.push({ text: "\n", styles: {} });
                    current = { text: "", styles: { ...current.styles } };
                } else {
                    current.text += char;
                }
            }
            if (current.text) segments.push(current);
            return segments;
        };
        this.renderPreview = (segments) => {
            return (
                segments
                    .map((seg) => {
                        if (seg.text === "\n") return "<br>";
                        let style = "";
                        if (seg.styles.color)
                            style += `color:${seg.styles.color};`;
                        if (seg.styles.bold) style += "font-weight:bold;";
                        if (seg.styles.underline)
                            style += "text-decoration:underline;";
                        if (seg.styles.strike)
                            style += "text-decoration:line-through;";
                        if (seg.styles.italic) style += "font-style:italic;";
                        return `<span style="${style}">${seg.text}</span>`;
                    })
                    .join("") + "<hr/>"
            );
        };
        this.namePreview = null;
        this.descriptionPreview = null;
        $scope.$watch(
            () => this.data.Name,
            () => {
                if (this.data.Name.includes("^")) {
                    this.namePreview = parsePreview(
                        this.data.Name + "[OFFLINE]"
                    );
                } else this.namePreview = null;
            }
        );
        $scope.$watch(
            () => this.data.Description,
            () => {
                this.data.Description = replaceLineBreaksIn(
                    this.data.Description
                );
                if (this.data.Description.includes("^")) {
                    this.descriptionPreview = parsePreview(
                        this.data.Description
                    );
                } else this.descriptionPreview = null;
            }
        );
    },
});
