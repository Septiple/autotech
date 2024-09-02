local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"
local recipe_verbs = require "verbs.recipe_verbs"

local recipe_node = object_node_base:create_object_class("recipe", node_types.recipe_node, function(self, nodes)
    local recipe = self.object
    self:add_dependency(nodes, node_types.recipe_category_node, recipe.category or "crafting", "crafting category", "craft")

    local recipe_data = (type(recipe.normal) == "table" and (recipe.normal or recipe.expensive) or recipe)

    self:add_productlike_dependency(nodes, recipe_data.ingredient, recipe_data.ingredients, "ingredient", "craft")

    self:add_productlike_disjunctive_dependent(nodes, recipe_data.result, recipe_data.results, "result")

    if recipe_data.enabled ~= false then
        self:add_disjunctive_dependency(nodes, node_types.start_node, 1, "starts enabled", recipe_verbs.enable)
    end
end)

return recipe_node
