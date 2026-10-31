# Tools

Client tools live in `src/ReplicatedStorage/client/tools`. Each tool ModuleScript
returns a named factory that creates its lifecycle hooks. `registry.luau` maps
tool IDs to factories; `LOADOUT.luau` sets their hotbar slots. The existing five
tools and nine hotbar slots are retained.

`controller.client.luau` owns input, selection, held-input buffering, and character
connections. The hotbar reads `state.luau`. Set selection through `state.set_slot`
so the controller and hotbar receive the same change. Selecting an empty slot is
allowed and unequips the current tool.

## Lifecycle

`tool_types.tool` defines the interface:

| Hook or setting | Purpose |
| --- | --- |
| `begin_use` | Required; runs when the player presses use. |
| `end_use` | Optional; runs when the player releases use. |
| `cancel_use` | Optional; stops an action without completing it. |
| `equip` | Optional; runs after creating the selected tool. |
| `unequip` | Optional; releases resources when the tool is removed. |
| `buffer_click` | Optional; starts use when equipped while use is already held. |

Switching tools cancels the outgoing action, unequips the old instance, then
creates and equips a fresh instance. Death and character removal cancel and
unequip it; respawning equips the selected slot again. Opening the HUD editor,
losing window focus, or releasing use over processed UI cancels the action.
Only a normal release calls `end_use`, so cancelling a bow draw does not shoot.
Cake enables `buffer_click` to retain its held-input buffer.

Hooks must return without yielding. Start yielding work such as RemoteFunction
calls through a named function passed to `task.spawn`. Keep action state inside
the factory, clear it synchronously on cancellation, and cancel pending server
work when appropriate. Tool modules should not subscribe to input, selection,
or character lifecycle events themselves. Disconnect tool-owned resources in
`unequip` and make cancellation safe to repeat.

The sword and cube modules delegate gameplay to existing combat and placement
helpers. Dissolver uses the existing prediction helper through its `start` and
`stop` API; the helper no longer listens for input. Bow and cake keep their
interaction state inside their factories. The cake server associates each
pending heal with one eating session and character, so an older request cannot
complete a restarted session or heal a replacement character.

## Adding a tool

1. Add its ID to `tool_types.id`.
2. Add a ModuleScript with a named factory returning `tool_types.tool`.
3. Require the factory and register it in `registry.luau`.
4. Put its ID in a slot in `LOADOUT.luau` when it should be carried.
5. Implement and validate any new gameplay effects on the server.

The client lifecycle does not provide server-owned inventories or equipped-tool
validation. Existing gameplay remotes retain their action validation. No item
variants, variant configuration, or inventory persistence are implemented.

## Verification in Studio

Check all five tools and empty slots. Hold use and switch to cake, then release
or switch away before it heals. Cancel and immediately restart eating to check
that the earlier request cannot finish the new session. Draw a bow and test
normal release, switching, focus loss, HUD editing, death, and respawning. Start
dissolving and check that those cancellation paths clear progress and stop
dissolving. Check that block placement and melee still work after respawning.
