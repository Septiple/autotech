local object_types = require "nodes.object_types"
local object_node_functor = require "nodes.object_node_functor"
local requirement_node = require "nodes.requirement_node"
local requirement_types = require "nodes.requirement_types"
local technology_requirements = require "nodes.technology_requirements"

local technology_functor = object_node_functor:new(object_types.technology,
function (object, requirement_nodes)
    requirement_node:add_new_object_dependent_requirement(technology_requirements.enable, object, requirement_nodes, object.configuration)
    requirement_node:add_new_object_dependent_requirement(technology_requirements.researched_with, object, requirement_nodes, object.configuration)
end,
function (object, requirement_nodes, object_nodes)
end)
return technology_functor

-- local tech = self.object

-- self:add_dependency(nodes, node_types.technology_node, tech.prerequisites, "prerequisite", technology_verbs.enable)

-- for _, modifier in pairs(tech.effects or {}) do
--     if modifier.type == "give-item" then
--         self:add_disjunctive_dependent(nodes, node_types.item_node, modifier.item, "given by tech", item_verbs.create)
--     elseif modifier.type == "unlock-recipe" then
--         self:add_disjunctive_dependent(nodes, node_types.recipe_node, modifier.recipe, "enabled by tech", recipe_verbs.enable)
--     elseif modifier.type == "unlock-space-location" then
--         self:add_disjunctive_dependent(nodes, node_types.planet_node, modifier.space_location, "unlocked by tech", planet_verbs.visit)
--     end
-- end

-- if tech.unit then
--     for _, ingredient in pairs(tech.unit.ingredients or {}) do
--         self:add_dependency(nodes, node_types.item_node, ingredient[1], "required science pack", technology_verbs.researched_with)
--     end
-- elseif tech.research_trigger then
--     local trigger = tech.research_trigger
--     if trigger.type == "mine-entity" or trigger.type == "build-entity" then
--         self:add_dependency(nodes, node_types.entity_node, trigger.entity, "researched by mining", technology_verbs.researched_with)
--     elseif trigger.type == "craft-item" then
--         self:add_dependency(nodes, node_types.item_node, trigger.item, "researched by crafting", technology_verbs.researched_with)
--     elseif trigger.type == "craft-fluid" then
--         self:add_dependency(nodes, node_types.fluid_node, trigger.fluid, "researched by crafting", technology_verbs.researched_with)
--     elseif trigger.type == "send-item-to-orbit" then
--         self:add_dependency(nodes, node_types.item_node, trigger.item, "researched by sending to orbit", technology_verbs.researched_with)
--         self:add_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
--     elseif trigger.type == "create-space-platform" then
--         -- todo: technically this should be the rocket silo not the landing pad
--         self:add_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
--     end
-- end
