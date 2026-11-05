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

## Per-stack overrides

A slot can carry `data` (`tool_types.overrides`), merged on top of its tool for
that stack only. Use `tool_registry.resolve(item_id, data)` to get the result.
Replace `data` to change it, don't mutate it, since resolved tools are cached per
table.

## Inventory and hotbar

Tools live in the player's inventory. The first row of the inventory (slots 1 to
`COLUMNS`) is the hotbar. `ReplicatedStorage/shared/inventory/STARTING_LOADOUT.luau`
maps slots to tool ids, and the server gives this loadout on every spawn. Use
`get_slot_tool(slot)` to resolve a slot to its tool. To check what a slot does,
use `slot_has_behaviour(slot, behaviour)` rather than comparing ids.

The server only accepts a tool action when the tool is in the slot the client
has selected, and reads params from its own copy of the inventory. The client
reports slot switches through the `select_slot` remote.

## Adding a behaviour

1. Add its params to `behaviours` and its name to `behaviour` in `tool_types.luau`.
2. Add its client handler under `client/tools/<behaviour>/`. The handler takes the
   selected tool.
3. Add the handler to `HANDLERS` in `tools.client.luau`.
4. Give a tool the behaviour in its definition.
5. On the server, reject the action unless
   `inventory_util.has_behaviour(player, behaviour)` is true.
