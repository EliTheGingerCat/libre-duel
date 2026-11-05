# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This project does **not** adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Melee attacking.
- Cube placing and dissolving.
- Version text in the bottom left.
- Local and server debug printing.
- Development guides.
- Notifications.
- Colour guide.
- Knockback.
- Tool registry with variants.
- Sphere and brown cube variants.
- Settings menu backed by real settings, with a button to open the HUD editor.

### Changed

- Queue modes are defined once in `shared/queue/QUEUE_MODES.luau`.
- The crosshair is now the only code that changes the mouse cursor; menus request a free cursor through `cursor_state`.
- Shared UI fonts and colours live in `FONTS.luau` and `COLOURS.luau`.

### Fixed

- The ban command now passes a list of user IDs to `BanAsync`.
- The server now rejects public keys that are not buffers.
