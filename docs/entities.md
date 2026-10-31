# Entities

Gameplay uses `registry.entity`, defined as `string | Player` in
`ReplicatedStorage/shared/entity/registry.luau`. Players register automatically.
A string is a registered bot ID, separate from its character's display name.

To add a bot, parent its character model to Workspace, then call
`registry.register_bot(bot_id, character)` on the server. Give it a Humanoid and
HumanoidRootPart, as with a player character. IDs must be non-empty and unique
among registered bots. Keep an ID unchanged while the bot is registered.

The registry replicates bot identity using the `bot` CollectionService tag and
`entity_id` attribute. Bot teams use an `entity_team` ObjectValue; player teams
continue to use Roblox's Player properties. Use `registry.set_team` on the
server to change either kind of entity's team. A nil team means neutral.

Use `registry.get_character`, `registry.from_character`, `registry.get_name`,
`registry.get_team`, and `get_entity_position` instead of reading Player
properties in shared gameplay. `registry.get_all()` returns both kinds of entity.
The `added`, `removed`, `character_added`, and `changed` signals cover membership,
characters, and team changes. Subscribe before processing existing entities.

Server bot code can call the same gameplay modules as player remote handlers:

- `ServerScriptService/combat/attack_entity(attacker, target)` returns whether an
  attack succeeded. Both arguments are entities.
- `ServerScriptService/cube/place_cube(entity, position)` returns whether a block
  was placed.
- `ServerScriptService/cube/dissolve_cube.start(entity, id, cube)` starts dissolving
  and returns whether the request was accepted. Use `.stop(entity, id)` to cancel.

Player remote handlers supply the authenticated sender as the acting entity.
Clients cannot select a bot as their attacker or block placer. Click-rate
mitigation remains specific to player input; gameplay cooldowns apply to both.

Bridge assigns registered bots to teams alongside players. In Studio, bots also
count towards starting the local match. Published matches still require a
validated player queue roster; bots cannot create queue claims or teleport.
Registered bots receive hitboxes, collision groups, nametags, and tab-list entries.
Bot tab-list entries have no Roblox account thumbnail.

Call `registry.unregister_bot(bot_id)` to retire a bot without destroying its
model. Destroying its model also unregisters it. Membership removal clears its
cooldowns and pending dissolving operations and frees its Bridge team slot.
Unregistering does not destroy the character or its hitboxes. Bot AI, spawning,
and respawning remain the caller's responsibility; register each replacement
character after unregistering the previous one.

## Verification in Studio

Start a playtest with a player and a registered humanoid bot. Check that both
appear in the tab list, receive nametags, and join Bridge teams. Verify that each
can score against the opposing goal and that cages move both characters. Check
player-to-bot, bot-to-player, and bot-to-bot attacks, including friendly fire,
range, death, and cooldown rejection. Test bot block placement and dissolving,
then remove a bot during dissolving and confirm that its progress clears. Finally,
respawn a player and register a replacement bot to check character setup again.
