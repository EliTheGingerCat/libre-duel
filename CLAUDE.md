Libre Duel is a minecraft-like combat game on Roblox.

How to write good code for this repo:

Everything should be split up into folders, and the codebase should be agnostic. The existing codebase does a pretty decent job at this.
Do not write useless comments that simply explain what code does verbatim. Only write them if they are useful, or if something goes against the styling guidelines but you have an explanation for it. Do not use ; in comments or start them with capital letters.
NEVER use emdashes or center dots (·).
ALWAYS make sure things are going in the correct folders. If you have a folder where things actually do 2 different things, split it up or move the scripts out. A good example of this is the cube folder which had mining and placing both at the root but was then split up into mining and placing folders under the cube directory.
Use the `const` keyword when possible. It is correct Luau. A const is just a local that cannot be reassigned.
`const` can be used for functions, tables, non-reassignable variables, requires.
```luau
const req = require(script.Parent.req)

const function hi(string: string): ()
	print(`Hello, {string}!`)
	return `Printed {string}`
end

const result = hi(string)

const CONST_ARRAY = {
	21,
	67,
	69,
	420,
}

const CONST_DICT = {
	first = "yay!",
	second = "yippie!",
}
```

Casing: Use snake_case for vars and funcs, SCREAMING_SNAKE_CASE for const variable definitions, same casing for services (exempli gratia `const ReplicatedStorage = game:GetService("ReplicatedStorage")`).

Never use anonymous functions.

Prefer long variable and function names to vague ones.

Use types.

Avoid monolithic modules as much as possible.
