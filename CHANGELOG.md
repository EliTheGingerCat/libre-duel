# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This project does **not** adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

**GUI Manager System**
- centralized visibility management
- lets only one gui be open at a time
- api for showing/hiding game interface panels
- state setters to register gui
- for big gui in the centre of the screen (like bridge npc gui or party list)

**example of how to use it**
```
local gui_manager = require(ReplicatedStorage.client.modules.gui_manager)

-- register a ui with its visibility setter
gui_manager.register_gui("bridge", set_is_visible)

-- show a specific gui, will hide others automatically
gui_manager.show_gui("bridge")

-- hide a specific ui
gui_manager.hide_gui("bridge")

--hide all guis
gui_manager.hide_all_guis()
```


**Notification System**
COLOR THEME:
- Success, Green: #85dd32
- Error, Red: #ff6464  
- Info?, Blue: #0da2dd -- could be success like in bridge duel
- Orange: #e67e22
- Purple: #9b59b6
- Red Team: #ff6464  --change these later if you want
- Blue Team: #0da2dd 
- White: #ffffff -- was info in bridge duel
- Document more colours at the top of the notificaiotn_system module

example of how to use it:

local notification_system = require(ReplicatedStorage.client.modules.notification_system)

notification_system.show("success message", "#85dd32")

notification_system.show("player", "#0da2dd", " was killed by ", "#ffffff", "oTillyy", "#b14c4e")

**Added**
- Melee attacking.
- Cube placing.
- Version text in the bottom left.
- Local and server debug printing.
- Development guides.