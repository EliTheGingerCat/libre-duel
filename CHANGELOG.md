# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This project does **not** adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Melee attacking.
- Cube placing and mining.
- Version text in the bottom left.
- Local and server debug printing.
- Development guides.
- Notifications.
- Colour guide.
- Knockback.
- Tool registry with variants.
- Cube textures, with red and blue clay variants.
- Settings menu backed by real settings, with a button to open the HUD editor.
- Back button in the HUD editor, which also closes when clicking outside its bounds.
- UI blur setting, using [Objectual UI Blur](https://devforum.roblox.com/t/objectual-ui-blur-12-revision-2/3626057).
- HUD editor snap guides, widget outlines, and a reset button.
- Play button above the hotbar that opens the mode selector.

### Changed

- Queue modes are defined once in `shared/queue/QUEUE_MODES.luau`.
- The crosshair is now the only code that changes the mouse cursor; menus request a free cursor through `cursor_state`.
- Shared UI fonts and colours live in `FONTS.luau` and `COLOURS.luau`.
- Default HUD widget positions live in `HUD_DEFAULTS.luau`.
- Keystrokes and mousestrokes start hidden and are added from the HUD selector.
- The HUD editor dims the world, shows a short hint instead of the welcome text, and has a clearer toolbar.

### Fixed

- The infoboard now scales on small displays.
- The ban command now passes a list of user IDs to `BanAsync`.
- The server now rejects public keys that are not buffers.
