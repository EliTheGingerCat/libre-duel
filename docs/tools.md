# Tools

Every tool is a module in `ReplicatedStorage/shared/tools/definitions/`. The
module's name is the tool id and it only returns data. `registry.luau` loads them
all, so the server and client resolve the same definitions.

```luau
const definition: tool_types.definition = {
	name = "Sword",
	image = "rbxassetid://...", -- defaults to a placeholder
	behaviours = {
		sword = { damage = 20 },
	},
}
```

A tool runs every behaviour in `behaviours`, so one tool can have several. The
params of each behaviour are typed in `tool_types.luau`. Unset params keep the
behaviour's default.

## Variants

Set `inherits` to copy another tool, then override fields. Tables merge key by
key, anything else replaces the base value:

```luau
const definition: tool_types.definition = {
	inherits = "cube",
	name = "Sphere",
	behaviours = {
		cube = { shape = Enum.PartType.Ball },
	},
}
```

`image` is the icon in the hotbar and inventory. A cube's `texture_id` is drawn on
every face of the placed block.

## Per-stack overrides

A slot can carry `data` (`tool_types.overrides`), merged on top of its tool for
that stack only. Use `tool_registry.resolve(item_id, data)` to get the result.
Replace `data` to change it, don't mutate it, since resolved tools are cached per
table.

## Inventory and hotbar

Tools live in the entity's inventory, players and bots alike. The first row of the inventory (slots 1 to
`COLUMNS`) is the hotbar. `ReplicatedStorage/shared/inventory/STARTING_LOADOUT.luau`
maps slots to tool ids, and the server gives this loadout on every spawn. Use
`get_slot_tool(slot)` to resolve a slot to its tool. To check what a slot does,
use `slot_has_behaviour(slot, behaviour)` rather than comparing ids.

The server only accepts a tool action when the tool is in the slot the client
has selected, and reads params from its own copy of the inventory. The client
reports slot switches through the `select_slot` remote.

## Attacking and using

Left click attacks and right click uses, whichever item is held. The buttons are
`tool_attack` and `tool_use` in `KEYBINDS.luau`.

Attacking works the same for every item, so it isn't a behaviour. A sword deals its
`damage` and anything else deals `NON_SWORD_DAMAGE`. An empty hand doesn't attack.

What else a click does depends on the item's behaviours:

| Behaviour       | Button | Effect                              |
| --------------- | ------ | ----------------------------------- |
| `pickaxe`       | Left   | Mines while held                    |
| `sword`         | Right  | Blocks while held                   |
| `cake`          | Right  | Eats while held                     |
| `cube`          | Right  | Places one cube                     |
| `bow`           | Right  | Draws while held, shoots on release |
| `mode_selector` | Right  | Opens the mode selector             |

`TOOL_BUTTONS` in `tools.client.luau` maps each button to its handlers, and
`create_tool_button.luau` runs them. An instant handler only has a `start`. A lasting
handler also has a `stop`, which is called when the button is released, or when the
handler gets interrupted by switching to a different item, opening a menu, losing window
focus or the character being removed. Holding the button while switching to an item
starts a lasting handler straight away, but never an instant one.

## Adding a behaviour

1. Add its params to `behaviours` and its name to `behaviour` in `tool_types.luau`.
2. Add its client handler under `client/tools/<behaviour>/`. The handler takes the
   selected tool.
3. Add the handler to its button in `TOOL_BUTTONS` in `tools.client.luau`, as
   `{ start = handler }` if it's instant. If it lasts, also add a `stop`. It takes whether
   the button was released, as opposed to the handler getting interrupted.
4. Give a tool the behaviour in its definition.
5. On the server, reject the action unless
   `inventory_util.has_behaviour(entity, behaviour)` is true.
