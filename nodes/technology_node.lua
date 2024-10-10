local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local item_verbs = require "verbs.item_verbs"
local recipe_verbs = require "verbs.recipe_verbs"
local planet_verbs = require "verbs.planet_verbs"
local technology_verbs = require "verbs.technology_verbs"
local entity_verbs = require "verbs.entity_verbs"

local technology_node = object_node_base:create_object_class("technology", node_types.technology_node, function(self, nodes)
    local tech = self.object

    self:add_dependency(nodes, node_types.technology_node, tech.prerequisites, "prerequisite", technology_verbs.enable)

    for _, modifier in pairs(tech.effects or {}) do
        if modifier.type == "give-item" then
            self:add_disjunctive_dependent(nodes, node_types.item_node, modifier.item, "given by tech", item_verbs.create)
        elseif modifier.type == "unlock-recipe" then
            self:add_disjunctive_dependent(nodes, node_types.recipe_node, modifier.recipe, "enabled by tech", recipe_verbs.enable)
        elseif modifier.type == "unlock-space-location" then
            self:add_disjunctive_dependent(nodes, node_types.planet_node, modifier.space_location, "unlocked by tech", planet_verbs.visit)
        end
    end

    if tech.unit then
        for _, ingredient in pairs(tech.unit.ingredients or {}) do
            self:add_dependency(nodes, node_types.item_node, ingredient[1], "required science pack", technology_verbs.researched_with)
        end
    elseif tech.research_trigger then
        local trigger = tech.research_trigger
        if trigger.type == "mine-entity" or trigger.type == "build-entity" then
            self:add_dependency(nodes, node_types.entity_node, trigger.entity, "researched by mining", technology_verbs.researched_with)
        elseif trigger.type == "craft-item" then
            self:add_dependency(nodes, node_types.item_node, trigger.item, "researched by crafting", technology_verbs.researched_with)
        elseif trigger.type == "craft-fluid" then
            self:add_dependency(nodes, node_types.fluid_node, trigger.fluid, "researched by crafting", technology_verbs.researched_with)
        elseif trigger.type == "send-item-to-orbit" then
            self:add_dependency(nodes, node_types.item_node, trigger.item, "researched by sending to orbit", technology_verbs.researched_with)
            self:add_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
        elseif trigger.type == "create-space-platform" then
            -- todo: technically this should be the rocket silo not the landing pad
            self:add_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
        end
    end
end)

return technology_node
