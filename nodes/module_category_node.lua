local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local module_category_node = object_node_base:create_object_class("module category", node_types.module_category_node, function(self, nodes)

end)

return module_category_node
