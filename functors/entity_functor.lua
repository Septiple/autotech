local object_types = require "object_nodes.object_types"
local object_node_functor = require "object_nodes.object_node_functor"
local requirement_node = require "requirement_nodes.requirement_node"
local requirement_types = require "requirement_nodes.requirement_types"
local item_requirements = require "requirements.item_requirements"
local entity_requirements = require "requirements.entity_requirements"
local fluid_requirements = require "requirements.fluid_requirements"
local technology_requirements = require "requirements.technology_requirements"

-- local is_nonelevated_rail = {
--     ["curved-rail-a"] = true,
--     ["curved-rail-b"] = true,
--     ["half-diagonal-rail"] = true,
--     ["straight-rail"] = true,
-- }

-- local is_elevated_rail = {
--     ["elevated-curved-rail-a"] = true,
--     ["elevated-curved-rail-b"] = true,
--     ["elevated-half-diagonal-rail"] = true,
--     ["elevated-straight-rail"] = true,
-- }

-- local requires_rail_to_build = {
--     ["locomotive"] = true,
--     ["cargo-wagon"] = true,
--     ["fluid-wagon"] = true,
--     ["artillery-wagon"] = true,
--     ["rail-signal"] = true,
--     ["rail-chain-signal"] = true,
--     ["train-stop"] = true,
-- }

-- local is_energy_generator = {
--     ["fusion-generator"] = true,
--     ["solar-panel"] = true,
--     ["burner-generator"] = true,
--     ["generator"] = true,
--     ["electric-energy-interface"] = true,
--     ["lightning-attractor"] = true,
-- }

local entity_functor = object_node_functor:new(object_types.entity,
function (object, requirement_nodes)
    local entity = object.object
    requirement_node:add_new_object_dependent_requirement(entity_requirements.instantiate, object, requirement_nodes, object.configuration)

    local minable = entity.minable
    if minable ~= nil then
        if minable.required_fluid then
            requirement_node:add_new_object_dependent_requirement(entity_requirements.required_fluid, object, requirement_nodes, object.configuration)
        end
    end
end,
function (object, requirement_nodes, object_nodes)
    local entity = object.object
    if entity.type == "resource" then
        object_node_functor:add_typed_requirement_to_object(object, entity.category or "basic-solid", requirement_types.resource_category, requirement_nodes)
    elseif entity.type == "mining-drill" then
        object_node_functor:add_fulfiller_for_typed_requirement(object, entity.resource_categories, requirement_types.resource_category, requirement_nodes)
    elseif entity.type == "offshore-pump" then
        object_node_functor:add_fulfiller_for_object_requirement(object, entity.fluid, object_types.fluid, fluid_requirements.create, object_nodes)
    end
    
    local minable = entity.minable
    if minable ~= nil then
        --self:add_dependency(nodes, node_types.fluid_node, minable.required_fluid, "required fluid", "mine")
        object_node_functor:add_fulfiller_to_productlike_object(object, minable.results or minable.result, object_nodes)
        if minable.required_fluid then
            object_node_functor:reverse_add_fulfiller_for_object_requirement(object, entity_requirements.required_fluid, minable.required_fluid, object_types.fluid, object_nodes)
        end
    end
    
    object_node_functor:add_fulfiller_for_object_requirement(object, entity.remains_when_mined, object_types.entity, entity_requirements.instantiate, object_nodes)
    if entity.placeable_by then
        object_node_functor:reverse_add_fulfiller_for_object_requirement(object, entity_requirements.instantiate, entity.placeable_by.item, object_types.item, object_nodes)
    end
    object_node_functor:add_fulfiller_for_object_requirement(object, entity.loot, object_types.item, item_requirements.create, object_nodes)
    object_node_functor:add_fulfiller_for_object_requirement(object, entity.corpse, object_types.entity, entity_requirements.instantiate, object_nodes)

    -- Support for PyAL-style module requirements
    if entity.autotech_force_require_module_categories then
        object_node_functor:add_typed_requirement_to_object(object, entity.allowed_module_categories, requirement_types.module_category, requirement_nodes)
    end

--     if entity.energy_source then
--         local energy_source = entity.energy_source
--         local type = energy_source.type
--         if type == "electric" then
--             if is_energy_generator[entity.type] then
--                 self:add_disjunctive_dependent(nodes, node_types.electricity_node, 1, "generates electricity", electricity_verbs.generate)
--             else
--                 self:add_dependency(nodes, node_types.electricity_node, 1, "requires energy", entity_verbs.power)
--             end
--         elseif type == "burner" then
--             self:add_disjunctive_dependency(nodes, node_types.fuel_category_node, energy_source.fuel_category, "requires fuel", entity_verbs.fuel)
--             self:add_disjunctive_dependency(nodes, node_types.fuel_category_node, energy_source.fuel_categories, "requires fuel", entity_verbs.fuel)
--         elseif type == "heat" then
--             self:add_dependency(nodes, node_types.electricity_node, "heat", "requires a heat source", entity_verbs.heat)
--         elseif type == "fluid" then
--         else
--             assert(type == "void", "Unknown energy source type")
--         end
--     end

--     if entity.burner then
--         self:add_disjunctive_dependency(nodes, node_types.fuel_category_node, entity.burner.fuel_categories, "requires fuel", entity_verbs.fuel)
--     end
    object_node_functor:add_fulfiller_for_typed_requirement(object, entity.crafting_categories, requirement_types.recipe_category, requirement_nodes)

    --     local fluid_boxes = entity.fluid_boxes or {}
    --     if entity.fluid_box then table.insert(fluid_boxes, entity.fluid_box) end
    --     if entity.output_fluid_box then table.insert(fluid_boxes, entity.output_fluid_box) end
    --     for _, fluid_box in pairs(fluid_boxes) do
    --         if fluid_box.filter then
    --             if fluid_box.production_type == "input" then
    --                 self:add_dependency(nodes, node_types.fluid_node, fluid_box.filter, "requires fluid input", entity_verbs.required_fluid)
    --             elseif fluid_box.production_type == "output" then
    --                 self:add_disjunctive_dependent(nodes, node_types.fluid_node, fluid_box.filter, "produces fluid output", fluid_verbs.create)
    --             end
    --         end
    --     end
    
    --     if entity.type == "reactor" or entity.type == "heat-interface" then
    --         self:add_disjunctive_dependent(nodes, node_types.electricity_node, "heat", "generates heat", electricity_verbs.heat)
    --     end

    if entity.type == "lab" then
        local inputs = entity.inputs
        local input_lookup = {}
        for _, input in pairs(inputs) do
            input_lookup[input] = true
        end
        for _, technology_node in pairs(object_nodes.nodes[object_types.technology]) do
            local technology = technology_node.object
            if technology.unit ~= nil then
                local matches = true
                for _, ingredientPair in pairs(technology.unit.ingredients) do
                    if input_lookup[ingredientPair[1]] ~= true then
                        matches = false
                        break
                    end
                end
                if matches then
                    technology_node.requirements[technology_requirements.researched_with]:add_fulfiller(object)
                end
            end
        end
    end

    --     if entity.type == "plant" then
    --         self:add_disjunctive_dependency(nodes, node_types.entity_node, 1, "requires any agri tower prototype", entity_verbs.requires_agri_tower)
    --     elseif entity.type == "agricultural-tower" then
    --         self:add_disjunctive_dependent(nodes, node_types.entity_node, 1, "can grow", entity_verbs.requires_agri_tower)
    --     end
    
    --     if entity.type == "rocket-silo" or entity.type == "cargo-bay" or entity.type == "cargo-pod" then
    --         self:add_disjunctive_dependency(nodes, node_types.entity_node, 1, "requires any cargo-landing-pad prototype", entity_verbs.requires_cargo_landing_pad)
    --     elseif entity.type == "cargo-landing-pad" then
    --         self:add_disjunctive_dependent(nodes, node_types.entity_node, 1, "can land rockets on", entity_verbs.requires_cargo_landing_pad)
    --     end
    if entity.type == "rocket-silo" then
        object_node_functor:add_fulfiller_for_independent_requirement(object, requirement_types.rocket_silo, requirement_nodes)
    end
    if entity.type == "cargo-landing-pad" then
        object_node_functor:add_fulfiller_for_independent_requirement(object, requirement_types.cargo_landing_pad, requirement_nodes)
    end
    
    --     if entity.type == "cargo-pod" then
    --         self:add_disjunctive_dependent(nodes, node_types.entity_node, entity.spawned_container, "spawned container", entity_verbs.instantiate)
    --     end
    
    --     if is_elevated_rail[entity.type] then
    --         self:add_dependency(nodes, node_types.entity_node, 1, "requires any rail-support prototype", entity_verbs.requires_rail_supports)
    --         self:add_dependency(nodes, node_types.entity_node, 1, "requires any rail-ramp prototype", entity_verbs.requires_rail_ramp)
    --     elseif entity.type == "rail-support" then
    --         self:add_disjunctive_dependent(nodes, node_types.entity_node, 1, "requires any rail-support prototype", entity_verbs.requires_rail_supports)
    --     elseif entity.type == "rail-ramp" then
    --         self:add_disjunctive_dependent(nodes, node_types.entity_node, 1, "requires any rail-ramp prototype", entity_verbs.requires_rail_ramp)
    --     end
    
    --     if is_elevated_rail[entity.type] or is_nonelevated_rail[entity.type] then
    --         self:add_disjunctive_dependent(nodes, node_types.entity_node, 1, "requires any rail prototype", entity_verbs.requires_rail)
    --     elseif requires_rail_to_build[entity.type] then
    --         self:add_dependency(nodes, node_types.entity_node, 1, "requires any rail prototype", entity_verbs.requires_rail)
    --     end
    
    --     if entity.autoplace then
    --         self:add_disjunctive_dependency(nodes, node_types.autoplace_control_node, entity.autoplace.control, "autoplace control", "configure")
    --     end
end)
return entity_functor
