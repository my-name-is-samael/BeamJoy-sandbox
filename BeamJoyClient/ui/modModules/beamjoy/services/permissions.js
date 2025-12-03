const M = {
    PERMISSIONS: {},

    data: {},
};
let parent;
M.init = function (beamjoyStore) {
    parent = beamjoyStore;
};
M.isStaff = function (playerName) {
    playerName = playerName || parent.players.self.playerName;
    const player = parent.players.players.find(
        (p) => p.playerName == playerName
    );
    if (!player) return false;
    const group = parent.groups.getGroup(player.group);
    return group && group.staff;
};

M.hasAllPermissions = function (playerName, ...permissions) {
    playerName = playerName || parent.players.self.playerName;
    const player = parent.players.players.find(
        (p) => p.playerName == playerName
    );
    if (!player) return false;
    const groupIndex = parent.groups.getGroupIndex(player.group);
    const group = typeof groupIndex === "number" ? parent.groups.data[groupIndex] : null;
    if (!group) return false;
    return permissions.every((permName) => {
        const permGroupIndex = parent.groups.getGroupIndex(M.data[permName]);
        return (
            typeof permGroupIndex === "number" &&
            (group.permissions.includes(permName) ||
                permGroupIndex <= groupIndex)
        );
    });
};

M.hasAnyPermission = function (playerName, ...permissions) {
    playerName = playerName || parent.players.self.playerName;
    const player = parent.players.players.find(
        (p) => p.playerName == playerName
    );
    if (!player) return false;
    const groupIndex = parent.groups.getGroupIndex(player.group);
    const group = typeof groupIndex === "number" ? parent.groups.data[groupIndex] : null;
    if (!group) return false;
    return permissions.some((permName) => {
        const permGroupIndex = parent.groups.getGroupIndex(M.data[permName]);
        return (
            typeof permGroupIndex === "number" &&
            (group.permissions.includes(permName) ||
                permGroupIndex <= groupIndex)
        );
    });
};

export default M;
