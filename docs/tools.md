# Tools

Every tool is registered in `ReplicatedStorage/shared/tools/registry.luau`. The
registry is shared so the server can resolve the same definitions as the client.
A tool has an `id`, a display `name`, a `behaviour`, an `image` (its icon in the
hotbar and inventory), and an `appearance`.

Client behaviours live in `ReplicatedStorage/client/tools/<behaviour>/`.
`tools.client.luau` maps each behaviour to its handler and calls the handler with
the selected tool when the use keybind is pressed. Server handlers stay in their
feature directories under `ServerScriptService`.

## Variants

A variant behaves exactly like its base tool but looks different. Register one
with `define_variant(id, base_id, name, overrides, image?)`. The variant uses the
base tool's image unless `image` is given. The variant copies the base
tool's behaviour and appearance, then applies `overrides`:

```luau
define_variant("sphere_cube", "cube", "Sphere", {
	shape = Enum.PartType.Ball,
})
```

`appearance` supports `colour`, `material`, and `shape`. Unset fields keep the
default. Cube placement applies the appearance to the placed cube on both the
client and the server. The client sends the tool id with the placement request,
and the server rejects ids that are not registered cube tools.

## Inventory and hotbar

Tools live in the player's inventory. The first row of the inventory (slots 1 to
`COLUMNS`) is the hotbar. `ReplicatedStorage/shared/inventory/STARTING_LOADOUT.luau`
maps slots to tool ids, and the server gives this loadout on every spawn. Use
`get_slot_tool(slot)` to resolve a slot to its tool. To check what a slot does,
use `slot_has_behaviour(slot, behaviour)` rather than comparing ids, so variants
are handled too.

The server only accepts a tool action when the tool is in the slot the client
has selected. The client reports slot switches through the `select_slot` remote.

## Adding a behaviour

1. Add the behaviour to the `behaviour` type in the registry and `define` a tool
   that uses it, with an image.
2. Add its client handler under `client/tools/<behaviour>/`. The handler takes the
   selected tool, though it may ignore it.
3. Add the handler to `HANDLERS` in `tools.client.luau`.
4. Give the tool a slot in `STARTING_LOADOUT.luau`.
5. On the server, reject the action unless
   `inventory_util.has_behaviour(player, behaviour)` is true.
