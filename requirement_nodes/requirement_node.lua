--- @module "definitions"

-- There are 3 kinds of requirement nodes:
-- - generic requirements like electricity
-- - typed requirements like a recipe category
-- - requirements specific to an object like the ingredients of a recipe

---Represents one of the three types of Factorio requirements for objects
---@class RequirementNode
---@field name string
---@field source RequirementType|ObjectNode
---@field printable_name string
---@field configuration Configuration
---@field disjunctive_depends ObjectNode[]
---@field reverse_depends ObjectNode[]
local requirement_node = {}
requirement_node.__index = requirement_node

-- TODO: split up requirement_nodes according to the 3 types?

---@package
---@param name string
---@param source RequirementType|ObjectNode
---@param printable_name string
---@param requirement_nodes RequirementNodes
---@param configuration Configuration
---@return RequirementNode
function requirement_node:new(name, source, printable_name, requirement_nodes, configuration)
    local result = {}
    setmetatable(result, self)

    result.name = name
    result.source = source
    result.printable_name = printable_name
    result.configuration = configuration

    result.disjunctive_depends = {}
    result.reverse_depends = {}

    local nodes_for_source = requirement_nodes[source]
    if nodes_for_source == nil then
        requirement_nodes[source] = {}
        nodes_for_source = requirement_nodes[source]
    end
    if nodes_for_source[name] ~= nil then
        error("Duplicate requirement node " .. result.printable_name)
    end
    nodes_for_source[name] = result

    if configuration.verbose_logging then
        log("Created requirement node for " .. result.printable_name)
    end

    return result
end

---@param source RequirementType
---@param requirement_nodes RequirementNodes
---@param configuration Configuration
---@return RequirementNode
function requirement_node:new_independent_requirement(source, requirement_nodes, configuration)
    return self:new(source, source, source, requirement_nodes, configuration)
end

---@param name string
---@param source RequirementType
---@param requirement_nodes RequirementNodes
---@param configuration Configuration
---@return RequirementNode
function requirement_node:new_typed_requirement(name, source, requirement_nodes, configuration)
    return self:new(name, source, name .. " (" .. source .. ")", requirement_nodes, configuration)
end

---@param name string
---@param source_object ObjectNode
---@param requirement_nodes RequirementNodes
---@param configuration Configuration
---@return RequirementNode
function requirement_node:add_new_object_dependent_requirement(name, source_object, requirement_nodes, configuration)
    local new_requirement = self:new(name, source_object, name .. " (" .. source_object.printable_name .. ")", requirement_nodes, configuration)
    source_object:add_requirement(new_requirement)
    return new_requirement
end

---@param fulfiller ObjectNode
function requirement_node:add_fulfiller(fulfiller)
    local disjunctive_depends = self.disjunctive_depends
    disjunctive_depends[#disjunctive_depends+1] = fulfiller
    ---@diagnostic disable-next-line: invisible
    fulfiller:add_reverse_disjunctive_fulfilled(self)

    log("Object " .. fulfiller.printable_name .. " is able to fulfil the requirement " .. self.printable_name)
end

---@package
---@param dependent ObjectNode
function requirement_node:add_reverse_dependent(dependent)
    local reverse_depends = self.reverse_depends
    reverse_depends[#reverse_depends+1] = dependent
end

return requirement_node