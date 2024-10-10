local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local recipe_verbs = require "verbs.recipe_verbs"

local recipe_node = object_node_base:create_object_class("recipe", node_types.recipe_node, function(self, nodes)
    local recipe = self.object
    self:add_dependency(nodes, node_types.recipe_category_node, recipe.category or "crafting", "crafting category", "craft")

    self:add_productlike_dependency(nodes, recipe.ingredient, recipe.ingredients, "ingredient", "craft")

    self:add_productlike_disjunctive_dependent(nodes, recipe.result, recipe.results, "result")

    if recipe.enabled ~= false then
        self:add_disjunctive_dependency(nodes, node_types.start_node, 1, "starts enabled", recipe_verbs.enable)
    end
end)

return recipe_node
