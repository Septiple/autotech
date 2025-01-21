local object_types = require "object_nodes.object_types"
local deque = require "utils.deque"

---Represents a technology
---@class TechnologyNode
---@field object_node ObjectNode
---@field printable_name string
---@field configuration Configuration
---@field requirements table<string, TechnologyNode>
---@field nr_requirements int
---@field fulfilled_requirements table<string, boolean>
---@field nr_fulfilled_requirements int
---@field not_part_of_canonical_path boolean
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
    result.not_part_of_canonical_path = false

    technology_nodes:add_technology_node(result)

    if result.configuration.verbose_logging then
        log("Created technology node for " .. result.printable_name)
    end

    return result
end

function technology_node:link_technologies()
    local verbose_logging = self.configuration.verbose_logging
    if verbose_logging then
        log("Resolving dependencies for technology " .. self.printable_name)
    end

    local object_node = self.object_node

    local visitedObjects = {}
    local q = deque.new()

    local function add_initial_node(node)
        visitedObjects[node] = true
        q:push_right(node)
        if verbose_logging then
            log("Initial node that needs to be useable: " .. node.printable_name)
        end
    end
    add_initial_node(object_node)
    for _, unlock in pairs(object_node.technology_unlocks) do
        add_initial_node(unlock)
    end

    while not q:is_empty() do
        ---@type ObjectNode
        local next = q:pop_left()

        for _, requirement in pairs(next.requirements) do
            ---@type ObjectNode
            local canonical_fulfiller = requirement.canonical_fulfiller
            if canonical_fulfiller == nil then
                if verbose_logging then
                    log("Cannot fulfil requirement " .. requirement.printable_name .. ", it has no canonical fulfiller. Aborting search, technology unusable.")
                end
                self.not_part_of_canonical_path = true
                return
            end

            if canonical_fulfiller.descriptor.object_type == object_types.technology then
                self.requirements[#self.requirements] = canonical_fulfiller
                self.nr_requirements = self.nr_requirements + 1

                if verbose_logging then
                    log("Found a tech dependency: " .. canonical_fulfiller.printable_name)
                end
            else
                if visitedObjects[canonical_fulfiller] == nil then
                    q:push_right(canonical_fulfiller)
                    visitedObjects[canonical_fulfiller] = true

                    if verbose_logging then
                        log("Dependency on: " .. canonical_fulfiller.printable_name)
                    end
                end
            end
        end
    end
    if verbose_logging then
        log("Done resolving dependencies for technology " .. self.printable_name)
    end
end

return technology_node