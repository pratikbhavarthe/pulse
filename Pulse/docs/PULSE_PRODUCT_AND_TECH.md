PULSE

Modern Command Launcher for macOS

Version: 0.1 (Foundational Build)

1\. Vision

Pulse is a fast, native, keyboard-first command interface for macOS.

The long-term goal:

Replace mouse-driven workflows with a unified command layer.

Pulse is not just a launcher.

It is intended to become:

The command center of the operating system.

2\. Problem We Are Solving

Modern macOS workflows are fragmented.

Users currently:

Use Spotlight for search

Use Dock for apps

Use Finder for files

Use menus for actions

Use mouse for most navigation

This creates:

Context switching

Slow workflows

High cognitive friction

Power users install multiple tools:

Raycast

Alfred

Rectangle

Clipboard managers

Script runners

But these tools:

Are heavy

Have fragmented UX

Are not modal-first

Often rely on plugins for basic workflows

3\. Pulse Core Idea

Keyboard is the primary interface.

Pulse provides:

One command palette

One input

One interaction model

Everything becomes:

Search → Select → Execute

4\. Inspiration / References

Historical

Quicksilver (philosophy)

LaunchBar

Modern

Raycast (UX polish)

Spotlight (speed)

VS Code Command Palette

Linear command menu

Superhuman command bar

5\. Product Philosophy

Speed First

Target:

Hotkey response < 30ms

Search latency < 10ms

Zero visible lag

Modal Interaction

Pulse supports multiple modes:

Fuzzy Mode (default search)

Leader Mode (key sequences)

Text Mode (command line)

Talk Mode (voice)

This is inspired by:

Vim

Emacs

Quicksilver

Local First

No cloud dependency

Private

Offline capable

6\. What Makes Pulse Different

1\. Modal Command System

Most launchers are:

Type → Open

Pulse supports:

Mode → Command → Action

This enables:

Leader key workflows

Power automation

Muscle memory usage

2\. Speed + Native Architecture

Unlike Electron-based tools:

100% Swift

AppKit + SwiftUI hybrid

Low memory footprint

Instant open

3\. Command Engine First

Pulse is designed as:

Command Engine

↑

Modes

↑

UI

Not:

UI → Features

This allows:

Automation

Extensions

AI later

4\. Learning Ranking Engine (Planned)

Pulse will rank results using:

Frequency

Recency

Context

Active app

7\. Tech Stack

Language

Swift 5+

UI

SwiftUI (view layer)

AppKit (window + system APIs)

System APIs

Accessibility

NSWorkspace

FSEvents (planned)

Launch Services

Architecture

Modular Swift Packages:

PulseCore

PulseSearch

PulseIndex

PulseRanking

PulseCommands

Storage (Planned)

SQLite

In-memory cache

8\. System Architecture

Hotkey

↓

AppDelegate

↓

LauncherPanel (NSPanel)

↓

Command Input

↓

Search Engine

↓

Ranking Engine

↓

Action Execution

9\. Features (Current Build)

Core Launcher Shell

Floating panel

Dockless agent app

Top-third screen positioning

Global hotkey toggle

Command UI

Input field

Results list

Live filtering

Auto-focus

Interaction

Enter executes command

Escape closes

(Arrow navigation in progress)

10\. Features Not Common in Existing Tools (Planned)

Modal Command System

Leader key workflows:

Space → F → Open Finder

Unified Action Engine

Everything becomes an action:

Open app

Move file

Rename

Run script

System control

Context-Aware Commands

Commands change based on:

Current app

Time

Location

Workflow

Voice + Text Hybrid Mode

Talk Mode:

Dictation → Command execution

11\. Development Phases

Phase 0 --- Foundation (Completed)

Native macOS agent app

Floating launcher panel

Global hotkey

SwiftUI + AppKit integration

Phase 1 --- Core Launcher (Current)

Command input

Results list

Filtering

Basic commands

Goal:

Spotlight-level functionality.

Phase 2 --- Power Features

App indexing

File indexing

Recents

Learning ranking

Goal:

Better than Spotlight.

Phase 3 --- Modal System

Leader mode

Key sequences

Command registry

Goal:

Power-user differentiation.

Phase 4 --- Productivity Layer

Clipboard history

Window switcher

Quick actions

Phase 5 --- Platform

Extension SDK

Plugin ecosystem

AI command parsing

12\. What We Have Completed So Far

Architecture

AppKit lifecycle

Agent app configuration

NSPanel launcher window

Interaction

Global hotkey (Option + Space)

Toggle open/close

Auto-focus input

UI

Command palette layout

Live filtering

Basic command execution

13\. Risks

Technical

Global hotkey reliability

File indexing performance

Ranking quality

Product

Competing with Raycast

User habit inertia

14\. Success Metrics

Hotkey → result time

Commands per session

Daily usage

Retention after 7 days

15\. Long-Term Vision

Pulse becomes:

The command layer for macOS

Not just a launcher.

Eventually:

AI command interface

Cross-app automation

Personal productivity OS layer

Next Logical Engineering Step

From here the highest impact move is:

App Indexing Engine

Because once Pulse can:

Type → Open Any App

Users will immediately switch from Spotlight.