local object_types = require "nodes.object_types"

---@class ObjectNodeStorage
---@field nodes table<ObjectType, table<string, ObjectNode>>
local object_node_storage = {}
object_node_storage.__index = object_node_storage

---@return ObjectNodeStorage
function object_node_storage:new()
    local result = {
        nodes = {},
    }
    setmetatable(result, self)

    for _, object_type in pairs(object_types) do
        result.nodes[object_type] = {}
    end

    return result
end

---@param object_node ObjectNode
function object_node_storage:add_object_node(object_node)
    local descriptor = object_node.descriptor
    local table_for_type = self.nodes[descriptor.object_type]
    if table_for_type[descriptor.name] ~= nil then
        error("Duplicate object node " .. object_node.printable_name)
    end
    table_for_type[descriptor.name] = object_node
end

---@param descriptor ObjectNodeDescriptor
---@returns ObjectNode
function object_node_storage:find_object_node(descriptor)
    return self.nodes[descriptor.object_type][descriptor.name]
end

---@returns table<ObjectType, table<string, ObjectNode>>
function object_node_storage:all_nodes()
    return self.nodes
end

return object_node_storage
