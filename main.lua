require("board")
require("deck")
require("touch")
require("game")
require("colors")

SPACER = 10
gw = 10 * SCORE_WIDTH + SPACER*2 + 4 * BUTTON_WIDTH
gh = 9*SCORE_WIDTH + 2*SCORE_HEIGHT + SPACER*2 + BUTTON_HEIGHT + BUTTON_WIDTH + SPACER*2
scale = 1

 function love.draw()
     
    love.graphics.scale(scale)
    love.graphics.setBackgroundColor(BackgroundColor)
    local startPointX = SPACER --+ (width-gw)/2

    love.graphics.setFont(boardFont)
    Board:render(startPointX, SPACER)
    
    love.graphics.setFont(logFont)
    renderEventLog(startPointX + 8.5 * PROPERTY_SIZE + SCORE_WIDTH + CARD_WIDTH + SPACER, gh / 2 - CARD_HEIGHT / 2)
    
    love.graphics.setFont(otherFont)
    renderInfo(startPointX + 7.5 * PROPERTY_SIZE + SCORE_WIDTH, 2*SCORE_HEIGHT + SPACER)
    Deck:render(startPointX + 7.5 * PROPERTY_SIZE + SCORE_WIDTH, gh / 2 - CARD_HEIGHT / 2)
    Game:render(startPointX, 9*SCORE_WIDTH + 2*SCORE_HEIGHT + 20)
    
    love.graphics.scale(1.0)

    love.graphics.print(love.timer.getFPS(), gw, 10)
end

function renderInfo(x, y)
    infoX = x
    love.graphics.setColor({0, 0, 0})
    for i,player in pairs(Game.players) do
        y = y+love.graphics.getFont():getHeight()*(i-1)
        local playerNumber = player.playerNumber
        local playerMoney = player.money
        local playerScore = Board.scores[player.scorePosition].pointValue
        love.graphics.print("Player "..playerNumber.." has $"..playerMoney.." million and "..playerScore.." points",infoX,y)        
    end
    y = y + love.graphics.getFont():getHeight() + SPACER
    local activePlayer = Game.players[Game.activePlayer]
    if activePlayer then        
        love.graphics.setColor(PlayerColors[activePlayer.playerNumber])
        love.graphics.rectangle("fill", x, y, BUTTON_WIDTH, BUTTON_WIDTH)
        love.graphics.setColor({0, 0, 0})
        love.graphics.printf("Player "..activePlayer.playerNumber.."'s turn", x, y + BUTTON_WIDTH/4, BUTTON_WIDTH, "center")
    end
end

function renderEventLog(x, y)
    love.graphics.setColor({0, 0, 0})
    for i,log in ipairs(Game.eventLog) do
        logY = y + (i-1)*(love.graphics.getFont():getHeight() + SPACER/2)
        love.graphics.printf(log, x, logY, BUTTON_WIDTH * 4, "left")
    end
end

-- https://github.com/vrld/hump
-- https://github.com/robtandy/ship-game/blob/master/main.lua
function love.load()
    math.randomseed (os.time ())

    configureWindow()
    Board:init()
    Deck:init()

    Game:init(2)
end

function configureWindow()
    width, height = love.graphics.getDimensions()
    -- print(width,height)
    -- print(gw,gh)
    sx = width/gw
    sy = height/gh
    scale = math.min( sx, sy)
    -- print(sx, sy, scale)
    boardFont = love.graphics.newFont(14)
    logFont = love.graphics.newFont(16)    
    otherFont = love.graphics.newFont(18)    
end

function love.mousereleased(x, y)
    love.touchreleased(1, x, y)
end

function love.touchreleased(id, x, y)
    Touch:handle(x/scale,y/scale)
end