local object_node_base = require object_nodes".object_node_base"
local node_types = require "nodes.node_types"

local start_node = object_node_base:create_object_class("start", node_types.start_node, function(self, nodes)
    
end)

return start_node
