local util = require('util')
require('constants')

local function CopyAndReplaceTemplate(srcPath, dstPath, replacements)
    local f = io.open(srcPath, "r")
    if not f then
        error("Template file not found: " .. srcPath)
    end
    local content = f:read("*all")
    f:close()

    for key, value in pairs(replacements) do
        content = content:gsub(key, value)
    end

    local out = io.open(dstPath, "w")
    out:write(content)
    out:close()
    os.execute('chmod +x "' .. dstPath .. '"')
end

function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo['mariadb']
    local path = sdkInfo.path
    local version = sdkInfo.version

    if not version or version == "" then
        local handle = io.popen("mariadb -V | grep -oP '\\d+\\.\\d+\\.\\d+'")
        local result = handle:read("*all")
        handle:close()
        version = result:gsub("%s+", "")
        if version == "" then
            error("No MariaDB version found, set version in constants.lua or ctx.")
        end
    end

    if RUNTIME.osType == "windows" then
        ConfigForWindows(path, version)
    else
        ConfigForLinux(path, version)
    end
end

function ConfigForWindows(path, version)
    local installBinDir = path .. "/bin"
    os.execute("mkdir -p " .. installBinDir)
    local templateDir = RUNTIME.pluginDirPath .. "/templates/windows"

    CopyAndReplaceTemplate(templateDir .. "/mariadb-install.template", installBinDir .. "/mariadb-install.cmd", {
        ["##VERSION##"] = version,
        ["##BASEDIR##"] = path
    })

    CopyAndReplaceTemplate(templateDir .. "/mariadb-server.template", installBinDir .. "/mariadb-server.cmd", {
        ["##VERSION##"] = version,
        ["##BASEDIR##"] = path
    })

    CopyAndReplaceTemplate(templateDir .. "/mariadb-client.template", installBinDir .. "/mariadb-client.cmd", {
        ["##VERSION##"] = version
    })

    print("✅ Windows MariaDB executables created in " .. installBinDir)

    local createServiceCmd = table.concat({
        'sc create "MariaDB (mise managed, user)"',
        'binPath= "' .. installBinDir .. '\\mariadb-server.cmd start"',
        'DisplayName= "MariaDB (mise managed, user)"',
        'start= demand'
    }, " ")

    local ok, code, out = util.run_cmd(createServiceCmd)
    if not ok then
        error("Failed to create MariaDB service.\nOutput:\n" .. out)
    end

    print("✅ MariaDB user service created with name 'MariaDB (mise managed, user)'")
end

function ConfigForLinux(path, version)
    local installBinDir = path .. "/bin"
    os.execute("mkdir -p " .. installBinDir)
    local templateDir = RUNTIME.pluginDirPath .. "/templates/linux"

    CopyAndReplaceTemplate(templateDir .. "/mariadb-install.template", installBinDir .. "/mariadb-install", {
        ["##VERSION##"] = version,
        ["##BASEDIR##"] = path
    })

    CopyAndReplaceTemplate(templateDir .. "/mariadb-server.template", installBinDir .. "/mariadb-server", {
        ["##VERSION##"] = version,
        ["##BASEDIR##"] = path
    })

    CopyAndReplaceTemplate(templateDir .. "/mariadb-client.template", installBinDir .. "/mariadb-client", {
        ["##VERSION##"] = version
    })

    print("✅ Linux MariaDB executables created in " .. installBinDir)

    local serviceDir = os.getenv("HOME") .. "/.config/systemd/user"
    os.execute("mkdir -p " .. serviceDir)
    CopyAndReplaceTemplate(templateDir .. "/mariadb.service.template", serviceDir .. "/mariadb.service", {})

    print("✅ MariaDB systemd service created at " .. serviceDir .. "/mariadb.service")
end
