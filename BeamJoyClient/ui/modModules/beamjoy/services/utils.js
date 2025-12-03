const M = {};
let parent;
M.init = function (beamjoyStore) {
    parent = beamjoyStore;
};

M.rgbToHex = function (rgb) {
    let res = "#";
    [rgb.r, rgb.g, rgb.b].forEach((v) => {
        let val = parseInt(v * 255).toString(16);
        res += `${val.length == 1 ? "0" : ""}${val}`;
    });
    return res;
};

M.hexToRgb = function (hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
        ? {
              r: Math.round((parseInt(result[1], 16) / 255) * 1000) / 1000,
              g: Math.round((parseInt(result[2], 16) / 255) * 1000) / 1000,
              b: Math.round((parseInt(result[3], 16) / 255) * 1000) / 1000,
          }
        : null;
};

M.prettyDelay = function (secs) {
    secs = Math.max(secs, 0);
    let mins = 0,
        hours = 0,
        days = 0,
        months = 0;
    if (secs >= 60) {
        mins = Math.floor(secs / 60);
        secs = secs - mins * 60;
    }
    if (mins >= 60) {
        hours = Math.floor(mins / 60);
        mins = mins - hours * 60;
    }
    if (hours >= 24) {
        days = Math.floor(hours / 24);
        hours = hours - days * 24;
    }
    if (days >= 30) {
        months = Math.floor(days / 30);
        days = days - months * 30;
    }

    const andLabel = ", ";

    if (months > 1) {
        const monthLabel = parent.translate("beamjoy.time.months");
        return `${months} ${monthLabel}`;
    } else if (months === 1) {
        const monthLabel = parent.translate("beamjoy.time.month");
        const dayLabel =
            days > 1
                ? parent.translate("beamjoy.time.days")
                : parent.translate("beamjoy.time.day");
        if (days > 0) {
            return `${months} ${monthLabel}${andLabel}${days} ${dayLabel}`;
        } else {
            return `${months} ${monthLabel}`;
        }
    }

    if (days > 1) {
        const dayLabel = parent.translate("beamjoy.time.days");
        return `${days} ${dayLabel}`;
    } else if (days === 1) {
        const dayLabel = parent.translate("beamjoy.time.day");
        const hourLabel =
            hours > 1
                ? parent.translate("beamjoy.time.hours")
                : parent.translate("beamjoy.time.hour");
        if (hours > 0) {
            return `${days} ${dayLabel}${andLabel}${hours} ${hourLabel}`;
        } else {
            return `${days} ${dayLabel}`;
        }
    }

    if (hours > 1) {
        const hourLabel = parent.translate("beamjoy.time.hours");
        return `${hours} ${hourLabel}`;
    } else if (hours === 1) {
        const hourLabel = parent.translate("beamjoy.time.hour");
        const minLabel =
            mins > 1
                ? parent.translate("beamjoy.time.minutes")
                : parent.translate("beamjoy.time.minute");
        if (mins > 0) {
            return `${hours} ${hourLabel}${andLabel}${mins} ${minLabel}`;
        } else {
            return `${hours} ${hourLabel}`;
        }
    }

    if (mins > 1) {
        const minLabel = parent.translate("beamjoy.time.minutes");
        return `${mins} ${minLabel}`;
    } else if (mins === 1) {
        const minLabel = parent.translate("beamjoy.time.minute");
        const secLabel =
            secs > 1
                ? parent.translate("beamjoy.time.seconds")
                : parent.translate("beamjoy.time.second");
        if (secs > 0) {
            return `${mins} ${minLabel}${andLabel}${secs} ${secLabel}`;
        } else {
            return `${mins} ${minLabel}`;
        }
    }

    const secondLabel =
        secs > 1
            ? parent.translate("beamjoy.time.seconds")
            : parent.translate("beamjoy.time.second");
    return `${secs} ${secondLabel}`;
};

export default M;
