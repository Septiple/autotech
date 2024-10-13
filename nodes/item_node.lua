local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local entity_verbs = require "verbs.entity_verbs"
local item_verbs = require "verbs.item_verbs"
local fuel_category_verbs = require "verbs.fuel_category_verbs"
local equipment_grid_verbs = require "verbs.equipment_grid_verbs"
local module_category_verbs = require "verbs.module_category_verbs"
local ammo_category_verbs = require "verbs.ammo_category_verbs"
local tile_verbs = require "verbs.tile_verbs"

local item_node = object_node_base:create_object_class("item", node_types.item_node, function(self, nodes)
    local item = self.object
    
    self:add_disjunctive_dependent(nodes, node_types.entity_node, item.place_result, "place result", entity_verbs.instantiate)
    self:add_disjunctive_dependent(nodes, node_types.fuel_category_node, item.fuel_category, "fuel category", fuel_category_verbs.instantiate)

    self:add_disjunctive_dependent(nodes, node_types.item_node, item.burnt_result, "burnt result", item_verbs.create)
    self:add_disjunctive_dependent(nodes, node_types.item_node, item.spoil_result, "spoil result", item_verbs.create)
    self:add_disjunctive_dependent(nodes, node_types.entity_node, item.plant_result, "plant result", entity_verbs.instantiate)

    self:add_disjunctive_dependent(nodes, node_types.item_node, item.rocket_launch_products, "rocket launch product", item_verbs.create, "name")
    if item.rocket_launch_products then
        self:add_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
    end

    if item.type == "armor" then
        self:add_disjunctive_dependent(nodes, node_types.equipment_grid_node, item.equipment_grid, "equipment grid", equipment_grid_verbs.instantiate)

    elseif item.type == "ammo" then
        self:add_disjunctive_dependent(nodes, node_types.ammo_category_node, item.ammo_category, "ammo category", ammo_category_verbs.fires)
        
    elseif item.type == "gun" and item.attack_parameters then
        self:add_dependency(nodes, node_types.ammo_category_node, item.attack_parameters.ammo_categories or item.attack_parameters.ammo_category, "ammo category", ammo_category_verbs.fires)

    elseif item.type == "module" then
        self:add_disjunctive_dependent(nodes, node_types.module_category_node, item.category, "module category", module_category_verbs.requires)

    elseif item.type == "space-platform-starter-pack" then
        self:add_disjunctive_dependent(nodes, node_types.item_node, item.initial_items, "initial item in the space platform starter pack", item_verbs.create, "name")

    elseif item.type == "rail-planner" then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, item.rails, "rail", entity_verbs.instantiate)
    end

    if item.place_as_tile then
        self:add_disjunctive_dependent(nodes, node_types.tile_node, item.place_as_tile.result, "place as tile result", tile_verbs.place)
    end

    --placed_as_equipment_result optional 	:: EquipmentID
end)

return item_node
