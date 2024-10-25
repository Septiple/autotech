--- @meta

--- @alias Configuration { verbose_logging: boolean }

--- @alias ObjectNodes table<ObjectType, table<string, ObjectNode>>
--- @alias RequirementNodes table<RequirementType|ObjectNode, table<string, RequirementNode>>

--- @alias RequirementsRegistryFunction fun(object: ObjectNode, requirement_nodes: RequirementNodes)
--- @alias DependencyRegistryFunction fun(object: ObjectNode, requirement_nodes: RequirementNodes, object_nodes: ObjectNodes)

--- @alias FactorioThing { name: string }
--- @alias FactorioThingGroup table<string, FactorioThing>
--- @alias DataRaw table<string, FactorioThingGroup>

-- TODO: use built-in Factorio types
--- @alias FluidDefinition { name: string, fuel_value: number }
