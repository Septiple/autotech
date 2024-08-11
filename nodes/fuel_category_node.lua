local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local fuel_category_node = object_node_base:create_object_class("fuel category", node_types.fuel_category_node)

function fuel_category_node:register_dependencies(nodes)
end

return fuel_category_node
