---@return {ip: string, port: string, name: string, map: string, skipModWarning: boolean}
function GetServerInfos()
    local data = MPCoreNetwork.getCurrentServer()
    data.name = data.name or data.ip
    return data
end
