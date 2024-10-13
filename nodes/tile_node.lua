local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local fluid_verbs = require "verbs.fluid_verbs"
local item_verbs = require "verbs.item_verbs"
local tile_verbs = require "verbs.tile_verbs"

local tile_node = object_node_base:create_object_class("tile", node_types.tile_node, function(self, nodes)
    local tile = self.object

    self:add_disjunctive_dependent(nodes, node_types.fluid_node, tile.fluid, "offshore pump", fluid_verbs.create)
    self:add_disjunctive_dependent(nodes, node_types.tile_node, tile.next_direction, "tile rotation", tile_verbs.place)

    local minable = tile.minable
    if minable ~= nil then
        self:add_productlike_disjunctive_dependent(nodes, minable.result, minable.results, item_verbs.create)
    end

    if defines.feature_flags.freezing then
        self:add_disjunctive_dependent(nodes, node_types.tile_node, tile.frozen_variant, "freezing", tile_verbs.place)
        self:add_disjunctive_dependent(nodes, node_types.tile_node, tile.thawed_variant, "thawing", tile_verbs.place)
    end
end)

return tile_node
