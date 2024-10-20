local object_types = require "nodes.object_types"
local object_node_functor = require "nodes.object_node_functor"
local requirement_node = require "nodes.requirement_node"
local planet_requirements = require "nodes.planet_requirements"

local planet_functor = object_node_functor:new(object_types.planet,
function (object, requirement_nodes)
    requirement_node:add_new_object_dependent_requirement(planet_requirements.visit, object, requirement_nodes, object.configuration)
end,
function (object, requirement_nodes, object_nodes)
end)
return planet_functor

-- if planet.entities_require_heating and defines.feature_flags.freezing then
--     self:add_dependency(nodes, node_types.electricity_node, 1, "requires a heat source", electricity_verbs.heat)
-- end

-- local mgs = planet.map_gen_settings
-- if not mgs then return end

-- self:add_disjunctive_dependent(nodes, node_types.entity_node, mgs.cliff_settings, "cliff autoplace", entity_verbs.instantiate, "name")
-- self:add_disjunctive_dependent(nodes, node_types.entity_node, mgs.territory_settings, "planet territory owner", entity_verbs.instantiate, "units")
-- for control in pairs(mgs.autoplace_controls or {}) do
--     self:add_disjunctive_dependent(nodes, node_types.autoplace_control_node, control, "autoplace control", "configure")
-- end

-- local autoplace_settings = mgs.autoplace_settings
-- if not autoplace_settings then return end

-- if autoplace_settings.entity then
--     for k, _ in pairs(autoplace_settings.entity.settings or {}) do
--         self:add_disjunctive_dependent(nodes, node_types.entity_node, k, "autoplace entity", entity_verbs.instantiate)
--     end
-- end

-- if autoplace_settings.tile then
--     for k, _ in pairs(autoplace_settings.tile.settings or {}) do
--         self:add_disjunctive_dependent(nodes, node_types.tile_node, k, "autoplace tile", tile_verbs.place)
--     end
-- end