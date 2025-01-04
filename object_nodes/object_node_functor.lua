--- @module "definitions"

local object_node_descriptor = require "object_nodes.object_node_descriptor"
local object_types = require "object_nodes.object_types"
local requirement_descriptor = require "requirement_nodes.requirement_descriptor"
local item_requirements = require "requirements.item_requirements"
local fluid_requirements = require "requirements.fluid_requirements"

---Defines how to register requirements and dependencies for a specific object type.
---@class ObjectNodeFunctor
---@field object_type ObjectType
---@field configuration Configuration
---@field register_requirements_func RequirementsRegistryFunction
---@field register_dependencies_func DependencyRegistryFunction
local object_node_functor = {}
object_node_functor.__index = object_node_functor

---@param object_type ObjectType
---@param register_requirements_func RequirementsRegistryFunction
---@param register_dependencies_func DependencyRegistryFunction
---@return ObjectNodeFunctor
function object_node_functor:new(object_type, register_requirements_func, register_dependencies_func)
    local result = {}
    setmetatable(result, self)
    result.object_type = object_type
    result.register_requirements_func = register_requirements_func
    result.register_dependencies_func = register_dependencies_func

    return result
end

---@package
---@param object ObjectNode
function object_node_functor:check_object_type(object)
    if object.descriptor.object_type ~= self.object_type then
        error("Mismatching object type, expected " .. self.object_type .. ", actual " .. object.descriptor.object_type)
    end
end

---@param object ObjectNode
---@param requirement_nodes RequirementNodeStorage
function object_node_functor:register_requirements(object, requirement_nodes)
    self:check_object_type(object)
    self.register_requirements_func(object, requirement_nodes)
end

---@param object ObjectNode
---@param requirement_nodes RequirementNodeStorage
---@param object_nodes ObjectNodeStorage
function object_node_functor:register_dependencies(object, requirement_nodes, object_nodes)
    self:check_object_type(object)
    self.register_dependencies_func(object, requirement_nodes, object_nodes)
end

-- These are static helper functions

---@param object ObjectNode
---@param source RequirementType
---@param requirement_nodes RequirementNodeStorage
function object_node_functor:add_fulfiller_for_independent_requirement(object, source, requirement_nodes)
    local descriptor = requirement_descriptor:new_independent_requirement_descriptor(source)
    local node = requirement_nodes:find_requirement_node(descriptor)
    node:add_fulfiller(object)
end

---@param object ObjectNode
---@param nameOrTable string
---@param source RequirementType
---@param requirement_nodes RequirementNodeStorage
function object_node_functor:add_fulfiller_for_typed_requirement(object, nameOrTable, source, requirement_nodes)
    if nameOrTable == nil then
        return
    end

    local function actually_add_fulfiller(name)
        local descriptor = requirement_descriptor:new_typed_requirement_descriptor(name, source)
        local node = requirement_nodes:find_requirement_node(descriptor)
        node:add_fulfiller(object)
    end

    if type(nameOrTable) == "table" then
        for _, name in pairs(nameOrTable) do
            actually_add_fulfiller(name)
        end
    else
        actually_add_fulfiller(nameOrTable)
    end
end

---@param requirer ObjectNode
---@param requirement string
---@param fulfiller_name string
---@param fulfiller_type ObjectType
---@param object_nodes ObjectNodeStorage
function object_node_functor:reverse_add_fulfiller_for_object_requirement(requirer, requirement, fulfiller_name, fulfiller_type, object_nodes)
    local node = requirer.requirements[requirement]
    local descriptor = object_node_descriptor:new(fulfiller_name, fulfiller_type)
    local fulfiller = object_nodes:find_object_node(descriptor)
    node:add_fulfiller(fulfiller)
end

---@param requirer ObjectNode
---@param requirement_prefix string
---@param table any[]
---@param fulfiller_type ObjectType
---@param object_nodes ObjectNodeStorage
---@param optional_inner_index? any
function object_node_functor:reverse_add_fulfiller_for_object_requirement_table(requirer, requirement_prefix, table, fulfiller_type, object_nodes, optional_inner_index)
    for _, entry in pairs(table or {}) do
        local actualEntry = optional_inner_index and entry[optional_inner_index] or entry
        object_node_functor:reverse_add_fulfiller_for_object_requirement(requirer, requirement_prefix .. ": " .. actualEntry, actualEntry, fulfiller_type, object_nodes)
    end
end

---@param fulfiller ObjectNode
---@param nameOrTable any
---@param object_type ObjectType
---@param requirement any
---@param object_nodes ObjectNodeStorage
---@param optional_inner_name? string|nil
function object_node_functor:add_fulfiller_for_object_requirement(fulfiller, nameOrTable, object_type, requirement, object_nodes, optional_inner_name)
    
    -- This function aims to work with a lot of different formats:
    -- - nameOrTable is an item/entity/whatever directly
    -- - nameOrTable[optional_inner_name] is an item directly
    -- - nameOrTable is a table of items
    -- - nameOrTable is a table of objects, and object[optional_inner_name] is an item

    if nameOrTable == nil then
        return
    end
    local function actualWork(name)
        local object_descriptor = object_node_descriptor:new(name, object_type)
        local target_node = object_nodes:find_object_node(object_descriptor)
        local requirement_node = target_node.requirements[requirement]
        requirement_node:add_fulfiller(fulfiller)
    end
    function checkInnerName(actual_node_name)
        if optional_inner_name == nil then
            if type(actual_node_name) == "table" then
                actualWork(actual_node_name["name"])
            else
                actualWork(actual_node_name)
            end
        else
            actualWork(actual_node_name[optional_inner_name])
        end
    end
    function doCallOnObject()
        checkInnerName(nameOrTable)
    end
    function doCallOnTable()
        for _, actual_node_name in pairs(nameOrTable) do
            checkInnerName(actual_node_name)
        end
    end
    if type(nameOrTable) == "table" then
        if optional_inner_name ~= nil then
            -- have to distinguish between { item='fish', count=5 } and a table of such entries
            if nameOrTable[optional_inner_name] == nil then
                doCallOnTable()
            else
                doCallOnObject()
            end
        else
            doCallOnTable()
        end
    else
        doCallOnObject()
    end
end

---@param object ObjectNode
---@param source RequirementType
---@param requirement_nodes RequirementNodeStorage
function object_node_functor:add_independent_requirement_to_object(object, source, requirement_nodes)
    local requirement = requirement_nodes:find_requirement_node(requirement_descriptor:new_independent_requirement_descriptor(source))
    if requirement == nil then
        error("Cannot find requirement " .. source)
    end
    object:add_requirement(requirement)
end

---@param object ObjectNode
---@param name string?
---@param requirement_type RequirementType
---@param requirement_nodes RequirementNodeStorage
function object_node_functor:add_typed_requirement_to_object(object, name, requirement_type, requirement_nodes)
    if name == nil then
        return
    end
    local requirement = requirement_nodes:find_requirement_node(requirement_descriptor:new_typed_requirement_descriptor(name, requirement_type))
    if requirement == nil then
        error("Cannot find requirement " .. name .. " of type " .. requirement_type)
    end
    object:add_requirement(requirement)
end

---@param requirement RequirementNode
---@param productlike any
---@param object_nodes ObjectNodeStorage
function object_node_functor:add_productlike_fulfiller(requirement, productlike, object_nodes)
    local type_of_productlike = productlike.type == "item" and object_types.item or object_types.fluid
    local descriptor = object_node_descriptor:new(productlike.name, type_of_productlike)
    requirement:add_fulfiller(object_nodes:find_object_node(descriptor))
end

---@param fulfiller ObjectNode
---@param productlike_possibly_table any
---@param object_nodes ObjectNodeStorage
function object_node_functor:add_fulfiller_to_productlike_object(fulfiller, productlike_possibly_table, object_nodes)
    if productlike_possibly_table == nil then
        return
    end

    function inner_function(productlike)
        local type_of_productlike = productlike.type and (productlike.type == "item" and object_types.item or object_types.fluid) or object_types.item
        local type_of_requirement = productlike.type and (productlike.type == "item" and item_requirements.create or fluid_requirements.create) or item_requirements.create
        local descriptor = object_node_descriptor:new(productlike.name or productlike, type_of_productlike)
        object_nodes:find_object_node(descriptor).requirements[type_of_requirement]:add_fulfiller(fulfiller)
    end

    if type(productlike_possibly_table) == "table" then
        for _, productlike in pairs(productlike_possibly_table or {}) do
            inner_function(productlike)
        end
    else
        inner_function(productlike_possibly_table)
    end
end

return object_node_functor