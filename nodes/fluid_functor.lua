local object_types = require "nodes.object_types"
local object_node_functor = require "nodes.object_node_functor"
local requirement_node = require "nodes.requirement_node"
local requirement_types = require "nodes.requirement_types"
local item_requirements = require "nodes.item_requirements"
local entity_requirements = require "nodes.entity_requirements"

local fluid_functor = object_node_functor:new(object_types.fluid,
function (object, requirement_nodes)
end,
function (object, requirement_nodes, object_nodes)
end)
return fluid_functor

-- if fluid.fuel_value ~= nil then
--     self:add_disjunctive_dependent(nodes, node_types.fluid_fuel_node, 1, "fuel value", fluid_fuel_verbs.instantiate)
-- end
