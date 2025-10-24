require "class"
require "colliders"

require "variables"
require "util"

require "map"
require "player"
require "game"

gameState = ""

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    love.window.setMode(SCREEN_WIDTH*DEFAULT_SCALE, SCREEN_HEIGHT*DEFAULT_SCALE, { vsync = true, msaa = 0, highdpi = true, resizable=true})
    love.window.setTitle("Slime to the Top")

    sprites = {}
    sprites.slime = love.graphics.newImage("assets/slime.png")

    gameCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)

    love.graphics.setBackgroundColor(0, 0, 0)

    setGameState("game")
end

function love.update()
    if not love.window.hasFocus() then return end
    
    if _G[gameState .. "_update"] then
        _G[gameState .. "_update"](dt)
    end
end

function love.draw()
    if _G[gameState .. "_draw"] then
        _G[gameState .. "_draw"]()
    end

    love.graphics.setCanvas()
    local w, h = love.graphics.getDimensions()
    local scl = math.min(w/SCREEN_WIDTH, h/SCREEN_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, w/2, h/2, 0, scl, scl, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
end

function love.keypressed(key, scancode, isrepeat)
    if _G[gameState .. "_keypressed"] then
		_G[gameState .. "_keypressed"](key, scancode, isrepeat)
	end
end

function love.keyreleased(key, scancode, isrepeat)
    if _G[gameState .. "_keyreleased"] then
		_G[gameState .. "_keyreleased"](key, scancode, isrepeat)
	end
end

function setGameState(newGameState)
    gameState = newGameState

    if _G[gameState .. "_load"] then
		_G[gameState .. "_load"]()
	end
end