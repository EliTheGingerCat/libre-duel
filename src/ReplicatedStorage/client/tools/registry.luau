const bow = require(script.Parent.bow)
const cake = require(script.Parent.cake)
const cube = require(script.Parent.cube)
const dissolver = require(script.Parent.dissolver)
const sword = require(script.Parent.sword)
const tool_types = require(script.Parent.tool_types)

const registry: { [tool_types.id]: tool_types.factory } = {
	bow = bow,
	cake = cake,
	cube = cube,
	dissolver = dissolver,
	sword = sword,
}

return registry
