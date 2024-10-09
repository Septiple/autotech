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
    --placed_as_equipment_result optional 	:: EquipmentID
    self:add_disjunctive_dependent(nodes, node_types.fuel_category_node, item.fuel_category, "fuel category", fuel_category_verbs.instantiate)

    self:add_disjunctive_dependent(nodes, node_types.item_node, item.burnt_result, "burnt result", item_verbs.create)
    self:add_disjunctive_dependent(nodes, node_types.item_node, item.spoil_result, "spoil result", item_verbs.create)
    self:add_disjunctive_dependent(nodes, node_types.entity_node, item.plant_result, "plant result", entity_verbs.plants)

    for _, rocket_launch_product in pairs(item.rocket_launch_products or {}) do
        self:add_disjunctive_dependent(nodes, node_types.item_node, rocket_launch_product.name, "rocket launch product", item_verbs.create)
    end


    if item.type == "armor" then
        self:add_disjunctive_dependent(nodes, node_types.equipment_grid_node, item.equipment_grid, "equipment grid", equipment_grid_verbs.instantiate)

    elseif item.type == "ammo" and item.ammo_category then
        self:add_disjunctive_dependent(nodes, node_types.ammo_category_node, item.ammo_category, "ammo category", ammo_category_verbs.fires)
        
    elseif item.type == "gun" and item.attack_parameters then
        if item.attack_parameters.ammo_categories then
            for _, ammo_category in pairs(item.attack_parameters.ammo_categories) do
                self:add_dependency(nodes, node_types.ammo_category_node, ammo_category, "ammo category", ammo_category_verbs.fires)
            end
        elseif item.attack_parameters.ammo_category then
            self:add_dependency(nodes, node_types.ammo_category_node, item.attack_parameters.ammo_category, "ammo category", ammo_category_verbs.fires)
        end

    elseif item.type == "module" and item.category then
        self:add_disjunctive_dependent(nodes, node_types.module_category_node, item.category, "module category", module_category_verbs.requires)

    elseif item.type == "space-platform-starter-pack" then
        for _, inital_item in pairs(item.initial_items or {}) do
            self:add_disjunctive_dependent(nodes, node_types.item_node, inital_item.name, "initial item in the space platform starter pack", item_verbs.create)
        end

    end
end)

return item_node
