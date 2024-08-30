local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local electricity_node = object_node_base:create_object_class("electricity", node_types.electricity_node)

function electricity_node:register_dependencies(nodes)
end

return electricity_node
