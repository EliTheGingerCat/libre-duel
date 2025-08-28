# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This project does **not** adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Notification System** (react based ui)
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