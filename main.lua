local console = require("console")

function test()
    console.print("This is a test function!")
end

function love.load()
    love.window.setTitle("Love2d typical game")
    love.window.setMode(600, 600)
    
    console.Storefunctions("test",test)
end

function love.draw()
    if console.draw() then return end
    love.graphics.print("Hello world!", 250, 250)
end

function love.textinput(t)
    if console.textinput(t) then return end
end

function love.keypressed(key, scancode, isrepeat)
    if console.keypressed(key, scancode, isrepeat) then return end
end