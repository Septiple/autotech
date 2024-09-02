local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local fluid_fuel_node = object_node_base:create_object_class("fluid fuel", node_types.fluid_fuel_node, function(self, nodes)
    
end)

return fluid_fuel_node
