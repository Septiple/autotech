local object_types = require "object_nodes.object_types"
local object_node_functor = require "object_nodes.object_node_functor"
local requirement_node = require "requirement_nodes.requirement_node"
local requirement_types = require "requirement_nodes.requirement_types"
local tile_requirements = require "requirements.tile_requirements"

local tile_functor = object_node_functor:new(object_types.tile,
function (object, requirement_nodes)
    requirement_node:add_new_object_dependent_requirement(tile_requirements.place, object, requirement_nodes, object.configuration)
end,
function (object, requirement_nodes, object_nodes)
end)
return tile_functor

-- self:add_disjunctive_dependent(nodes, node_types.fluid_node, tile.fluid, "offshore pump", fluid_verbs.create)
-- self:add_disjunctive_dependent(nodes, node_types.tile_node, tile.next_direction, "tile rotation", tile_verbs.place)

-- local minable = tile.minable
-- if minable ~= nil then
--     self:add_productlike_disjunctive_dependent(nodes, minable.result, minable.results, item_verbs.create)
-- end

-- if defines.feature_flags.freezing then
--     self:add_disjunctive_dependent(nodes, node_types.tile_node, tile.frozen_variant, "freezing", tile_verbs.place)
--     self:add_disjunctive_dependent(nodes, node_types.tile_node, tile.thawed_variant, "thawing", tile_verbs.place)
-- end
