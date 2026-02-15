# Pulse Versioning Scheme

## Semantic Versioning Format
`MAJOR.MINOR.PATCH-PHASE.BUILD`

Example: `0.1.0-alpha.1`, `0.5.0-beta.3`, `1.0.0`

---

## Version Phases

### 🔬 Alpha (Development Phase)
**Format**: `0.x.y-alpha.z`
- **Purpose**: Internal development and testing
- **Stability**: Unstable, breaking changes expected
- **Audience**: Developers only
- **Examples**: 
  - `0.1.0-alpha.1` - First alpha build
  - `0.2.0-alpha.5` - Fifth build of 0.2.0 alpha
  - `0.3.0-alpha.12` - Twelfth build of 0.3.0 alpha

**Current Phase**: `0.1.0-alpha.1`

---

### 🧪 Beta (Testing Phase)
**Format**: `0.x.y-beta.z`
- **Purpose**: External testing with early adopters
- **Stability**: Feature-complete, minor bugs expected
- **Audience**: Beta testers, early adopters
- **Examples**:
  - `0.5.0-beta.1` - First beta release
  - `0.8.0-beta.3` - Third beta build
  - `0.9.0-beta.10` - Release candidate approaching

---

### 🚀 Release (Production)
**Format**: `MAJOR.MINOR.PATCH`
- **Purpose**: Public release
- **Stability**: Stable, production-ready
- **Audience**: General public
- **Examples**:
  - `1.0.0` - First public release
  - `1.1.0` - Minor feature update
  - `1.1.1` - Patch/bugfix
  - `2.0.0` - Major version with breaking changes

---

## Version Number Meanings

### MAJOR (X.0.0)
Increment when:
- Breaking changes to user workflows
- Complete UI redesign
- Major architecture changes
- Incompatible with previous versions

### MINOR (0.X.0)
Increment when:
- New features added
- Significant improvements
- Backwards-compatible changes

### PATCH (0.0.X)
Increment when:
- Bug fixes
- Performance improvements
- Minor tweaks
- Security patches

### BUILD (.alpha.X or .beta.X)
Increment for each build within the same phase.

---

## Release Roadmap

### Phase 1: Alpha Development
- **0.1.0-alpha.1** ← **Current**
  - Basic search functionality
  - App launcher
  - System commands
  - Empty Trash confirmation dialog ✅
  
- **0.2.0-alpha.1**
  - File search
  - Calculator mode
  - Settings panel

- **0.3.0-alpha.1**
  - Plugins/extensions support
  - Custom themes

### Phase 2: Beta Testing
- **0.5.0-beta.1**
  - Feature freeze
  - Bug fixing
  - Performance optimization

- **0.8.0-beta.1**
  - UI polish
  - Final testing
  - Documentation

### Phase 3: Public Release
- **1.0.0**
  - First stable public release
  - Full documentation
  - App Store submission

---

## How to Update Version

### In Xcode:
1. Select project in navigator
2. Select target "Pulse"
3. General tab → Identity section
4. Update **Version** (e.g., `0.1.0-alpha.1`)
5. Update **Build** (auto-increment or manual)

### In Info.plist:
```xml
<key>CFBundleShortVersionString</key>
<string>0.1.0-alpha.1</string>
<key>CFBundleVersion</key>
<string>1</string>
```

---

## Changelog

### 0.1.0-alpha.1 (Current)
**Features:**
- ✅ Global hotkey launcher
- ✅ Fuzzy search
- ✅ App launching
- ✅ System commands (Sleep, Restart, Shutdown, Lock, Empty Trash)
- ✅ Premium confirmation dialog for Empty Trash
- ✅ Hover effects and micro-interactions
- ✅ Custom scrollbar
- ✅ Dark mode UI

**Known Issues:**
- Automation permission required for Empty Trash
- ViewBridge warnings in console (benign)

---

## Git Tagging

Tag releases in git:
```bash
# Alpha
git tag -a v0.1.0-alpha.1 -m "Alpha 1: Initial development build"

# Beta
git tag -a v0.5.0-beta.1 -m "Beta 1: First public testing release"

# Release
git tag -a v1.0.0 -m "Release 1.0.0: First stable public release"

git push --tags
```
