# Changelog

All notable changes to Pulse will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned for 0.2.0-alpha
- File search functionality
- Calculator mode improvements
- Settings panel
- Custom keyboard shortcuts

---

## [0.1.0-alpha.1] - 2026-02-11

### Added
- Global hotkey launcher (Cmd+Space alternative)
- Fuzzy search engine with ranking
- Application launcher with icons
- System commands:
  - Sleep
  - Restart
  - Shutdown
  - Lock Screen
  - Empty Trash (with confirmation)
- Premium confirmation dialog for destructive actions
  - Smooth fade-in and spring scale animations
  - Hover effects on buttons
  - Gradient styling
  - 60fps micro-interactions
- Custom UI components:
  - Floating NSPanel window
  - Custom scrollbar with hover effects
  - Dark mode support
  - Blur effects
- Usage tracking for recency ranking
- Keyboard-first navigation

### Technical
- SwiftUI + AppKit hybrid architecture
- Background agent (no Dock icon)
- NSPanel for floating window
- Automation permission support

### Known Issues
- Requires manual Automation permission grant for Empty Trash
- ViewBridge warnings in console (benign, macOS issue)
- FSFindFolder errors when permission not granted

---

## Version History

- **0.1.0-alpha.1** (2026-02-11) - Initial alpha release
