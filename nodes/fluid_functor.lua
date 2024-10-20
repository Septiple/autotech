local object_types = require "nodes.object_types"
local object_node_functor = require "nodes.object_node_functor"
local requirement_node = require "nodes.requirement_node"
local requirement_types = require "nodes.requirement_types"
local fluid_requirements = require "nodes.fluid_requirements"

local fluid_functor = object_node_functor:new(object_types.fluid,
function (object, requirement_nodes)
    requirement_node:add_new_object_dependent_requirement(fluid_requirements.create, object, requirement_nodes, object.configuration)
end,
function (object, requirement_nodes, object_nodes)
    local fluid = object.object
    if fluid.fuel_value ~= nil then
        object_node_functor:add_fulfiller_for_independent_requirement(object, requirement_types.fluid_fuel, requirement_nodes)
    end
end)
return fluid_functor
