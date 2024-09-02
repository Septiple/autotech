--- @module "factorio_meta"

local deque = require "utils.deque"
local entity_prototypes = require "entity_prototypes"

local node_types = require "nodes.node_types"

local ammo_category_node = require "nodes.ammo_category_node"
local electricity_node = require "nodes.electricity_node"
local entity_node = require "nodes.entity_node"
local equipment_grid_node = require "nodes.equipment_grid_node"
local fluid_fuel_node = require "nodes.fluid_fuel_node"
local fluid_node = require "nodes.fluid_node"
local fuel_category_node = require "nodes.fuel_category_node"
local item_node = require "nodes.item_node"
local recipe_category_node = require "nodes.recipe_category_node"
local recipe_node = require "nodes.recipe_node"
local resource_category_node = require "nodes.resource_category_node"
local start_node = require "nodes.start_node"
local technology_node = require "nodes.technology_node"

--- @class auto_tech
--- @field private configuration Configuration
--- @field private data_raw DataRaw
--- @field private entity_prototypes { [string]:0 }
--- @field private nodes_per_node_type table<NodeType, ObjectNodeBase>
local auto_tech = {}
auto_tech.__index = auto_tech

---@param data_raw DataRaw
---@param configuration Configuration
---@return auto_tech
function auto_tech.create(data_raw, configuration)
    local a = {}
    setmetatable(a, auto_tech)

    a.nodes_per_node_type = {}
    a.data_raw = data_raw
    a.entity_prototypes = entity_prototypes
    a.configuration = configuration
    return a
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
    for _, node_type in pairs(node_types) do
        self.nodes_per_node_type[node_type] = {}
    end

    start_node:create(nil, self.nodes_per_node_type, self.configuration)
    electricity_node:create(nil, self.nodes_per_node_type, self.configuration)
    fluid_fuel_node:create(nil, self.nodes_per_node_type, self.configuration)

    ---@param table FactorioThingGroup
    ---@param node_type ObjectNodeBase
    local function process_type(table, node_type)
        for _, object in pairs(table) do
            node_type:create(object, self.nodes_per_node_type, self.configuration)
        end
    end

    process_type(self.data_raw["ammo-category"], ammo_category_node)
    process_type(self.data_raw["equipment-grid"], equipment_grid_node)
    process_type(self.data_raw["fluid"], fluid_node)
    process_type(self.data_raw["fuel-category"], fuel_category_node)
    process_type(self.data_raw["recipe-category"], recipe_category_node)
    process_type(self.data_raw["recipe"], recipe_node)
    process_type(self.data_raw["resource-category"], resource_category_node)
    process_type(self.data_raw["resource"], entity_node)
    process_type(self.data_raw["technology"], technology_node)

    process_type(self.data_raw["armor"], item_node)
    process_type(self.data_raw["ammo"], item_node)
    process_type(self.data_raw["capsule"], item_node)
    process_type(self.data_raw["gun"], item_node)
    process_type(self.data_raw["item"], item_node)
    process_type(self.data_raw["item-with-entity-data"], item_node)
    process_type(self.data_raw["item-with-inventory"], item_node)
    process_type(self.data_raw["item-with-label"], item_node)
    process_type(self.data_raw["item-with-tags"], item_node)
    process_type(self.data_raw["mining-tool"], item_node)
    process_type(self.data_raw["module"], item_node)
    process_type(self.data_raw["spidertron-remote"], item_node)
    process_type(self.data_raw["rail-planner"], item_node)
    process_type(self.data_raw["repair-tool"], item_node)
    process_type(self.data_raw["tool"], item_node)

    for entity_name, _ in pairs(self.entity_prototypes) do
        for _, value in pairs(self.data_raw[entity_name]) do
            entity_node:create(value, self.nodes_per_node_type, self.configuration)
        end
    end
end

function auto_tech:link_nodes()
    for _, node_type in pairs(self.nodes_per_node_type) do
        for _, node in pairs(node_type) do
            node:register_dependencies(self.nodes_per_node_type)
        end
    end
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