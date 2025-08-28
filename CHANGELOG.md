# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This project does **not** adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

## **Gamemode Service (Server-Side)**
- serverside gamemode/playground management system
- automatic RF creation
- creates playground codes
- player teleportation via MessagingService
- manages bridge, basicfight, and boxing queues
- auto server cleanup on shutdown
- player tp data handling for gamemode and playground servers
- Server metadata API for client consumption
- ttl ms service entry management with automatic refresh

Remote Functions:
- GetThisServerMetadata
- ResolvePlaygroundCode  
- CreatePlaygroundAndTeleport
- TeleportToPlaygroundByCode
- JoinQueue
- LeaveQueue
- GetQueueStatus
  ^^^ CHORE: inconsistent camel case -> snake case

## MemoryStoreService Hashmap Schema

### servers_map: "ld:servers"
server metadata indexed by jobId
```lua
["job id"] = {
    placeId = ,
    jobId = "",
    serverType = "playground", -- or "lobby", "bridge", "boxing", "basicfight"
    updatedAt = ,
    
    -- for playground servers
    ownerUserId = ,
    reservedAccessCode = "",
    playgroundCode = "", -- foreign key
    
    -- non playground
    gamemode = "bridge", -- uneccessary
    variant = "2v2", -- or "1v1", "3v3", "4v4"
    reservedAccessCode = ""
}
```

### playground_codes_map: "ld:playground_codes"
playground codes to server info
```lua
["AAAAAA"] = {
    jobId = "",
    placeId = ,
    updatedAt = 
}
```

### queues_map: "ld:queues"
queue data for each gamemode variant combination
```lua
["bridge-2v2"] = {
    players = {
        {
            userId = ,
            jobId = "", -- they can be in different servers
            joinedAt = 
        },
        {
            userId = ,
            jobId = "", -- they can be in different servers
            joinedAt = 
        }
    },
    createdAt = 
}