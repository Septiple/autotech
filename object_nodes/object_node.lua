--- @module "definitions"

---Represents a thing in Factorio. May have requirements, and may fulfil requirements.
---@class ObjectNode
---@field object FactorioThing
---@field descriptor ObjectNodeDescriptor
---@field printable_name string
---@field configuration Configuration
---@field depends table<string, RequirementNode>
---@field reverse_disjunctive_depends RequirementNode[]
local object_node = {}
object_node.__index = object_node

---@param object FactorioThing
---@param descriptor ObjectNodeDescriptor
---@param object_nodes ObjectNodeStorage
---@param configuration Configuration
---@return ObjectNode
function object_node:new(object, descriptor, object_nodes, configuration)
    local result = {}
    setmetatable(result, self)

    result.object = object
    result.descriptor = descriptor
    result.printable_name = descriptor.printable_name
    result.configuration = configuration

    result.depends = {}
    result.reverse_disjunctive_depends = {}

    object_nodes:add_object_node(result)

    if configuration.verbose_logging then
        log("Created object node for " .. result.printable_name)
    end

    return result
end

---@param requirement RequirementNode
function object_node:add_requirement(requirement)
    local requirement_type = requirement.name
    local depends = self.depends
    if depends[requirement_type] ~= nil then
        error("Duplicate requirement " .. requirement_type .. " on object " .. self.printable_name)
    end
    depends[requirement_type] = requirement
    ---@diagnostic disable-next-line: invisible
    requirement:add_reverse_dependent(self)

    log("Object " .. self.printable_name .. " has the requirement " .. requirement.printable_name)
end

---@package
---@param fulfilled RequirementNode
function object_node:add_reverse_disjunctive_fulfilled(fulfilled)
    local reverse_disjunctive_depends = self.reverse_disjunctive_depends
    reverse_disjunctive_depends[#reverse_disjunctive_depends+1] = fulfilled
end

return object_node
