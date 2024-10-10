local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local electricity_verbs = require "verbs.electricity_verbs"
local entity_verbs = require "verbs.entity_verbs"

local planet_node = object_node_base:create_object_class("planet", node_types.planet_node, function(self, nodes)
    local planet = self.object

    if planet.autotech_is_starting_planet then
        self:add_dependency(nodes, node_types.start_node, 1, "is the starting planet")
    end

    if planet.entities_require_heating and defines.feature_flags.freezing then
        self:add_dependency(nodes, node_types.electricity_node, 1, "requires a heat source", electricity_verbs.heat)
    end

    local mgs = planet.map_gen_settings
    if not mgs then return end

    if mgs.cliff_settings then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, mgs.cliff_settings.name, "cliff autoplace", entity_verbs.autoplace)
    end

    if mgs.territory_settings then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, mgs.territory_settings.units, "planet territory owner", entity_verbs.autoplace)
    end

    local autoplace_settings = mgs.autoplace_settings
    if not autoplace_settings then return end

    if autoplace_settings.entity then
        for k, _ in pairs(autoplace_settings.entity.settings or {}) do
            self:add_disjunctive_dependent(nodes, node_types.entity_node, k, "autoplace entity", entity_verbs.autoplace)
        end
    end
end)

return planet_node
