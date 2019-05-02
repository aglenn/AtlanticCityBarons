require("board")
require("deck")
require("touch")
require("game")
require("colors")

gw = 10 * SCORE_WIDTH + 20
gh = 9*SCORE_WIDTH + 2*SCORE_HEIGHT + 20 + BUTTON_HEIGHT + BUTTON_WIDTH + 40
scale = 1

function love.draw()
    love.graphics.scale(scale)
    love.graphics.setBackgroundColor(BackgroundColor)
    local startPointX = 10 + (width-gw)/2
    Board:render(startPointX, 10)

    renderInfo(startPointX + 8.5 * PROPERTY_SIZE + SCORE_WIDTH, gh / 6)
    Deck:render(startPointX + 8.5 * PROPERTY_SIZE + SCORE_WIDTH, gh / 2 - CARD_HEIGHT / 2)
    Game:render(startPointX, 9*SCORE_WIDTH + 2*SCORE_HEIGHT + 20)

    love.graphics.scale(1.0)
end

function renderInfo(x, y)
    infoX = x
    local activePlayer = Game.players[Game.activePlayer]
    if activePlayer then        
        love.graphics.setColor(PlayerColors[activePlayer.playerNumber])
        love.graphics.rectangle("fill", x, y, BUTTON_WIDTH, BUTTON_HEIGHT)
        love.graphics.setColor({1, 1, 1})
        love.graphics.printf("Player "..activePlayer.playerNumber.."'s turn", x, y + BUTTON_HEIGHT / 4, BUTTON_WIDTH, "center")
        y = y + BUTTON_HEIGHT * 1.5
    else
        love.graphics.setColor({1, 1, 1})
    end
    for i,player in pairs(Game.players) do
        infoY = y+20*(i-1)
        local playerNumber = player.playerNumber
        local playerMoney = player.money
        local playerScore = Board.scores[player.scorePosition].pointValue
        love.graphics.print("Player "..playerNumber.." has $"..playerMoney.." million and "..playerScore.." points",infoX,infoY)        
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
    print(width,height)
    print(gw,gh)
    sx = width/gw
    sy = height/gh
    scale = math.min( sx, sy)
    print(sx, sy, scale)
    love.graphics.setNewFont(14)
end

function love.mousereleased(x, y)
    love.touchreleased(1, x, y)
end

function love.touchreleased(id, x, y)
    Touch:handle(x/scale,y/scale)
end