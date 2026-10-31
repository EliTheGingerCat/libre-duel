# Cross-server matchmaking

## Note

This is a pretty complex matchmaking system, but it's scales really well if the game ever gets a ton of players, unlike "standard" messagingservice implementations.
**Credits to morefeinn for the concept.**. I used AI to implement this from his original description.

The rest of the markdown file was written by AI.

## Overview

Players wait in their current lobby until a solo or duo match fills. Lobby servers discover shared match entries in MemoryStore sorted maps and claim individual slots with `UpdateAsync`. No coordinator server is needed. Teams remain nested dictionaries; each team contains members keyed by their string user IDs.

The claim callback checks the latest entry, removes expired waiting slots, chooses a team with space, and closes the match in the same write that fills its last slot. An earlier search result never authorises a teleport. Callback retries have no teleport or messaging side effects.

Once full, every lobby uses the match ID as `TeleportOptions.ReservedServerId`. Roblox creates the destination on the first teleport and routes subsequent teleports using that ID to the same reservation. MessagingService notifications wake up interested lobbies, with polling as a fallback if subscription or delivery fails. The destination validates each player's claim token against MemoryStore, binds the match to one destination job, and starts Bridge only after the complete claimed roster is present. The claimed teams are preserved.

## Configuration and setup

`src/ServerScriptService/queue/QUEUE_CONFIG.luau` contains mode capacities, shard count, search bounds, heartbeat timing, expiry, and retry limits. The current defaults are:

| Setting | Default |
| --- | --- |
| Solo | Two teams of one |
| Duo | Two teams of two |
| Shards per mode | One |
| Search page size | 25 entries |
| Maximum pages per shard | Four |
| Entry lifetime | 90 seconds |
| Slot lifetime | 45 seconds |
| Heartbeat interval | 10 seconds |
| Fallback poll interval | Two seconds |
| Full-match arrival deadline | 90 seconds |
| Teleport attempts | Three, with increasing delays |
| Minimum interval between client join requests | Two seconds |

Publish this place normally. Public servers are lobbies, and reserved instances of the same place host matches. No separate match place ID or external service is required. The server handles the existing `join_queue` and `leave_queue` RemoteFunctions; joining accepts `solo` or `duo` and returns a boolean. The existing client test script still automatically requests solo on an ordinary lobby join, but skips that request after a match teleport or an explicit return to the lobby. This is a development trigger, not a queue selection UI.

Cross-server matchmaking is disabled in Studio because TeleportService requires a published game running in the Roblox client. Studio retains the existing local Bridge playtest. Check the experience's teleport access settings when publishing. The installed local Roblox type definitions may predate `TeleportOptions.ReservedServerId`; refresh those definitions if the editor reports that this documented property is missing.

## Recovery and limits

- Heartbeats update only slots with matching claim tokens. They preserve slots claimed by other lobbies and never create a missing match entry.
- Leaving before a full match removes the slot. Leaving or losing a participant after it fills cancels that attempt so the remaining players can requeue. Leaving the queue is refused while a teleport is already in progress or a match is playing.
- Source servers retain claims during teleport; confirmed arrivals renew them at the destination. A crashed lobby's slots expire. A destination that cannot assemble its roster requeues its remaining players.
- A lost response to a committed start is recoverable at the same destination. Gameplay starts once, and only for the validated roster. A cancelled or expired assignment cannot start a partial match.
- Teleport failures retry up to the configured limit. After exhaustion, that player's claim is released and their queue request stops; they can request another queue. Backend failures can make a join return false. Unknown arrivals and unavailable admission checks are refused.
- Matches exclude incompatible Roblox cross-play matchmaking types. Region, parties, ranked ratings, widening skill ranges, recent-opponent avoidance, and rematches are not implemented because this project has no corresponding matchmaking data or party flow yet.
- Search is bounded and prefers the fullest compatible waiting match among the entries it finds. Pagination skips closed entries, but it does not search the entire map. Simultaneous searches can create separate partial matches. Empty or abandoned entries expire; matches are not merged.
- Shards distribute map traffic but do not increase the experience-wide MemoryStore quota. Increase them based on observed traffic. Change the map prefix version when changing the stored schema, team capacities, or shard layout during a rolling deployment so old and new servers do not interpret the same entries differently.
