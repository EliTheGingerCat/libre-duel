# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This project does **not** adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

**Queue Status GUI**
- queue status display at bottom of screen
- current queue .e.g. 2/4
- displays gamemode (eg bridge 1v1)
- Cancel queue functionality with loading states
- updates every 0.3 seconds
- global force update function. other guis will call it
- need to move it above the hotbar like in bridge, its currently at the very bottom middle of the screen