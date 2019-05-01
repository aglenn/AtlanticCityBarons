require("colors")

SCORE_HEIGHT = 30
SCORE_WIDTH = 60
PROPERTY_SIZE = 60
PROPERTY_PADDING = 2
DIE_SIZE = 18
PIP_SIZE = 3

Board = {blocks = {}, selectedBlock=nil}


function Board:init()
    blockCounts = {6, 6, 12, 9, 6, 9}
    blockNames = {'A', 'B', 'C', 'D', 'E', 'F'}

    blockA = {
        {block = 'A', price=9, value=3},
        {block = 'A', price=6, value=2},
        {block = 'A', price=15, value=5},
        {block = 'A', price=12, value=4},
        {block = 'A', price=9, value=3},
        {block = 'A', price=20, value=6},
    }
    self.blocks['A'] = blockA

    blockB = {
        {block = 'B', price=15, value=5},
        {block = 'B', price=6, value=2},
        {block = 'B', price=9, value=3},
        {block = 'B', price=20, value=6},
        {block = 'B', price=9, value=3},
        {block = 'B', price=12, value=4},
    }
    self.blocks['B'] = blockB

    blockC = {
        {block = 'C', price=12, value=4},
        {block = 'C', price=9, value=3},
        {block = 'C', price=20, value=6},
        {block = 'C', price=6, value=2},
        {block = 'C', price=8, value=1},
        {block = 'C', price=12, value=4},
        {block = 'C', price=6, value=2},
        {block = 'C', price=8, value=1},
        {block = 'C', price=12, value=4},
        {block = 'C', price=9, value=3},
        {block = 'C', price=6, value=2},
        {block = 'C', price=15, value=5},
    }
    self.blocks['C'] = blockC

    blockD = {
        {block = 'D', price=20, value=6},
        {block = 'D', price=9, value=3},
        {block = 'D', price=12, value=4},
        {block = 'D', price=12, value=4},
        {block = 'D', price=8, value=1},
        {block = 'D', price=6, value=2},
        {block = 'D', price=15, value=5},
        {block = 'D', price=6, value=2},
        {block = 'D', price=9, value=3},
    }
    self.blocks['D'] = blockD

    blockE = {
        {block = 'E', price=9, value=3},
        {block = 'E', price=6, value=2},
        {block = 'E', price=15, value=5},
        {block = 'E', price=12, value=4},
        {block = 'E', price=9, value=3},
        {block = 'E', price=20, value=6},
    }
    self.blocks['E'] = blockE

    blockF = {
        {block = 'F', price=20, value=6},
        {block = 'F', price=9, value=3},
        {block = 'F', price=12, value=4},
        {block = 'F', price=12, value=4},
        {block = 'F', price=8, value=1},
        {block = 'F', price=6, value=2},
        {block = 'F', price=15, value=5},
        {block = 'F', price=6, value=2},
        {block = 'F', price=9, value=3},
    }
    self.blocks['F'] = blockF

    scoreValues = {
        0, 1, 2, 3, 4, 5, 6, 7, 8,
        10, 12, 14, 16, 18, 20,
        23, 26, 29, 32,
        36, 40, 44,
        49, 54,
        60, 66,
        73,
        81,
        90
    }

    self.scores = {}
    for i,score in ipairs(scoreValues) do
        self.scores[i] = {pointValue=score}
    end
    
end

function Board:render(x, y)

    scoreY = y + 9*PROPERTY_SIZE + SCORE_HEIGHT
    for i=10,1,-1 do
        scoreX = x + (10-i) * SCORE_WIDTH
        self:renderHorizontalScore(self.scores[i], ScoreTextColors.low, scoreX, scoreY)
    end

    for i=11,19 do
        scoreY = scoreY - SCORE_WIDTH
        self:renderVerticalScore(self.scores[i], ScoreTextColors.medium, x, scoreY)
    end

    for i=20,29 do
        scoreX = x + (i-20) * SCORE_WIDTH
        self:renderHorizontalScore(self.scores[i], ScoreTextColors.high, scoreX, y)
    end

    x, y = x + SCORE_HEIGHT * 1 + PROPERTY_SIZE, y + SCORE_HEIGHT * 1
    self:renderBlock(self.blocks['A'], x, y)
    self:renderBlock(self.blocks['B'], x + 4*PROPERTY_SIZE, y)
    self:renderBlock(self.blocks['C'], x, y + 2.5*PROPERTY_SIZE)
    self:renderBlock(self.blocks['D'], x + 4*PROPERTY_SIZE, y + 2.5*PROPERTY_SIZE)
    self:renderBlock(self.blocks['E'], x, y + 7*PROPERTY_SIZE)
    self:renderBlock(self.blocks['F'], x + 4*PROPERTY_SIZE, y + 6*PROPERTY_SIZE)

    
end

function Board:renderVerticalScore(score, textColor, x, y)
    love.graphics.setColor(ScoreBackgroundColor)
    love.graphics.rectangle("fill", x, y, SCORE_HEIGHT, SCORE_WIDTH)
    love.graphics.setColor({1,1,1})
    love.graphics.rectangle("line", x, y, SCORE_HEIGHT, SCORE_WIDTH)
    if score.playersPresent then
        for i,player in ipairs(score.playersPresent) do
            playerColor = PlayerColors[player]
            -- playerColor[4] = 0.5
            love.graphics.setColor(playerColor)
            love.graphics.circle("fill", x +((i-1)*4) + SCORE_HEIGHT/3, y + SCORE_WIDTH / 1.3, SCORE_HEIGHT/3)
        end
    end
    love.graphics.setColor({0,0,0})--textColor)
    love.graphics.printf(score.pointValue, x , y + SCORE_WIDTH/3, SCORE_HEIGHT, "center")
end

function Board:renderHorizontalScore(score, textColor, x, y)
    love.graphics.setColor(ScoreBackgroundColor)
    love.graphics.rectangle("fill", x, y, SCORE_WIDTH, SCORE_HEIGHT)
    love.graphics.setColor({1,1,1})
    love.graphics.rectangle("line", x, y, SCORE_WIDTH, SCORE_HEIGHT)
    if score.playersPresent then
        for i,player in ipairs(score.playersPresent) do
            playerColor = PlayerColors[player]
            -- playerColor[4] = 0.5
            love.graphics.setColor(playerColor)
            love.graphics.circle("fill", x + SCORE_WIDTH/4, y + ((i-1)*4) + SCORE_HEIGHT / 3, SCORE_HEIGHT/3)
        end
    end
    love.graphics.setColor({0,0,0})--textColor)
    love.graphics.printf(score.pointValue, x , y + SCORE_WIDTH/8, SCORE_WIDTH, "center")
end

function Board:renderBlock(block, x, y)
    for i,property in ipairs(block) do
        row = math.floor((i-1)/3)
        column = (i-1) % 3
        self:renderProperty(block[i], i, x + column * PROPERTY_SIZE, y + row * PROPERTY_SIZE)
    end
end

function Board:renderProperty(property, position, x, y)

    casinoColor = {0, 0, 0}
    if property.casino then
        casinoColor = CasinoColors[property.casino]
    end

    love.graphics.setColor(casinoColor)
    love.graphics.rectangle("fill", x, y, PROPERTY_SIZE, PROPERTY_SIZE)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, PROPERTY_SIZE, PROPERTY_SIZE)
    love.graphics.print(string.format( "%s%d", property.block, position), x + PROPERTY_PADDING, y)
    love.graphics.print(string.format( "%d mil", property.price, position), x + PROPERTY_PADDING, y + 3 * PROPERTY_SIZE / 4 - PROPERTY_PADDING)

    dieX = (PROPERTY_SIZE - DIE_SIZE) / 2
    dieY = dieX

    dieColor = {1,1,1}
    if property.player and property.casino then
        dieColor = PlayerColors[property.player]
    end

    self:renderDie(property.value, dieColor, x + dieX, y + dieY)

    if property.player and not property.casino then
        playerColor = PlayerColors[property.player]
        playerColor[4] = 0.5
        love.graphics.setColor(playerColor)
        love.graphics.circle("fill", x + dieX + DIE_SIZE/2, y + dieY + DIE_SIZE/2, DIE_SIZE)
    end
end

function Board:renderDie(value, color, x, y)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, DIE_SIZE, DIE_SIZE)

    midX = x + (DIE_SIZE / 2) - PIP_SIZE / 2
    midY = y + (DIE_SIZE / 2) - PIP_SIZE / 2

    quarterX = x + (DIE_SIZE / 4) - PIP_SIZE / 2
    quarterX = x + (DIE_SIZE / 4) - PIP_SIZE / 2
    quarterY = y + (DIE_SIZE / 4) - PIP_SIZE / 2

    threequarterX = x + (3 * DIE_SIZE / 4) - PIP_SIZE / 2
    threequarterY = y + (3 * DIE_SIZE / 4) - PIP_SIZE / 2

    love.graphics.setColor(0, 0, 0)
    if value == 1 then
        love.graphics.rectangle("fill", midX, midY, PIP_SIZE, PIP_SIZE)
    elseif value == 2 then
        love.graphics.rectangle("fill", quarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, threequarterY, PIP_SIZE, PIP_SIZE)
    elseif value == 3 then
        love.graphics.rectangle("fill", quarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", midX, midY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, threequarterY, PIP_SIZE, PIP_SIZE)
    elseif value == 4 then
        love.graphics.rectangle("fill", quarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", quarterX, threequarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, threequarterY, PIP_SIZE, PIP_SIZE)
    elseif value == 4 then
        love.graphics.rectangle("fill", quarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", quarterX, threequarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, threequarterY, PIP_SIZE, PIP_SIZE)
    elseif value == 5 then
        love.graphics.rectangle("fill", quarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", midX, midY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", quarterX, threequarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, threequarterY, PIP_SIZE, PIP_SIZE)
    elseif value == 6 then
        love.graphics.rectangle("fill", quarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", quarterX, midY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", quarterX, threequarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, quarterY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, midY, PIP_SIZE, PIP_SIZE)
        love.graphics.rectangle("fill", threequarterX, threequarterY, PIP_SIZE, PIP_SIZE)
    end
end