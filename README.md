# Autotech

Autotech is a mod that analyses the 'true' dependencies between recipes and technologies, allowing the following:
- adapt tech dependencies such that if you research a tech, you will be able to use all the recipes from that tech tree right away.
- allow other mods to override tech costs for every tech
  - the other mod will get the length of the longest tech dependency chain between this tech and the required science pack for every such pack
  - this allows for slowly scaling tech costs
  - can enforce that all techs require at least the same science packs as its dependencies
- order the recipes in the tech screen according to which one is used first
- set technology-order to a sensible value
- remove superfluous dependencies between techs: if A depends on B and B depends on C, then A doesn't need to also depend on C

Various parts of these features are allowed to be precomputed in a 'cache file', with two benefits:
- faster startup times
- adding additional mods don't mess up the tech tree, in particular when using scaling tech costs

The mod also has extensive debugging capabilities, reporting various issues with your tech tree, such as:
- unreachable items/recipes/techs
- cyclic dependencies between items
- whether the game is beatable
