# AI Approval Buttons for Stream Deck

A small Windows Stream Deck plugin for Codex, Claude, and other CLI or editor approval prompts.

The buttons send configurable key sequences to the currently focused window:

- Yes once: `1{ENTER}`
- Always: `2{ENTER}`
- No: `3{ENTER}`
- Custom: `{ENTER}`
- New Chat: `^n` (Ctrl+N)
- Model Menu: `^+m` (Ctrl+Shift+M)

You can edit every sequence in the Stream Deck property inspector.

## Easy Install

Download the latest `AI-Approval-Buttons.streamDeckPlugin` file from the GitHub releases page and double-click it.

Stream Deck will import the plugin automatically. Restart the Stream Deck app if the **AI Approval** category does not appear right away.

## Build

```powershell
.\build.ps1
```

This creates:

```text
dist\com.aiapproval.buttons.sdPlugin
```

## Install

```powershell
.\build.ps1 -Install
```

Then restart the Stream Deck app. The plugin category is **AI Approval**.

## Package for Sharing

```powershell
.\package.ps1
```

This creates:

```text
dist\AI-Approval-Buttons.streamDeckPlugin
```

## Sequence Syntax

The plugin uses Windows `SendKeys`. These are the most useful entries:

| What you want | Sequence |
| --- | --- |
| Press Enter | `{ENTER}` |
| Choose option 1, then Enter | `1{ENTER}` |
| Choose option 2, then Enter | `2{ENTER}` |
| Choose option 3, then Enter | `3{ENTER}` |
| Press Tab, then Enter | `{TAB}{ENTER}` |
| Press Down, then Enter | `{DOWN}{ENTER}` |
| Press Escape | `{ESC}` |
| Press Ctrl+N | `^n` |
| Press Ctrl+K | `^k` |
| Press Ctrl+Shift+M | `^+m` |
| Press Alt+Down | `%{DOWN}` |
| Type `y` | `y` |
| Type `n` | `n` |

Modifier keys use this shorthand:

| Key | Symbol |
| --- | --- |
| Ctrl | `^` |
| Shift | `+` |
| Alt | `%` |

For example, `^+m` means Ctrl+Shift+M.

Important: the target window must be focused. Stream Deck triggers the button, then the plugin sends the keys to the active window.
