local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local entity_verbs = require "verbs.entity_verbs"
local item_verbs = require "verbs.item_verbs"
local fuel_category_verbs = require "verbs.fuel_category_verbs"
local equipment_grid_verbs = require "verbs.equipment_grid_verbs"
local module_category_verbs = require "verbs.module_category_verbs"

local item_node = object_node_base:create_object_class("item", node_types.item_node, function(self, nodes)
    local item = self.object
    
    self:add_disjunctive_dependent(nodes, node_types.entity_node, item.place_result, "place result", entity_verbs.instantiate)
    self:add_disjunctive_dependent(nodes, node_types.fuel_category_node, item.fuel_category, "fuel category", fuel_category_verbs.instantiate)

    self:add_disjunctive_dependent(nodes, node_types.item_node, item.burnt_result, "burnt result", item_verbs.create)
    self:add_disjunctive_dependent(nodes, node_types.item_node, item.spoil_result, "spoil result", item_verbs.create)
    self:add_disjunctive_dependent(nodes, node_types.entity_node, item.plant_result, "plant result", entity_verbs.plants)

    for _, rocket_launch_product in pairs(item.rocket_launch_products or {}) do
        self:add_disjunctive_dependent(nodes, node_types.item_node, rocket_launch_product.name, "rocket launch product", item_verbs.create)
        self:add_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
    end

    if item.type == "armor" then
        self:add_disjunctive_dependent(nodes, node_types.equipment_grid_node, item.equipment_grid, "equipment grid", equipment_grid_verbs.instantiate)

    elseif item.type == "ammo" then
        self:add_disjunctive_dependent(nodes, node_types.ammo_category_node, item.ammo_category, "ammo category", ammo_category_verbs.fires)
        
    elseif item.type == "gun" and item.attack_parameters then
        local ammo_categories = item.attack_parameters.ammo_categories or {item.attack_parameters.ammo_category}
        self:add_dependency(nodes, node_types.ammo_category_node, ammo_categories, "ammo category", ammo_category_verbs.fires)

    elseif item.type == "module" and item.category then
        self:add_disjunctive_dependent(nodes, node_types.module_category_node, item.category, "module category", module_category_verbs.requires)

    elseif item.type == "space-platform-starter-pack" then
        self:add_disjunctive_dependent(nodes, node_types.item_node, item.initial_items, "initial item in the space platform starter pack", item_verbs.create, "name")

    elseif item.type == "rail-planner" then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, item.rails, "rail", entity_verbs.instantiate)
    end

    --placed_as_equipment_result optional 	:: EquipmentID
end)

return item_node
