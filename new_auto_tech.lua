--- @module "definitions"

local deque = require "utils.deque"

local object_node = require "object_nodes.object_node"
local object_types = require "object_nodes.object_types"
local object_node_descriptor = require "object_nodes.object_node_descriptor"
local object_node_storage = require "object_nodes.object_node_storage"
local requirement_node = require "requirement_nodes.requirement_node"
local requirement_types = require "requirement_nodes.requirement_types"
local requirement_node_storage = require "requirement_nodes.requirement_node_storage"

local entity_functor = require "functors.entity_functor"
local fluid_functor = require "functors.fluid_functor"
local item_functor = require "functors.item_functor"
local planet_functor = require "functors.planet_functor"
local recipe_functor = require "functors.recipe_functor"
local technology_functor = require "functors.technology_functor"
local tile_functor = require "functors.tile_functor"

---@type table<ObjectType, ObjectNodeFunctor>
local functor_map = {}
functor_map[object_types.entity] = entity_functor
functor_map[object_types.fluid] = fluid_functor
functor_map[object_types.item] = item_functor
functor_map[object_types.planet] = planet_functor
functor_map[object_types.recipe] = recipe_functor
functor_map[object_types.technology] = technology_functor
functor_map[object_types.tile] = tile_functor

--- @class auto_tech
--- @field private configuration Configuration
--- @field private object_nodes ObjectNodeStorage
--- @field private requirement_nodes RequirementNodeStorage
local auto_tech = {}
auto_tech.__index = auto_tech

---@param configuration Configuration
---@return auto_tech
function auto_tech.create(configuration)
    local result = {}
    setmetatable(result, auto_tech)

    result.configuration = configuration
    result.object_nodes = object_node_storage:new()
    result.requirement_nodes = requirement_node_storage:new()
    return result
end

function auto_tech:run_phase(phase_function, phase_name)
    log("Starting " .. phase_name)
    phase_function(self)
    log("Finished " .. phase_name)
end

function auto_tech:run()
    -- TODO:
    -- armor and gun stuff, military entities
    -- ignore soot results
    -- miner with fluidbox
    -- resources on map
    -- fluid boxes on crafting entities
    -- modules on crafting entities
    -- robots and roboports
    -- heat
    -- labs
    -- temperatures for fluids, boilers
    -- techs enabled at start

    -- nodes to finish:
    -- tech

    -- nodes finished:
    -- recipe
    -- item
    -- fluid
    -- resource

    self:run_phase(function()
        self:run_phase(self.create_nodes, "recipe graph node creation")
        self:run_phase(self.link_nodes, "recipe graph link creation")
        self:run_phase(self.linearise_recipe_graph, "recipe graph linearisation")
        self:run_phase(self.verify_end_tech_reachable, "verify end tech reachable")
        self:run_phase(self.construct_tech_graph, "constructing tech graph")
        self:run_phase(self.linearise_tech_graph, "tech graph linearisation")
        self:run_phase(self.calculate_transitive_reduction, "transitive reduction calculation")
        self:run_phase(self.adapt_tech_links, "adapting tech links")
        self:run_phase(self.set_tech_costs, "tech cost setting")
    end, "autotech")
end

function auto_tech:create_nodes()
    object_node:new({name="start"}, object_node_descriptor:unique_node(object_types.start), self.object_nodes, self.configuration)
    requirement_node:new_independent_requirement(requirement_types.electricity, self.requirement_nodes, self.configuration)
    requirement_node:new_independent_requirement(requirement_types.fluid_with_fuel_value, self.requirement_nodes, self.configuration)
    requirement_node:new_independent_requirement(requirement_types.heat, self.requirement_nodes, self.configuration)

    ---@param table FactorioThingGroup
    ---@param requirement_type RequirementType
    local function process_requirement_type(table, requirement_type)
        for _, requirement in pairs(table or {}) do
            requirement_node:new_typed_requirement(requirement.name, requirement_type, self.requirement_nodes, self.configuration)
        end
    end

    ---@param table FactorioThingGroup
    ---@param functor ObjectNodeFunctor
    local function process_object_type(table, functor)
        for _, object in pairs(table or {}) do
            local object_node = object_node:new(object, object_node_descriptor:new(object.name, functor.object_type), self.object_nodes, self.configuration)
            functor.register_requirements_func(object_node, self.requirement_nodes)
        end
    end

    process_requirement_type(data.raw["ammo-category"], requirement_types.ammo_category)
    process_requirement_type(data.raw["equipment-grid"], requirement_types.equipment_grid)
    process_requirement_type(data.raw["fuel-category"], requirement_types.fuel_category)
    process_requirement_type(data.raw["recipe-category"], requirement_types.recipe_category)
    process_requirement_type(data.raw["resource-category"], requirement_types.resource_category)
    process_requirement_type(data.raw["autoplace-control"], requirement_types.autoplace_control)

    process_object_type(data.raw["fluid"], fluid_functor)
    process_object_type(data.raw["recipe"], recipe_functor)
    process_object_type(data.raw["technology"], technology_functor)
    process_object_type(data.raw["planet"], planet_functor)
    process_object_type(data.raw["tile"], tile_functor)

    for item_type in pairs(defines.prototypes.item) do
        process_object_type(data.raw[item_type], item_functor)
    end

    local module_categories = {}
    for _, module in pairs(data.raw.module) do
        module_categories[module.category] = true
    end

    -- asteroid chunks are actually not entities however they define standard minable properties.
    process_object_type(data.raw["asteroid-chunk"], entity_functor)
    for entity_type in pairs(defines.prototypes.entity) do
        process_object_type(data.raw[entity_type], entity_functor)

        for _, entity in pairs(data.raw[entity_type] or {}) do
            if entity.allowed_module_categories then
                for _, category in pairs(entity.allowed_module_categories) do
                    module_categories[category] = true
                end
            end
        end
    end

    local _module_categories = {}
    for category in pairs(module_categories) do -- module categories are not a real prototype. we can need to fake it by giving them a name and type.
        table.insert(_module_categories, {
            name = category,
            type = "module-category",
        })
    end

    process_requirement_type(_module_categories, requirement_types.module_category)
end

function auto_tech:link_nodes()
    self.object_nodes:for_all_nodes(function (object_type, object)
        if object_type == object_types.start then
            return
        end
        functor_map[object_type]:register_dependencies(object, self.requirement_nodes, self.object_nodes)
    end)
end

function auto_tech:linearise_recipe_graph()
    local verbose_logging = self.configuration.verbose_logging
    local q = deque.new()
    for _, node_type in pairs(self.nodes_per_node_type) do
        for _, node in pairs(node_type) do
            if node:has_no_more_dependencies() then
                q:push_right(node)
                if verbose_logging then
                    log("Node " .. node.printable_name .. " starts with no dependencies.")
                end
            end
        end
    end

    while not q:is_empty() do
        local next = q:pop_left()
        if verbose_logging then
            log("Node " .. next.printable_name .. " is next in the linearisation.")
        end

        local newly_independent_nodes = next:release_dependents()
        if verbose_logging then
            for _, node in pairs(newly_independent_nodes) do
                log("After releasing " .. next.printable_name .. " node " .. node.printable_name .. " is now independent.")
            end
        end

        for _, node in pairs(newly_independent_nodes) do
            q:push_right(node)
        end
    end

    for _, node_type in pairs(self.nodes_per_node_type) do
        for _, node in pairs(node_type) do
            if not node:has_no_more_dependencies() then
                log("Node " .. node.printable_name .. " still has unresolved dependencies: " .. node:print_dependencies())
            end
        end
    end
end

function auto_tech:verify_end_tech_reachable()

end

function auto_tech:calculate_transitive_reduction()

end

function auto_tech:construct_tech_graph()

end

function auto_tech:linearise_tech_graph()

end

function auto_tech:adapt_tech_links()

end

function auto_tech:set_tech_costs()

end

return auto_tech
