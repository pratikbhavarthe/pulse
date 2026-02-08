---
trigger: always_on
---

Pulse -- Antigravity Agent Rules
==========================

Project Overview
----------------

Pulse is a **native macOS command launcher** built in Swift using AppKit + SwiftUI.

Primary goals:

-   Extreme speed

-   Keyboard-first workflows

-   Modal command system

-   Local-first architecture

-   Raycast-level UX with lower latency

The project is a **system utility**, not a normal app.

* * * * *

Core Philosophy
===============

Speed Over Everything
---------------------

All suggestions must prioritize:

-   Low latency

-   Minimal memory usage

-   Native APIs

-   No heavy abstractions

Avoid:

-   Over-engineered patterns

-   Large frameworks

-   Electron-style architecture

* * * * *

Native First
------------

Use:

-   Swift

-   AppKit for system-level behavior

-   SwiftUI only for view layer

Do NOT suggest:

-   Electron

-   React Native

-   Flutter

-   WebView-based UI

* * * * *

Command Engine First Architecture
---------------------------------

Pulse is structured as:

`Command Engine
  ↑
Modes
  ↑
UI`

Not:

`UI → Features`

All new features should be implemented as **Actions** or **Commands**.

* * * * *

Performance Rules
=================

Always prefer:

-   In-memory caching

-   Pre-indexed data

-   Background threads for heavy work

Never:

-   Block main thread

-   Perform disk search on every query

-   Load icons synchronously

Target:

-   Hotkey response < 30ms

-   Search latency < 10ms

* * * * *

macOS System Behavior Rules
===========================

Pulse is a **background agent app**.

Required behaviors:

-   No Dock icon

-   No Cmd+Tab presence

-   Floating NSPanel window

-   Global hotkey activation

Use:

-   NSPanel

-   Accessibility APIs

-   NSWorkspace

-   Event monitors

Avoid:

-   Standard NSWindow for launcher UI

-   Storyboards

* * * * *

UX Principles
=============

Pulse is:

-   Keyboard-first

-   Minimal

-   Fast

Always ensure:

-   Input is auto-focused

-   Actions require minimal steps

-   No unnecessary animations

-   No modal dialogs during core flow

* * * * *

Modal Interaction Model
=======================

Pulse supports:

-   Fuzzy Mode (default)

-   Leader Mode

-   Text Mode

-   Talk Mode

Future features must integrate with the mode system.

Do not create isolated feature UIs.

* * * * *

Command System Rules
====================

Everything must be represented as:

`Action
Command
Source`

Examples:

-   Open App

-   Open File

-   Run Script

-   Toggle Setting

Commands must be:

-   Stateless

-   Fast to execute

-   Searchable

* * * * *

Extension Architecture (Future)
===============================

Pulse will support:

-   Local extensions first

-   Sandboxed execution

-   Command registration

Design new systems so they can be exposed to extensions later.

Avoid tight coupling.

* * * * *

Code Style Guidelines
=====================

Prefer:

-   Small focused files

-   Clear naming

-   Explicit logic

Avoid:

-   Deep inheritance

-   Overuse of Combine

-   Complex reactive chains

Use:

-   Swift Concurrency when helpful

-   Simple GCD where faster

* * * * *

Search & Ranking Rules
======================

Search engine must support:

-   Fuzzy matching

-   Prefix matching

-   Initials matching

Ranking should consider:

-   Frequency

-   Recency

-   Context

Never implement naive alphabetical sorting.

* * * * *

Security & Privacy
==================

Pulse is local-first.

Never:

-   Log keystrokes

-   Send usage data externally

-   Require network access for core features

Permissions must be:

-   Justified

-   Progressive

-   Optional when possible

* * * * *

Feature Priority Order
======================

When suggesting features, prioritize:

1.  Speed improvements

2.  Ranking accuracy

3.  Keyboard workflows

4.  System integrations

5.  Extensions

6.  AI features (last)

* * * * *

Anti-Patterns To Avoid
======================

Do NOT introduce:

-   Heavy UI animations

-   Complex state machines early

-   Network dependencies

-   Feature bloat

Pulse must remain:

**Fast, predictable, minimal.**

* * * * *

Definition of Done (Engineering)
================================

A feature is complete only if:

-   It works entirely via keyboard

-   Adds no noticeable latency

-   Integrates with command system

-   Is searchable

* * * * *

Long-Term Vision
================

Pulse is evolving into:

**A universal command layer for macOS**

Future capabilities:

-   Automation

-   Context-aware actions

-   AI command parsing

-   Extension ecosystem

All architectural decisions must support this trajectory.