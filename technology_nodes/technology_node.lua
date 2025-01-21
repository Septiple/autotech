---Represents a technology
---@class TechnologyNode
---@field object_node ObjectNode
---@field printable_name string
---@field configuration Configuration
---@field requirements table<string, TechnologyNode>
---@field nr_requirements int
---@field fulfilled_requirements table<string, boolean>
---@field nr_fulfilled_requirements int
local technology_node = {}
technology_node.__index = technology_node

---@param object_node ObjectNode
---@param technology_nodes TechnologyNodeStorage
---@return TechnologyNode
function technology_node:new(object_node, technology_nodes)
    local result = {}
    setmetatable(result, self)

    result.object_node = object_node
    result.printable_name = object_node.printable_name
    result.configuration = object_node.configuration

    result.requirements = {}
    result.nr_requirements = 0
    result.fulfilled_requirements = {}
    result.nr_fulfilled_requirements = 0

    technology_nodes:add_technology_node(result)

    if result.configuration.verbose_logging then
        log("Created technology node for " .. result.printable_name)
    end

    return result
end

return technology_node