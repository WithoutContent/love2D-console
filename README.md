## Console.lua

A simple and customizable in-game console for [LÖVE](https://www.love2d.org/) (Love2D).\
It provides a lightweight debugging and command execution interface that can be easily integrated into your projects.

# Features
Toggleable in-game console `~`
- Built-in commands:
  - `help` – show help information
  - `commands` – list all available commands
  - `keybinds` – show keybinds
  - `clear` – clear console history
  - `quit / exit` – quit or close console
  - `print("text")` – print text into the console
  - `version` – show console version
  - `vsync(0/false | 1/true)` – control VSync
  - `info(0/false | 1/true)` – toggle info display
  - `function` – manage stored Lua functions (list, run, remove, clear)
  - `savelog` – save console output to a .txt file
 - Command autocompletion `(Tab key)`
 - Command history `(↑ / ↓ arrows)`
 - Clipboard support `(Ctrl+C, Ctrl+V, Ctrl+X)`
 - Custom print methods:
   - `console.print("text")` – print white text
   - `console.error("text")` – print warning/error text
   - `console.table({})` – pretty-print Lua tables
# Keybinds
 - `~`	Toggle console
 - `Left / Right arrows`	Move cursor
 - `Up / Down arrows`	Cycle command history
 - `Tab`	Autocomplete command
 - `Ctrl + Arrows`	Jump cursor to start/end
# Usage


> [!NOTE]
> The current version of the console is 1.0.0. There may be a few bugs.
