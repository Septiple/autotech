local json = require "utils/json"
local autotech_class = require "new_auto_tech"

log = print

-- TODO: figure out the right file
local fileName = arg[1]

print("Starting test on " .. fileName)

local f = io.open(fileName, "rb")
if f == nil then
    print("Could not open file")
    return
end

print("Loading defines table...")
_G.defines = require "utils.defines"

print("Parsing data raw JSON...")
_G.data = {}
---@type string
local content_as_string = f:read("*all")
f:close()
data.raw = json.parse(content_as_string)

print("Invoking autotech data stage...")
require "data"

print("Invoking autotech...")

local autotech = autotech_class.create {verbose_logging = true}
autotech:run()

print("Finished test")
