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

 - Place console.lua in your project
 - Require it in your main file:
```
local console = require("console")
```
 - Hook into Love2D callbacks:
```
function love.draw()
    if console.draw() then return end
end

function love.textinput(t)
    if console.textinput(t) then return end
end

function love.keypressed(key, scancode, isrepeat)
    if console.keypressed(key, scancode, isrepeat) then return end
end
```
 - Function Storage Example:
```
function test()
    console.print("This is a test function!")
end

-- First component is the name, that the function will be stored as.
-- Second component is the function itself.
console.Storefunctions("test",test)
```

> [!IMPORTANT]
> There always should be a name and a function. Or the code won't work


 - You can put as much functions as user wants.
```
console.Storefunctions("test1",test1,"test2",test2,"test3",test3...)
```
# Requirements
[LÖVE 11.x](https://love2d.org/)

# License

MIT License – free to use, modify, and distribute.
