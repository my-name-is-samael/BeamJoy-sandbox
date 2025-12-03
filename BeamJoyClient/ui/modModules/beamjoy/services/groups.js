const M = {
    data: [],
    defaultGroups: [],
};
let parent;
M.init = function (beamjoyStore) {
    parent = beamjoyStore;
};

M.set = function (payload) {
    M.data = payload.groups;
    M.defaultGroups = payload.defaultGroups;
    M.data.forEach((group) => {
        group.permissions = Array.isArray(group.permissions)
            ? group.permissions
            : [];
    });
};
M.getPrevious = function (groupName) {
    const groupIndex = M.getGroupIndex(groupName);
    if (typeof groupIndex  !== "number") return;
    let prevName, prevLevel;
    M.data.forEach((cgroup, index) => {
        if (
            index < groupIndex &&
            (!prevLevel || index > prevLevel)
        ) {
            prevName = cgroup.name;
            prevLevel = index;
        }
    });
    return prevName;
};

M.getNext = function (groupName) {
    const groupIndex = M.getGroupIndex(groupName);
    if (typeof groupIndex  !== "number") return;
    let nextName, nextLevel;
    M.data.forEach((cgroup, index) => {
        if (
            index > groupIndex &&
            (!nextLevel || index < nextLevel)
        ) {
            nextName = cgroup.name;
            nextLevel = index;
        }
    });
    return nextName;
};

M.getGroupIndex = (groupName) => {
    const index = M.data.findIndex((g) => g.name === groupName);
    return typeof index === "number" && index > -1 ? index : null;
};

M.getGroup = (groupName) => {
    const index = M.getGroupIndex(groupName);
    return typeof index === "number" ? M.data[index] : null;
};

export default M;
