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

local content_as_string = f:read("*all")
f:close()

print("Parsing JSON...")
local content = json.parse(content_as_string)

print("Invoking autotech...")

local autotech = autotech_class.create(content)
autotech:run()

print("Finished test")
