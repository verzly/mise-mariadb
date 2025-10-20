local util = require('util')
require('constants')

function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    local releases = self:Available({})

    if not releases or #releases == 0 then
        error("⚠️ No MariaDB releases available.")
    end

    if version == "latest" or version == "" then
        version = releases[1].version
    end

    local release = nil
    for _, r in ipairs(releases) do
        if r.version == version then
            release = r
            break
        end
    end

    if not release then
        error("Version not found: " .. version)
    end

    if RUNTIME.osType == 'windows' then
        return GetReleaseForWindows(release)
    else
        InstallDependencies()
        return GetReleaseForLinux(release)
    end
end

function GetReleaseForWindows(release)
    local asset_name = "winx64-packages/mariadb-" .. release.version .. "-winx64.zip"
    local download_url = release.url .. asset_name

    return {
        version = release.version,
        url = download_url,
    }
end

function GetReleaseForLinux(release)
    local asset_name = "bintar-linux-systemd-x86_64/mariadb-" .. release.version .. "-linux-systemd-x86_64.tar.gz"
    local download_url = release.url .. asset_name

    return {
        version = release.version,
        url = download_url,
    }
end

function InstallDependencies()
    os.execute('chmod +x ' .. RUNTIME.pluginDirPath .. '/bin/install-dependencies.sh')
    local ok, code, out = util.run_cmd(RUNTIME.pluginDirPath .. '/bin/install-dependencies.sh')
    if not ok then
        error('An unexpected error occurred while installing dependencies.' .. "\nOutput:\n" .. out)
    end
end
