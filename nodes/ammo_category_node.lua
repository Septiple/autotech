local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local ammo_category_node = object_node_base:create_object_class("ammo category", node_types.ammo_category_node, function(self, nodes)

end)

return ammo_category_node
