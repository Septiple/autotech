---Uniquely identifies an object node
---@class ObjectNodeDescriptor
---@field name string
---@field object_type ObjectType
local object_node_descriptor = {}
object_node_descriptor.__index = object_node_descriptor

---@param name string
---@param object_type ObjectType
---@return ObjectNodeDescriptor
function object_node_descriptor:new(name, object_type)
    local result = {
        name = name,
        object_type = object_type,
    }
    setmetatable(result, self)
    return result
end

---@param object_type ObjectType
---@return ObjectNodeDescriptor
function object_node_descriptor:unique_node(object_type)
    local result = {
        name = object_type,
        object_type = object_type,
    }
    setmetatable(result, self)
    return result
end

function object_node_descriptor:valid()
    return self.name ~= nil
end

function object_node_descriptor:printable_name()
    return self.name .. " (" .. self.object_type .. ")"
end

return object_node_descriptor