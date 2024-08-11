local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local resource_category_node = object_node_base:create_object_class("resource category", node_types.resource_category_node)

function resource_category_node:register_dependencies(nodes)
end

return resource_category_node
