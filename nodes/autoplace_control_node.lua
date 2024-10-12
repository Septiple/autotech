local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local autoplace_control_node = object_node_base:create_object_class("autoplace control", node_types.autoplace_control_node, function(self, nodes)

end)

return autoplace_control_node
