local util = require('util')
require('constants')

-- Template mappa (projektben)
local templateBinDir = RUNTIME.pluginDirPath .. "/bin"

-- Segédfüggvény: template másolása + placeholder csere
local function CopyAndReplaceTemplate(srcPath, dstPath, replacements)
    local f = io.open(srcPath, "r")
    if not f then
        error("Template fájl nem található: " .. srcPath)
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

--[[ PostInstall hook ]]--
function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo['mariadb']
    local path = sdkInfo.path   -- Telepítés alapkönyvtára
    local version = sdkInfo.version

    if not version or version == "" then
        local handle = io.popen("mariadb -V | grep -oP '\\d+\\.\\d+\\.\\d+'")
        local result = handle:read("*all")
        handle:close()
        version = result:gsub("%s+", "")
        if version == "" then
            error("Nem található MariaDB verzió, add meg a version-t constants.lua-ban vagy ctx-ben.")
        end
    end

    -- Létrehozzuk a telepített MariaDB bin mappát
    local installBinDir = path .. "/bin"
    os.execute("mkdir -p " .. installBinDir)

    -- Executables létrehozása a template-ekből
    CopyAndReplaceTemplate(templateBinDir .. "/mariadb-install.template", installBinDir .. "/mariadb-install", {
        ["##VERSION##"] = version,
        ["##BASEDIR##"] = path
    })

    CopyAndReplaceTemplate(templateBinDir .. "/mariadb-server.template", installBinDir .. "/mariadb-server", {
        ["##VERSION##"] = version,
        ["##BASEDIR##"] = path
    })

    CopyAndReplaceTemplate(templateBinDir .. "/mariadb-client.template", installBinDir .. "/mariadb-client", {
        ["##VERSION##"] = version
    })

    print("✅ MariaDB executables létrehozva a " .. installBinDir .. " mappában:")
    print("  mariadb-install  -> interaktív telepítés, copy/symlink/tiszta telepítés")
    print("  mariadb-server   -> start/stop MariaDB a kiválasztott verzióval")
    print("    -V/--verbose?")
    print("  mariadb-client   -> csatlakozás a kiválasztott verzióhoz, username/password megadható")
    print("    -u/--user?=without-user -p/--password?=without-password --version?=MiseDefault --port?=3306")

    local serviceDir = os.getenv("HOME") .. "/.config/systemd/user"
    os.execute("mkdir -p " .. serviceDir)
    CopyAndReplaceTemplate(templateBinDir .. "/mariadb.service.template", serviceDir .. "/mariadb.service", {})
    print("✅ MariaDB systemd service létrehozva felhasználói szinten: " .. serviceDir .. "/mariadb.service")
    print("  systemctl --user status mariadb")
    print("  systemctl --user start mariadb")
    print("  systemctl --user restart mariadb")
    print("  systemctl --user stop mariadb")
end
