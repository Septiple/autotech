local item_requirements = require "requirements.item_requirements"
local object_types = require "object_nodes.object_types"
local object_node_functor = require "object_nodes.object_node_functor"
local requirement_node = require "requirement_nodes.requirement_node"
local recipe_requirements = require "requirements.recipe_requirements"
local technology_requirements = require "requirements.technology_requirements"
local planet_requirements = require "requirements.planet_requirements"

local technology_functor = object_node_functor:new(object_types.technology,
function (object, requirement_nodes)
    local tech = object.object

    --requirement_node:add_new_object_dependent_requirement(technology_requirements.enable, object, requirement_nodes, object.configuration)
    requirement_node:add_new_object_dependent_requirement_table(tech.prerequisites, technology_requirements.prerequisite, object, requirement_nodes, object.configuration)

    if tech.unit then
        requirement_node:add_new_object_dependent_requirement(technology_requirements.researched_with, object, requirement_nodes, object.configuration)
        requirement_node:add_new_object_dependent_requirement_table(tech.unit.ingredients, technology_requirements.science_pack, object, requirement_nodes, object.configuration, 1)
    elseif tech.research_trigger then
        requirement_node:add_new_object_dependent_requirement(technology_requirements.trigger, object, requirement_nodes, object.configuration)
    end
end,
function (object, requirement_nodes, object_nodes)
    local tech = object.object

    object_node_functor:reverse_add_fulfiller_for_object_requirement_table(object, technology_requirements.prerequisite, tech.prerequisites, object_types.technology, object_nodes)

    for _, modifier in pairs(tech.effects or {}) do
        if modifier.type == "give-item" then
            object_node_functor:add_fulfiller_for_object_requirement(object, modifier.item, object_types.item, item_requirements.create, object_nodes)
        elseif modifier.type == "unlock-recipe" then
            object_node_functor:add_fulfiller_for_object_requirement(object, modifier.recipe, object_types.recipe, recipe_requirements.enable, object_nodes)
        elseif modifier.type == "unlock-space-location" then
            object_node_functor:add_fulfiller_for_object_requirement(object, modifier.space_location, object_types.planet, planet_requirements.visit, object_nodes)
        end
    end

    if tech.unit then
        object_node_functor:reverse_add_fulfiller_for_object_requirement_table(object, technology_requirements.science_pack, tech.unit.ingredients, object_types.item, object_nodes, 1)
    elseif tech.research_trigger then
        local trigger = tech.research_trigger
        if trigger.type == "mine-entity" or trigger.type == "build-entity" then
            object_node_functor:reverse_add_fulfiller_for_object_requirement(object, technology_requirements.trigger, trigger.entity, object_types.entity, object_nodes)
        elseif trigger.type == "craft-item" then
            object_node_functor:reverse_add_fulfiller_for_object_requirement(object, technology_requirements.trigger, trigger.item, object_types.item, object_nodes)
        elseif trigger.type == "craft-fluid" then
            object_node_functor:reverse_add_fulfiller_for_object_requirement(object, technology_requirements.trigger, trigger.fluid, object_types.fluid, object_nodes)
        elseif trigger.type == "send-item-to-orbit" then
            object_node_functor:reverse_add_fulfiller_for_object_requirement(object, technology_requirements.trigger, trigger.item, object_types.item, object_nodes)
            object_node_functor:add_independent_requirement_to_object(object, "rocket_silo", requirement_nodes)
        elseif trigger.type == "create-space-platform" then
            -- todo: technically this should be the rocket silo not the landing pad
            --self:add_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
        end
    end
end)
return technology_functor
