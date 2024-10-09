local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local entity_verbs = require "verbs.entity_verbs"
local resource_category_verbs = require "verbs.resource_category_verbs"
local recipe_category_verbs = require "verbs.recipe_category_verbs"
local item_verbs = require "verbs.item_verbs"
local fluid_verbs = require "verbs.fluid_verbs"
local electricity_verbs = require "verbs.electricity_verbs"

local entity_node = object_node_base:create_object_class("entity", node_types.entity_node, function(self, nodes)
    local entity = self.object

    if entity.type == "resource" then
        self:add_dependency(nodes, node_types.resource_category_node, entity.category or "basic-solid", "resource category", "mine")
    elseif entity.type == "mining-drill" then
        self:add_disjunctive_dependent(nodes, node_types.resource_category_node, entity.resource_categories, "can mine", resource_category_verbs.instantiate)
    elseif entity.type == "offshore-pump" then
        self:add_disjunctive_dependent(nodes, node_types.fluid_node, entity.fluid, "pumps", fluid_verbs.create)
    end
    local minable = entity.minable
    if minable ~= nil then
        self:add_dependency(nodes, node_types.fluid_node, minable.required_fluid, "required fluid", "mine")
        self:add_productlike_disjunctive_dependent(nodes, minable.result, minable.results, "mining result")
    end
    self:add_disjunctive_dependent(nodes, node_types.entity_node, entity.remains_when_mined, "remains when mined", entity_verbs.instantiate)
    self:add_disjunctive_dependency(nodes, node_types.item_node, entity.placeable_by, "placeable by", entity_verbs.instantiate, "item")
    self:add_disjunctive_dependent(nodes, node_types.item_node, entity.loot, "loot", item_verbs.create, "item")
    self:add_disjunctive_dependent(nodes, node_types.entity_node, entity.corpse, "corpse", entity_verbs.instantiate)

    -- TODO: this code is problematic. What if a machine is unlocked after its module?
    -- But then we also need to support the pY case of the machine requiring the module to function at all.
    -- For now I have chosen to only support the pY case.
    for _, module_category in pairs(entity.allowed_module_categories or {}) do
        self:add_disjunctive_dependency(nodes, node_types.module_category_node, module_category, "allowed module category", module_category_verbs.requires)
    end

    if entity.energy_usage then
        self:add_dependency(nodes, node_types.electricity_node, 1, "requires electricity", "power")
    end
    if entity.energy_source then
        local energy_source = entity.energy_source
        local type = energy_source.type
        if type == "electric" then
            self:add_disjunctive_dependent(nodes, node_types.electricity_node, 1, "generates electricity", electricity_verbs.generate)
        elseif type == "burner" then
            self:add_disjunctive_dependency(nodes, node_types.fuel_category_node, energy_source.fuel_category, "requires fuel", entity_verbs.fuel)
            self:add_disjunctive_dependency(nodes, node_types.fuel_category_node, energy_source.fuel_categories, "requires fuel", entity_verbs.fuel)
        elseif type == "heat" then
        elseif type == "fluid" then
        else
            assert(type == "void", "Unknown energy source type")
        end
    end
    self:add_disjunctive_dependency(nodes, node_types.fuel_category_node, entity.burner, "requires fuel", entity_verbs.fuel, "fuel_category")
    self:add_disjunctive_dependent(nodes, node_types.recipe_category_node, entity.crafting_categories, "can craft", recipe_category_verbs.instantiate)

    if entity.type == "lab" then
        for _, science_pack in pairs(entity.inputs) do
            self:add_disjunctive_dependent(nodes, node_types.item_node, science_pack, "can research with", item_verbs.requires_specific_lab)
        end
    end

    local fluid_boxes = entity.fluid_boxes or {}
    if entity.fluid_box then table.insert(fluid_boxes, entity.fluid_box) end
    if entity.output_fluid_box then table.insert(fluid_boxes, entity.output_fluid_box) end
    for _, fluid_box in pairs(fluid_boxes) do
        if fluid_box.filter then
            if fluid_box.production_type == 'input' then
                self:add_dependency(nodes, node_types.fluid_node, fluid_box.filter, "requires fluid input", entity_verbs.required_fluid)
            elseif fluid_box.production_type == 'output' then
                self:add_disjunctive_dependent(nodes, node_types.fluid_node, fluid_box.filter, "produces fluid output", fluid_verbs.create)
            end
        end
    end

    if entity.type == 'plant' then
        self:add_disjunctive_dependency(nodes, node_types.entity_node, 1, "requires any agri tower prototype", entity_verbs.requires_agri_tower)
    elseif entity.type == 'agricultural-tower' then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, 1, "can grow", entity_verbs.requires_agri_tower)
    end

    if entity.type == "rocket-silo" or entity.type == "cargo-bay" or entity.type == "cargo-pod" then
        self:add_disjunctive_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
    elseif entity.type == "cargo-landing-pad" then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, 1, "can land rockets on", entity_verbs.requires_cargo_landing_pad)
    end

    if entity.type == "cargo-pod" and entity.spawned_container then
        self:add_disjunctive_dependent(nodes, node_types.entity_node, entity.spawned_container, "spawned container", entity_verbs.instantiate)
    end
end)

return entity_node
