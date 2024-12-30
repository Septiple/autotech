local object_types = require "object_nodes.object_types"
local object_node_functor = require "object_nodes.object_node_functor"
local requirement_node = require "requirement_nodes.requirement_node"
local requirement_types = require "requirement_nodes.requirement_types"
local item_requirements = require "requirements.item_requirements"
local entity_requirements = require "requirements.entity_requirements"

local item_functor = object_node_functor:new(object_types.item,
function (object, requirement_nodes)
    requirement_node:add_new_object_dependent_requirement(item_requirements.create, object, requirement_nodes, object.configuration)
end,
function (object, requirement_nodes, object_nodes)
    local item = object.object
    object_node_functor:add_fulfiller_for_object_requirement(object, item.place_result, object_types.entity, entity_requirements.instantiate, object_nodes)
    object_node_functor:add_fulfiller_for_typed_requirement(object, item.fuel_category, requirement_types.fuel_category, requirement_nodes)

    object_node_functor:add_fulfiller_for_object_requirement(object, item.burnt_result, object_types.item, item_requirements.create, object_nodes)
    object_node_functor:add_fulfiller_for_object_requirement(object, item.spoil_result, object_types.item, item_requirements.create, object_nodes)
    object_node_functor:add_fulfiller_for_object_requirement(object, item.plant_result, object_types.entity, entity_requirements.instantiate, object_nodes)
    object_node_functor:add_fulfiller_for_object_requirement(object, item.rocket_launch_products, object_types.item, item_requirements.create, object_nodes)

end)
return item_functor

--     self:add_disjunctive_dependent(nodes, node_types.item_node, item.rocket_launch_products, "rocket launch product", item_verbs.create, "name")
--     if item.rocket_launch_products then
--         self:add_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
--     end

--     if item.type == "armor" then
--         self:add_disjunctive_dependent(nodes, node_types.equipment_grid_node, item.equipment_grid, "equipment grid", equipment_grid_verbs.instantiate)

--     elseif item.type == "ammo" then
--         self:add_disjunctive_dependent(nodes, node_types.ammo_category_node, item.ammo_category, "ammo category", ammo_category_verbs.fires)
        
--     elseif item.type == "gun" and item.attack_parameters then
--         self:add_dependency(nodes, node_types.ammo_category_node, item.attack_parameters.ammo_categories or item.attack_parameters.ammo_category, "ammo category", ammo_category_verbs.fires)

--     elseif item.type == "module" then
--         self:add_disjunctive_dependent(nodes, node_types.module_category_node, item.category, "module category", module_category_verbs.requires)

--     elseif item.type == "space-platform-starter-pack" then
--         self:add_disjunctive_dependent(nodes, node_types.item_node, item.initial_items, "initial item in the space platform starter pack", item_verbs.create, "name")

--     elseif item.type == "rail-planner" then
--         self:add_disjunctive_dependent(nodes, node_types.entity_node, item.rails, "rail", entity_verbs.instantiate)
--     end

--     if item.place_as_tile then
--         self:add_disjunctive_dependent(nodes, node_types.tile_node, item.place_as_tile.result, "place as tile result", tile_verbs.place)
--     end

--     --placed_as_equipment_result optional 	:: EquipmentID
-- end)