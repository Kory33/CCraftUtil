-- package management software desined for CraftOS of ComputerCraft in Minecraft
-- Author: Kory3(MCID)
-- ChangeLog:
-- 0.0.0

-- private:

-- places to store the packages/package list in remote/turtle
--
-- CAPIM_DIR and CAPIM_PKG_REMOTELOC
-- may be declared and defined before this script is loaded if necessary
local CAPIM_DIR = (CAPIM_DIR == nil) and "/lib/capim" or CAPIM_DIR
local CAPIM_PKG_REMOTELOC = (CAPIM_PKG_REMOTELOC == nil)
                            and "https://github.com/Kory33/CCraftUtil/master/CCraftAPIManager/api_pkg"
                            or CAPIM_PKG_REMOTELOC

local CAPIM_PKG_LIST_FILE = CAPIM_DIR .. "/core/api_pkg"
local CAPIM_REPO_DIR = CAPIM_DIR .. "/repos"

local capimPackageTree = {}
local capimPackageLoaded=false
local defaultPackageSpace = "com.github.Kory33.CCraftUtil"


-- Synchronously download string data from the remote source given the url or address
--
-- @param   string  url      - URL of the remote source
-- @returns boolean state    - Whether the text is received correctly
-- @returns string  response - Data obtained from the remote source. nil if no response is received
local function DownloadData(url)
    if http == nil then
        error("http API is not loaded! Aborting download...")
        return nil, false
    end

    if not http.checkURL(url) then
        error("Invalid URL: " .. url)
        return nil, false
    end

    return http.get(url).readAll(), true
end


-- Forcefully update and override the existing package list file
--
-- @returns boolean state - whether the updating is correctly done or not
local function updatePackageList()
    local pkgFile = fs.open(CAPIM_PKG_LIST_FILE, fs.exists(CAPIM_PKG_LIST_FILE) and "a" or "w")
    local data, state = DownloadData(CAPIM_PKG_LIST_FILE)
    if state then
        pkgFile.write(data)
    else
        error("Package list data could not be downloaded!")
    end
    pkgFile.close()
    return state
end


-- parse Json-formatted string
--
-- @param string stdJsonStr - string that is formatted in EITHER json or lua table(deprecated) format
-- @returns boolean state   - whether the string could be parsed
-- @returns table data      - parsed data(nil if parsing failed)
local function parseJSON(stdJsonStr)
    -- TODO make proper parser
    if stdJsonStr == nil or stdJsonStr == "" then
        return true, {}
    end

    -- remove quotations around the key of the data and
    -- convert array format into lua's table format
    tableStr = stdJsonStr:gsub("[\"']([%a%d_-]-)[\"']%s:", "%1 = "):gsub("%[", "{"):gsub("]", "}")

    -- check that there is only single object in data
    local ok = not tableStr:match("^%s*%b{}%s*$") == nil
    local resultTable = nil

    if ok then
        ok, resultTable = pcall(load("return " .. tableStr))
    end

    if ok then
        return true, resultTable
    else
        return false, nil
    end
end


-- load the package list
--
-- @returns boolean state  - whether the package list file is read correctly
local function loadPackageList()
    if not fs.exists(CAPIM_PKG_LIST_FILE) then
        print("No package list file found at ".. CAPIM_PKG_LIST_FILE ..".")
        print("Downloading the file from [".. CAPIM_PKG_REMOTELOC .."]")
        if not updatePackageList() then
            error("No package list loaded!")
            return false
        end
    end

    local pfile = fs.open(CAPIM_PKG_LIST_FILE, "r")
    local state, tmpTable = parseJSON(pfile.readAll())
    pfile.close()
    if state then
        capimPackageTree = tmpTable
        capimPackageLoaded = true
    else
        error("Package list file is possibly broken. Check if it has correct format of JSON")
    end

    return state
end


-- recursively access to a deep key present in the table
--
-- @param table table      - target table
-- @param string key       - key present in the table
-- @param string delimeter - a character to separate path to the key
--
-- for instance, calling ({a = {b = "1"}}, "a.b", ".") will return 1
local function recursiveTableAccess(table, key, delimeter)
    local currentTablePointer = table
    while key:len() > 0 do
        local firstKey = key:match("^(.-)%..*$")
        currentTablePointer = currentTablePointer[firstKey]
        if currentTablePointer == nil then
            break
        end

        -- search deeper path
        key = key:match("^.-%.(.*)$")
    end
    return currentTablePointer
end


-- download and save package into local location
--
-- @param string path  - path of the package, must be absolute referrence
local function downloadPackage(path)
    local pPathLocal = CAPIM_REPO_DIR .. "/" .. path:gsub(".", "/")
    local pFile = fs.open(pPathLocal)
    -- TODO implementation
end

-- public:

-- set the path from which the package is searched first
--
-- @param string path  - path
function setDefaultPackageSpace(path)
    defaultPackageSpace = path
end


-- load package specified by the path
--
-- @param string path            - path in a package tree to the file
-- @param boolean isAbsolutePath - if the path is absolute
-- @returns boolean state        - true if the package is correctly loaded
--
-- path may be absolute or relative (from defaultpackagespace, only to a deeper location) specification,
-- but the relative path is searched former to the absolute locaiton
function loadPackage(path, isAbsolutePath)
    local pPath = (isAbsolutePath and "" or (defaultPackageSpace .. ".")) .. path
    local localFilePath = CAPIM_REPO_DIR .. "/" .. pPath:gsub(".", "/")

    if not fs.exists(localFilePath) then
        local dFileData = DownloadData(getPackageUrl(pPath))
        if not downloadPackage(pPath) then
            error("package " .. pPath .. " not found anywhere")
            return false
        end
    end

    local pFile = fs.open(localFilePath)
    -- TODO load package file to the required namespace
end
