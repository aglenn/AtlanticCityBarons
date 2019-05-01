require("board")
require("deck")
require("actions")
require("touch")

lastCard = nil

gw = 10 * SCORE_WIDTH + 20
gh = 9*SCORE_WIDTH + 2*SCORE_HEIGHT + 20
scale = 1

function love.draw()
    love.graphics.scale(scale)
    love.graphics.setBackgroundColor(10 / 255, 108 / 255, 3 / 255)    
    Board:render(10 + (width-gw)/2, 10)
    
    if lastCard then
        Deck.renderCard(lastCard, 10, 150)
    end
    love.graphics.rectangle("line", t.x, t.y, t.width, t.height)
    love.graphics.scale(1.0)

end

-- https://github.com/vrld/hump
-- https://github.com/robtandy/ship-game/blob/master/main.lua
function love.load()
    -- love.window.setMode(480, 800, {resizable=true})
    width, height = love.graphics.getDimensions()
    print(width,height)
    print(gw,gh)
    sx = width/gw
    sy = height/gh
    scale = math.min( sx, sy)
    print(sx, sy, scale)
    Board:init()
    Deck:init()
    Deck:insertEnd()

    
    t = Touchable:new("Test target", 10, 10, 50, 50)
    Touch:add(t)
end

function love.mousereleased(x, y)
    love.touchreleased(1, x, y)
end

function love.touchreleased(id, x, y)
    Touch:handle(x,y)
end