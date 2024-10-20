local object_types = require "nodes.object_types"
local object_node_functor = require "nodes.object_node_functor"
local requirement_node = require "nodes.requirement_node"
local requirement_types = require "nodes.requirement_types"
local item_requirements = require "nodes.item_requirements"
local entity_requirements = require "nodes.entity_requirements"

local tile_functor = object_node_functor:new(object_types.tile,
function (object, requirement_nodes)
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
