local object_node_base = require "nodes.object_node_base"
local node_types = require "nodes.node_types"

local recipe_category_node = object_node_base:create_object_class("recipe category", node_types.recipe_category_node)

function recipe_category_node:register_dependencies(nodes)
end

return recipe_category_node
