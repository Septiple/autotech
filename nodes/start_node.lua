local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local start_node = object_node_base:create_unique_class("start", node_types.start_node)

function start_node:register_dependencies(nodes)
end

return start_node
