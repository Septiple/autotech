local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local equipment_grid_node = object_node_base:create_object_class("equipment grid", node_types.equipment_grid_node)

function equipment_grid_node:register_dependencies(nodes)
end

return equipment_grid_node
