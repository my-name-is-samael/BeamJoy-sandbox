-- FS lib additions

---@param path string
FS.RemoveDirectory = FS.RemoveDirectory or function(path)
    if not FS.Exists(path) or not FS.IsDirectory(path) then return end
    for _, file in pairs(FS.ListFiles(path)) do
        FS.Remove(path .. "/" .. file)
    end
    for _, folder in pairs(FS.ListDirectories(path)) do
        FS.RemoveDirectory(path .. "/" .. folder)
    end
    FS.Remove(path)
end

FS.isWindows = FS.isWindows or function()
    local sep = package.config:sub(1, 1)
    return sep == "\\"
end

---@param archivePath string
---@param dstPath string
FS.ExtractTo = FS.ExtractTo or function(archivePath, dstPath)
    if not FS.Exists(dstPath) then FS.CreateDirectory(dstPath) end
    if FS.isWindows() then
        os.execute(string.format(
            'powershell -Command "Expand-Archive -Path \'%s\' -DestinationPath \'%s\' -Force"',
            archivePath, dstPath
        ))
    else
        os.execute("unzip -o " .. archivePath .. " -d " .. dstPath)
    end
end

---@param srcPath string
---@param destPath string
FS.Move = FS.Move or function(srcPath, destPath)
    if not FS.Exists(srcPath) or not FS.IsFile(srcPath) then return end
    FS.Copy(srcPath, destPath)
    FS.Remove(srcPath)
end
