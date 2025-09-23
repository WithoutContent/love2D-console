--[[
    Love2d console
    version 1.0.0
    by WithoutContent
    
    MIT License:
    Copyright (c) 2025 WithoutContent

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]--

local console = {}

local lastname = ""
local lastwidth, lastheight, lastflags = 0, 0, 0

local enabled = false
local info = false

local prefix = "> "
local text = {"","",""}
local fulltext = ""

local commandsuggested = ""

local args = {}

local version = "1.0.0"

local currentctrl = 1

local sendcommands = {}
local sendcommandsindex = 0
local storedfuncs = {}

local commandsCodes = {
    ["clear"] = function () args = {} end,
    ["help"] = function ()
        local lines = {
            "[Console] Help:",
            "welcome to the console!",
            "type 'commands' to see a list of available commands."
        }
        table.insert(args, {table.concat(lines, "\n"), "cyan", os.time()})
    end,
    ["keybinds"] = function ()
        local lines = {
            "[Console] Keybinds:",
            "- ` or ~ : toggles the console",
            "- backspace or delete : deletes the character to the left of the cursor",
            "- left arrow : moves the cursor one character to the left",
            "- right arrow : moves the cursor one character to the right",
            "- up arrow : cycles through previously entered commands (older)",
            "- down arrow : cycles through previously entered commands (newer)",
            "- tab : autocompletes the current command if a suggestion is available",
            "- enter or numpad enter : submits the current command",
            "- ctrl + left arrow : moves the cursor to the beginning of the current command",
            "- ctrl + right arrow : moves the cursor to the end of the current command",
            "- ctrl + a : selects all text in the current command",
            "- ctrl + c : copies the selected text to the clipboard",
            "- ctrl + v : pastes text from the clipboard at the cursor position",
            "- ctrl + x : cuts the selected text to the clipboard"
        }
        table.insert(args, {table.concat(lines, "\n"), "cyan", os.time()})
    end,
    ["quit"] = function () love.event.quit() end,
    ["exit"] = function () enabled = false
        love.window.setTitle(lastname)
        love.window.setMode(lastwidth, lastheight, lastflags)
    end,
    ["print"] = function (t)
        if type(t) ~= "string" then return end
        if string.sub(t, 6, 6) == "(" and string.sub(t, -1) == ")" then
            if (string.sub(t, 7, 7) == '"' and string.sub(t, -2, -2) == '"') or (string.sub(t, 7, 7) == "'" and string.sub(t, -2, -2) == "'") then
                console.print(string.sub(t, 8, -3))
            else
                table.insert(args, {"[Warning] print command only accepts strings enclosed in single or double quotes!","red",os.time()})
            end
        else
            table.insert(args, {"[Warning] print command syntax error! Correct syntax: print(\"your text here\") or print('your text here')","red",os.time()})
        end
    end,
    ["version"] = function ()
        table.insert(args, {"[Console] Version: "..version,"cyan",os.time()})
    end,
    ["vsync"] = function (t) 
        if type(t) ~= "string" then return end
        if string.sub(t, 6, 6) == "(" and string.sub(t, -1) == ")" then
            local param = string.sub(t, 7, -2)
            if param == "0" or param == "false" then
                love.window.setVSync(0)
                lastflags.vsync = 0
                table.insert(args, {"[Console] VSync disabled.","cyan",os.time()})
            elseif param == "1" or param == "true" then
                love.window.setVSync(1)
                lastflags.vsync = 1
                table.insert(args, {"[Console] VSync enabled.","cyan",os.time()})
            else
                table.insert(args, {"[Warning] vsync command only accepts '0'/'false' or '1'/'true' as parameters!","red",os.time()})
            end
        else
            table.insert(args, {"[Warning] vsync command syntax error! Correct syntax: vsync(0/false) or vsync(1/true)","red",os.time()})
        end
    end,
    ["info"] = function (t) 
        if type(t) ~= "string" then return end
        if string.sub(t, 5, 5) == "(" and string.sub(t, -1) == ")" then
            local param = string.sub(t, 6, -2)
            if param == "0" or param == "false" then
                info = false
                table.insert(args, {"[Console] Info display disabled.","cyan",os.time()})
            elseif param == "1" or param == "true" then
                info = true
                table.insert(args, {"[Console] Info display enabled.","cyan",os.time()})
            else
                table.insert(args, {"[Warning] info command only accepts '0'/'false' or '1'/'true' as parameters!","red",os.time()})
            end
        else
            table.insert(args, {"[Warning] info command syntax error! Correct syntax: info(0/false) or info(1/true)","red",os.time()})
        end
    end,
    ["function"] = function (t)
        if type(t) ~= "string" then
            local lines = {
            "[Console] Function commands:",
            "- function run <name> : calls the stored function with the specified name",
            "- function list : lists all stored functions",
            "- function remove <name> : removes the stored function with the specified name",
            "- function clear : removes all stored functions"
            }
            table.insert(args, {table.concat(lines, "\n"), "cyan", os.time()})
            return
         end
        if string.sub(t, 9, 9) == " " then
            local param = t:sub(10):match("^%s*(.-)%s*$")
            if param == "list" then
                table.insert(args, {"[Console] Stored functions:","cyan",os.time()})
                local count = 0
                for name, _ in pairs(storedfuncs) do
                    table.insert(args, {"- "..name,"cyan",os.time()})
                    count = count + 1
                end
                if count == 0 then
                    table.insert(args, {"[Console] No stored functions.","cyan",os.time()})
                end
            elseif string.sub(param, 1, 3) == "run" then
                local fname = param:sub(4):match("^%s*(.-)%s*$")
                if fname == "" then
                    table.insert(args, {"[Warning] function run command requires a function name as parameter!","red",os.time()})
                elseif storedfuncs[fname] then
                    local status, err = pcall(storedfuncs[fname])
                    if not status then
                        table.insert(args, {"[Error] Error while executing function '"..fname.."': "..err,"red",os.time()})
                    else
                        table.insert(args, {"[Console] Function '"..fname.."' executed successfully.","cyan",os.time()})
                    end
                else
                    table.insert(args, {"[Warning] No stored function with the name '"..fname.."'!","red",os.time()})
                end
            elseif string.sub(param, 1, 6) == "remove" then
                local fname = param:sub(7):match("^%s*(.-)%s*$")
                if fname == "" then
                    table.insert(args, {"[Warning] function remove command requires a function name as parameter!","red",os.time()})
                elseif storedfuncs[fname] then
                    storedfuncs[fname] = nil
                    table.insert(args, {"[Console] Function '"..fname.."' removed successfully.","cyan",os.time()})
                else
                    table.insert(args, {"[Warning] No stored function with the name '"..fname.."'!","red",os.time()})
                end
            elseif param == "clear" then
                storedfuncs = {}
                table.insert(args, {"[Console] All stored functions removed.","cyan",os.time()})
            else
                table.insert(args, {"[Warning] Unknown function command parameter: "..param.." , type 'help' for help.","red",os.time()})
            end
            else
            table.insert(args, {"[Warning] function command syntax error! Correct syntax: function list | function run <name> | function remove <name> | function clear","red",os.time()})
        end
    end,
    ["github"] = function ()
        -- no git hub link yet
        table.insert(args, {"[Console] GitHub link not available yet.","cyan",os.time()})
    end,
    ["savelog"] = function ()
        local script_dir = love.filesystem.getSourceBaseDirectory()
        if not script_dir then
            table.insert(args, {"[Error] Could not determine script directory.","red",os.time()})
            return
        end

        local path = script_dir .. "/console_log (".. os.time() ..").txt"
        local file, err = io.open(path, "w")
        if not file then
            table.insert(args, {"[Error] Could not create log file: "..tostring(err),"red",os.time()})
            return
        end

        table.insert(args, {"[Console] Log saved to console_log.txt","cyan",os.time()})
        table.insert(args, {"[Console] Log file path: "..path,"cyan",os.time()})

        for _, v in ipairs(args) do
            file:write(v[3] .. "  -  "..v[1].. "\n")
        end

        file:close()
    end,

    ["commands"] = function ()
        local lines = {
            "[Console] Available commands:",
            "- clear : clears the console",
            "- help : shows this help message",
            "- commands : shows this list of commands",
            "- keybinds : shows a list of keybinds",
            "- quit or exit : closes the console or quits the game",
            "- print(\"your text here\") or print('your text here') : prints the specified text to the console",
            "- version : shows the console version",
            "- vsync(0/false) or vsync(1/true) : disables or enables vsync",
            "- info(0/false) or info(1/true) : disables or enables the info display when the console is closed",
            "- github : shows the GitHub link of the console (not available yet)",
            "- function : shows help for function commands",
            "- savelog : saves the current console log to a file named console_log.txt"
        }
        table.insert(args, {table.concat(lines, "\n"), "cyan", os.time()})
    end,
}

local colorCodes = {
    ["black"] = {0,0,0,1},
    ["red"] = {1,0,0,1},
    ["green"] = {0,1,0,1},
    ["blue"] = {0,0,1,1},
    ["yellow"] = {1,1,0,1},
    ["cyan"] = {0,1,1,1},
    ["magenta"] = {1,0,1,1},
    ["white"] = {1,1,1,1},
    ["gray"] = {0.5,0.5,0.5,1},
    ["lime"] = {0.5,1,0.5,1},
    ["pink"] = {1,0.5,0.5,1},
    ["orange"] = {1,0.65,0,1},
    ["purple"] = {0.5,0,0.5,1},
    ["brown"] = {0.6,0.4,0.2,1},
}

function linelimit(nr)
    if nr > 35 then
        repeat
            table.remove(args, 1)
            nr = nr - 1
        until nr <= 35
    end
end

function detectcommand(t)
    if commandsCodes[t] and t ~= "function" then
        commandsCodes[t]()
    else
        if string.sub(t, 1, 5) == "print" then
            commandsCodes["print"](t)
        elseif string.sub(t, 1, 5) == "vsync" then
            commandsCodes["vsync"](t)
        elseif string.sub(t, 1, 4) == "info" then
            commandsCodes["info"](t)
        elseif string.sub(t, 1, 8) == "function" then
            commandsCodes["function"](t)
        else
            table.insert(args, {"[Warning] Unknown command: "..t.." , type 'help' for help.","red",os.time()})
        end
    end
end

function console.textinput(t)
    if t == "`" or t == "~" then
        enabled = not enabled
        if not enabled then
            love.window.setTitle(lastname)
            love.window.setMode(lastwidth, lastheight, lastflags)
        else
            lastname = love.window.getTitle()
            love.window.setTitle("Console Enabled")
            lastwidth, lastheight, lastflags = love.window.getMode()
            love.window.setMode(800, 600, {resizable = false})
        end
        return
    end

    if not enabled then return end

    text[1] = text[1] .. text[2]
    if t == "(" then
        text[2] = t
        text[3] = ")" .. text[3]
    elseif t == "{" then
        text[2] = t
        text[3] = "}" .. text[3]
    elseif t == "[" then
        text[2] = t
        text[3] = "]" .. text[3]
    elseif t == '"' or t == "'" then
        text[2] = t
        text[3] = t .. text[3]
    else
        text[2] = t
    end
end

function console.draw()
    love.graphics.reset()
    if not enabled then
        if not info then return end

        love.graphics.setColor(colorCodes["white"])
        love.graphics.print("Console version "..version.." by WithoutContent", 10, 10)
        love.graphics.print("Vsync : "..tostring(love.window.getVSync()), 10, 25)
        love.graphics.print("Fps : "..tostring(love.timer.getFPS()), 10, 40)
        love.graphics.print("Lua version : ".._VERSION, 10, 55)
        love.graphics.print("Love2d version : "..love.getVersion(), 10, 70)
        love.graphics.print("Window size : "..tostring(love.graphics.getWidth()).."x"..tostring(love.graphics.getHeight()), 10, 85)
        x, y = love.window.getPosition()
        love.graphics.print("Window position : "..tostring(x)..","..tostring(y), 10, 100)

        return 
    end

    love.graphics.line( 10,550,790,550)

    fulltext = text[1] .. text[2] .. text[3]
    local fulltextlenght = string.len(fulltext)

    for k, _ in pairs(commandsCodes) do
        local n = false
        local y = false
        for i = 1, fulltextlenght do
            if string.sub(fulltext, i,i) == string.sub(k, i,i) then
                n = true
                y = true
            else
                n = false
                y = false
                commandsuggested = ""
                break
            end
        end
        if n then
            love.graphics.setColor(1,1,1,0.5)
            love.graphics.print(prefix .. k, 20, 565)
            commandsuggested = k
        end
        if y then break end
    end

    love.graphics.setColor(colorCodes["white"])
    love.graphics.print(prefix .. text[1], 20, 565)
    love.graphics.setColor(colorCodes["cyan"])
    love.graphics.print(text[2], 20 + love.graphics.getFont():getWidth(prefix) + love.graphics.getFont():getWidth(text[1]), 565)
    love.graphics.setColor(colorCodes["white"])
    love.graphics.print(text[3], 20 + love.graphics.getFont():getWidth(prefix) + love.graphics.getFont():getWidth(text[1])+ love.graphics.getFont():getWidth(text[2]), 565)

    local p = 0
    for nr, v in ipairs(args) do
        local color = colorCodes[v[2]] or colorCodes["white"]
        love.graphics.setColor(color)
        for line in string.gmatch(v[1], "[^\n]+") do
            love.graphics.print(line, 20, 20 + (p)*15)
            p = p + 1
        end
    end
    linelimit(p)

    return true
end

function console.keypressed(key, scancode, isrepeat)
    if not enabled then return end

    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    if not ctrl then
        currentctrl = 1
    end

    if key == "backspace" or key == "delete" then
        text[2] = ""
        if #text[1] > 0 then
            text[2] = text[1]:sub(-1)
            text[1] = text[1]:sub(1, -2)
        end
    elseif key == "return" or key == "kpenter" then
        table.insert(sendcommands, text[1] .. text[2] .. text[3])
        table.insert(args, {"[Console] : "..text[1] .. text[2] .. text[3],"white",os.time()})

        sendcommandsindex = 0
        currentctrl = 1

        detectcommand(text[1] .. text[2] .. text[3])

        text = {"","",""}
    elseif key == "left" then
        if ctrl then
            if currentctrl <= 1 then
                text[2] = text[1]:sub(-1) .. text[2]
                text[1] = text[1]:sub(1, -2)
            else
                text[3] = text[2]:sub(-1) .. text[3]
                text[2] = text[2]:sub(1, -2)
            end
            currentctrl = currentctrl - 1
        else
            if #text[1] > 0 then
                text[3] = text[2] .. text[3]
                text[2] = text[1]:sub(-1)
                text[1] = text[1]:sub(1, -2)
            end
        end
    elseif key == "right" then
        if ctrl then
            if currentctrl >= 1 then
                text[2] = text[2] .. text[3]:sub(1, 1)
                text[3] = text[3]:sub(2)
            else
                text[1] = text[1] .. text[2]:sub(1, 1) 
                text[2] = text[2]:sub(2)
            end
            currentctrl = currentctrl + 1
        else
            if #text[3] > 0 then
                text[1] = text[1] .. text[2]
                text[2] = text[3]:sub(1, 1)
                text[3] = text[3]:sub(2)
            end
        end
    elseif key == "up" then
        if #sendcommands > 0 then
            if sendcommandsindex == 0 then
                sendcommandsindex = #sendcommands + 1
            end
            sendcommandsindex = sendcommandsindex - 1
            if sendcommands[sendcommandsindex] then
                text = {sendcommands[sendcommandsindex],"",""}
            else
                sendcommandsindex = sendcommandsindex + 1
            end
        end
    elseif key == "down" then
        if #sendcommands > 0 then
            if sendcommandsindex == 0 then
                sendcommandsindex = 1
            else
                sendcommandsindex = sendcommandsindex + 1
                if sendcommandsindex == #sendcommands + 1 then
                    sendcommandsindex = 0
                    text = {"","",""}
                    return
                end
            end
            if sendcommands[sendcommandsindex] then
                text = {sendcommands[sendcommandsindex],"",""}
            else
                sendcommandsindex = sendcommandsindex - 1
            end
        end
    elseif key == "tab" then
        if commandsuggested ~= "" then
            if commandsuggested == "print" or commandsuggested == "vsync" or commandsuggested == "info" then
                text = {commandsuggested .. "(", "", ")"}
            else
                text = {commandsuggested,"",""}
            end
            commandsuggested = ""
        end
    elseif key == "v" and ctrl then
        local clip = love.system.getClipboardText()
        if clip and clip ~= "" then
            text[1] = text[1] .. text[2]
            text[2] = clip
            text[3] = "" .. text[3]
        end
    elseif key == "c" and ctrl then
        love.system.setClipboardText(text[2])
    elseif key == "a" and ctrl then
        text[2] = text[1] .. text[2] .. text[3]
        text[1] = ""
        text[3] = ""
    elseif key == "x" and ctrl then
        love.system.setClipboardText(text[2])
        text[2] = ""
    end
end

function console.print(printable)
    if not printable then return end

    local info = debug.getinfo(2, "Sl")
    local src = info.short_src or "?"
    local line = info.currentline or -1

    if type(printable) ~= "string" then
        table.insert(args, {"(" .. src .. ":" .. line .. ") string expected, instead got ".. type(printable),"red",os.time()})
        table.insert(args, {"[Warning] console.print only accepts strings!","red",os.time()})
        return
    end

    table.insert(args, {"(" .. src .. ":" .. line .. ") : "..printable,"white",os.time()})
end

function console.error(printable)
    if not printable then return end

    local info = debug.getinfo(2, "Sl")
    local src = info.short_src or "?"
    local line = info.currentline or -1

    if type(printable) ~= "string" then
        table.insert(args, {"(" .. src .. ":" .. line .. ") string expected, instead got ".. type(printable),"red",os.time()})
        table.insert(args, {"[Warning] console.error only accepts strings!","red",os.time()})
        return
    end

    table.insert(args, {"(" .. src .. ":" .. line .. ") : "..printable,"yellow",os.time()})
end

function console.table(printable)
    if not printable then return end

    local info = debug.getinfo(2, "Sl")
    local src = info.short_src or "?"
    local line = info.currentline or -1

    if type(printable) ~= "table" then
        table.insert(args, {"(" .. src .. ":" .. line .. ") table expected, instead got ".. type(printable),"red",os.time()})
        table.insert(args, {"[Warning] console.table only accepts tables!","red",os.time()})
        return
    end

    local tnr = #printable

    table.insert(args, {"(" .. src .. ":" .. line .. ") : {","lime",os.time()})
    for k, v in pairs(printable) do
        local value = tostring(v)
        if type(v) == "string" then
            value = '"' .. value .. '"'
        end
        if tnr == k then
                table.insert(args, {"  [" .. tostring(k) .. "] = " .. value,"white",os.time()})
            else
                table.insert(args, {"  [" .. tostring(k) .. "] = " .. value .. ",","white",os.time()})
        end
    end
    table.insert(args, {"}","lime",os.time()})
end

function console.Storefunctions(...)
    local funcs = {...}

    if #funcs == 0 then return end
    if #funcs % 2 ~= 0 then
        table.insert(args, {"[Warning] console.Storefunctions requires pairs of function names (string) and functions!","red",os.time()})
        return
    end

    for i = 1,#funcs/2 do
        local name = funcs[i*2-1]
        local func = funcs[i*2]

        if type(name) ~= "string" then
            table.insert(args, {"[Warning] console.Storefunctions requires pairs of function names (string) and functions! Argument #" .. tostring(i*2-1) .. " is not a string.","red",os.time()})
            return

        elseif type(func) ~= "function" then
            table.insert(args, {"[Warning] console.Storefunctions requires pairs of function names (string) and functions! Argument #" .. tostring(i*2) .. " is not a function.","red",os.time()})
            return
        elseif storedfuncs[name] then
            table.insert(args, {"[Warning] console.Storefunctions: function name '" .. name .. "' is already stored!","red",os.time()})
            return
        else
            storedfuncs[name] = func
        end
    end
end

return console