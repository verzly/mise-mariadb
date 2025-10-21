local http = require('http')
local json = require('json')
local util = require('util')
require('constants')

function PLUGIN:Available(ctx)
    local result = {}

    local resp, err = http.get({ url = MARIADB_VERSIONS_URL })
    if not resp or not resp.body then
        print("⚠️ Error fetching MariaDB releases: " .. tostring(err))
        return result
    end

    local ok, data = pcall(json.decode, resp.body)
    if not ok or not data or not data.releases then
        print("⚠️ Failed to parse MariaDB JSON response.")
        return result
    end

    for _, group in pairs(data.releases) do
        if group.children then
            for _, rel in ipairs(group.children) do
                -- only accept x.y.z
                -- exclude versions what contains space; e.g.: "11.6.0 Vector"
                if rel.release_number and not rel.release_number:find("%s") then
                    table.insert(result, {
                        version = rel.release_number,
                        name = rel.text or ("MariaDB " .. rel.release_number),
                        -- Windows url example: https://archive.mariadb.org//mariadb-11.4.8/winx64-packages/mariadb-11.4.8-winx64.zip
                        -- Linux url example: https://archive.mariadb.org//mariadb-11.4.8/bintar-linux-systemd-x86_64/mariadb-11.4.8-linux-systemd-x86_64.tar.gz
                        url = "https://archive.mariadb.org/mariadb-" .. rel.release_number .. "/"
                    })
                end
            end
        end
    end

    table.sort(result, function(a, b)
        return util.compare_versions(a.version, b.version) > 0
    end)

    if #result == 0 then
        print("⚠️ No MariaDB versions found.")
    end

    return result
end
