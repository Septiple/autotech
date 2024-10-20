local object_types = require "nodes.object_types"
local object_node_functor = require "nodes.object_node_functor"
local requirement_node = require "nodes.requirement_node"
local requirement_types = require "nodes.requirement_types"
local item_requirements = require "nodes.item_requirements"
local entity_requirements = require "nodes.entity_requirements"

local recipe_functor = object_node_functor:new(object_types.recipe,
function (object, requirement_nodes)
end,
function (object, requirement_nodes, object_nodes)
end)
return recipe_functor
-- self:add_dependency(nodes, node_types.recipe_category_node, recipe.category or "crafting", "crafting category", "craft")

-- self:add_productlike_dependency(nodes, recipe.ingredient, recipe.ingredients, "recipe ingredient", "craft")

-- self:add_productlike_disjunctive_dependent(nodes, recipe.result, recipe.results, "recipe result")

-- if recipe.enabled ~= false then
--     self:add_disjunctive_dependency(nodes, node_types.start_node, 1, "starts enabled", recipe_verbs.enable)
-- end