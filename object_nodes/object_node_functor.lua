--- @module "definitions"

local object_node_descriptor = require "object_nodes.object_node_descriptor"
local object_types = require "object_nodes.object_types"
local requirement_descriptor = require "requirement_nodes.requirement_descriptor"

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
---@param requirement_type RequirementType
---@param requirement_nodes RequirementNodeStorage
function object_node_functor:add_fulfiller_for_independent_requirement(object, requirement_type, requirement_nodes)
    local requirement = requirement_nodes[requirement_type][requirement_type]
    requirement:add_fulfiller(object)
end

---@param object ObjectNode
---@param requirement_type RequirementType
---@param requirement_nodes RequirementNodeStorage
function object_node_functor:add_fulfiller_for_typed_requirement(object, requirement_type, requirement_nodes)
    local requirement = requirement_nodes[requirement_type][requirement_type]
    requirement:add_fulfiller(object)
end

---@param object ObjectNode
---@param object_descriptor ObjectNodeDescriptor
---@param requirement any
---@param object_nodes ObjectNodeStorage
function object_node_functor:add_fulfiller_for_object_requirement(object, object_descriptor, requirement, object_nodes)
    if not object_descriptor:valid() then
        return
    end

    local target_node = object_nodes:find_object_node(object_descriptor)
    local requirement_node = target_node.depends[requirement]
    requirement_node:add_fulfiller(object)
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
---@param target_requirement_type string
---@param object_nodes ObjectNodeStorage
function object_node_functor:add_fulfiller_to_productlike_object(fulfiller, productlike_possibly_table, target_requirement_type, object_nodes)
    if productlike_possibly_table == nil then
        return
    end

    function inner_function(productlike)
        local type_of_productlike = productlike.type == "item" and object_types.item or object_types.fluid
        local descriptor = object_node_descriptor:new(productlike.name, type_of_productlike)
        object_nodes:find_object_node(descriptor).depends[target_requirement_type]:add_fulfiller(fulfiller)
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