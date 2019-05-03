require("colors")
require("touch")

SCORE_HEIGHT = 30
SCORE_WIDTH = 60
PROPERTY_SIZE = 60
PROPERTY_PADDING = 2
DIE_SIZE = 18
PIP_SIZE = 3

Board = {blocks = {}}
Property = Touchable:new("Property", 0, 0, PROPERTY_SIZE, PROPERTY_SIZE)
function Property:new(block, lot, price, value, onStrip)
    local newProperty = {name=block..lot, block = block, lot=lot, price=price, value=value, onStrip = onStrip or false, lastReorgTurn = 0}
    self.__index = self                      
    return setmetatable(newProperty, self)
end

function Property:pressed()
    -- property["y"] = yssed()
    print("select "..self.name)
    Game:selectPosition(self)
end

function Board:init()
    blockCounts = {6, 6, 12, 9, 6, 9}
    blockNames = {'A', 'B', 'C', 'D', 'E', 'F'}


    blockA = {
        Property:new('A', 1, 9, 3),
        Property:new('A', 2, 6, 2),
        Property:new('A', 3, 15, 5, true),
        Property:new('A', 4, 12, 4),
        Property:new('A', 5, 9, 3),
        Property:new('A', 6, 20, 6, true),
    }
    self.blocks['A'] = blockA

    blockB = {
        Property:new('B', 1, 15, 5, true),
        Property:new('B', 2, 6, 2),
        Property:new('B', 3, 9, 3),
        Property:new('B', 4, 20, 6, true),
        Property:new('B', 5, 9, 3),
        Property:new('B', 6, 12, 4),
    }
    self.blocks['B'] = blockB

    blockC = {
        Property:new('C', 1, 12, 4),
        Property:new('C', 2, 9, 3),
        Property:new('C', 3, 20, 6, true),
        Property:new('C', 4, 6, 2),
        Property:new('C', 5, 8, 1),
        Property:new('C', 6, 12, 4, true),
        Property:new('C', 7, 6, 2),
        Property:new('C', 8, 8, 1),
        Property:new('C', 9, 12, 4, true),
        Property:new('C', 10, 9, 3),
        Property:new('C', 11, 6, 2),
        Property:new('C', 12, 15, 5, true),
    }
    self.blocks['C'] = blockC

    blockD = {
        Property:new('D', 1, 20, 6, true),
        Property:new('D', 2, 9, 3),
        Property:new('D', 3, 12, 4),
        Property:new('D', 4, 12, 4, true),
        Property:new('D', 5, 8, 1),
        Property:new('D', 6, 6, 2),
        Property:new('D', 7, 15, 5, true),
        Property:new('D', 8, 6, 2),
        Property:new('D', 9, 9, 3),
    }
    self.blocks['D'] = blockD

    blockE = {
        Property:new('E', 1, 9, 3),
        Property:new('E', 2, 6, 2),
        Property:new('E', 3, 15, 5, true),
        Property:new('E', 4, 12, 4),
        Property:new('E', 5, 9, 3),
        Property:new('E', 6, 20, 6, true),
    }
    self.blocks['E'] = blockE

    blockF = {
        Property:new('F', 1, 20, 6, true),
        Property:new('F', 2, 9, 3),
        Property:new('F', 3, 12, 4),
        Property:new('F', 4, 12, 4, true),
        Property:new('F', 5, 8, 1),
        Property:new('F', 6, 6, 2),
        Property:new('F', 7, 15, 5, true),
        Property:new('F', 8, 6, 2),
        Property:new('F', 9, 9, 3),
    }
    self.blocks['F'] = blockF

    if Game.playerCount == 2 then
        for _,property in ipairs(blockF) do
            property.active = false
        end
    end

    for i,block in pairs(self.blocks) do
        for j,property in pairs(block) do
            c = property[j]
            Touch:add(property)
        end
    end
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

    scorePlayerLocations = {}
    for _,player in pairs(Game.players) do
        local emptyTable = {}
        table.insert((scorePlayerLocations[player.scorePosition] or emptyTable), player.playerNumber)
        scorePlayerLocations[player.scorePosition] = (scorePlayerLocations[player.scorePosition] or emptyTable)
    end

    scoreY = y + 9*PROPERTY_SIZE + SCORE_HEIGHT
    for i=10,1,-1 do
        scoreX = x + (10-i) * SCORE_WIDTH
        local score = self.scores[i]
        score.playersPresent = scorePlayerLocations[i]
        self:renderHorizontalScore(score, ScoreTextColors.low, scoreX, scoreY)
    end

    for i=11,19 do
        scoreY = scoreY - SCORE_WIDTH
        local score = self.scores[i]
        score.playersPresent = scorePlayerLocations[i]
        self:renderVerticalScore(score, ScoreTextColors.medium, x, scoreY)
    end

    for i=20,29 do
        scoreX = x + (i-20) * SCORE_WIDTH
        local score = self.scores[i]
        score.playersPresent = scorePlayerLocations[i]
        self:renderHorizontalScore(score, ScoreTextColors.high, scoreX, y)
    end

    blockX, blockY = x + SCORE_HEIGHT + PROPERTY_SIZE/2, y + SCORE_HEIGHT
    self:renderBlock(self.blocks['A'], blockX,blockY)
    self:renderBlock(self.blocks['B'], blockX + 4*PROPERTY_SIZE,blockY)
    self:renderBlock(self.blocks['C'], blockX,blockY + 2.5*PROPERTY_SIZE)
    self:renderBlock(self.blocks['D'], blockX + 4*PROPERTY_SIZE,blockY + 2.5*PROPERTY_SIZE)
    self:renderBlock(self.blocks['E'], blockX,blockY + 7*PROPERTY_SIZE)
    if Game.playerCount > 2 then
        self:renderBlock(self.blocks['F'], blockX + 4*PROPERTY_SIZE,blockY + 6*PROPERTY_SIZE)
    end

    if Game.selectedBlock then
        love.graphics.setColor(0, 1, 0)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", Game.selectedBlock.x, Game.selectedBlock.y, PROPERTY_SIZE, PROPERTY_SIZE)
        love.graphics.setLineWidth(1)
    end

    if Game.selectedDestination then
        love.graphics.setColor(0, 0, 1)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", Game.selectedDestination.x, Game.selectedDestination.y, PROPERTY_SIZE, PROPERTY_SIZE)
        love.graphics.setLineWidth(1)
    end

    if Game.selectedCasino then
        local function innerMask()        
            for _,property in ipairs(Game.selectedCasino.properties) do
                love.graphics.rectangle("fill", property.x, property.y, PROPERTY_SIZE, PROPERTY_SIZE)
            end
        end
        love.graphics.stencil(innerMask, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        for _,property in ipairs(Game.selectedCasino.properties) do
            love.graphics.setColor(0, 1, 0)
            love.graphics.setLineWidth(8)
            love.graphics.rectangle("line", property.x, property.y, PROPERTY_SIZE, PROPERTY_SIZE)
            love.graphics.setLineWidth(1)
        end
        love.graphics.setStencilTest()
    end
end

function Board:renderVerticalScore(score, textColor, x, y)
    love.graphics.setColor(ScoreBackgroundColor)
    love.graphics.rectangle("fill", x, y, SCORE_HEIGHT, SCORE_WIDTH)
    love.graphics.setColor({1,1,1})
    love.graphics.rectangle("line", x, y, SCORE_HEIGHT, SCORE_WIDTH)
    if score.playersPresent then
        for i,player in ipairs(score.playersPresent) do
            playerColor = PlayerColors[player]
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
        self:renderProperty(block[i], x + column * PROPERTY_SIZE, y + row * PROPERTY_SIZE)
    end
end

function Board:renderProperty(property, x, y)


    property["x"] = x
    property["y"] = y

    casinoColor = {0, 0, 0}
    if property.casino then
        casinoColor = CasinoColors[property.casino]
    end

    love.graphics.setColor(casinoColor)
    love.graphics.rectangle("fill", x, y, PROPERTY_SIZE, PROPERTY_SIZE)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, PROPERTY_SIZE, PROPERTY_SIZE)
    love.graphics.print(property.name, x + PROPERTY_PADDING, y)
    love.graphics.print(property.price.." mil", x + PROPERTY_PADDING, y + 3 * PROPERTY_SIZE / 4 - PROPERTY_PADDING)

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
        playerColor[4] = 1.0
        love.graphics.circle("fill", x + dieX + DIE_SIZE/2, y + dieY + DIE_SIZE/2, DIE_SIZE)
    end
end

function Board:renderDie(value, color, x, y)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, DIE_SIZE, DIE_SIZE)

    midX = x + (DIE_SIZE / 2) - PIP_SIZE / 2
    midY = y + (DIE_SIZE / 2) - PIP_SIZE / 2

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

function Board:casinosColored(color)
    local casinos = self:casinos()
    local filteredCasinos = {}
    for _,casino in ipairs(casinos) do
        if casino.casinoColor == color then table.insert(filteredCasinos, casino) end
    end
    return filteredCasinos
end

function Board:casinosOnStrip()
    local casinos = self:casinos()
    local filteredCasinos = {}
    for _,casino in ipairs(casinos) do
        if casino.onStrip then table.insert(filteredCasinos, casino) end
    end
    return filteredCasinos
end

function Board:casinoContaining(property)
    local casinos = self:casinos()
    for _,casino in ipairs(casinos) do
        for _,casinoProperty in pairs(casino.properties) do
            if casinoProperty.name == property.name then
                return casino
            end
        end
    end
    return nil
end

function Board:casinos()
    local casinos = {}

    for blockLetter,block in pairs(Board.blocks) do
        local blockCasinos = {}
        for _,property in ipairs(block) do
            if property.casino then
                for _,casino in ipairs(blockCasinos) do
                    if casino.casinoColor == property.casino then
                        for _,casinoProperty in pairs(casino.properties) do
                            if self:adjacent(property, casinoProperty) then
                                table.insert(casino.properties, property)
                                casino.size = casino.size + 1
                                if property.onStrip then
                                    casino.onStrip = true
                                end
                                if casino.lastReorgTurn < property.lastReorgTurn then
                                    casino.lastReorgTurn = property.lastReorgTurn
                                end
                                goto found
                            end
                        end
                    end
                end
                local newCasino = {properties={property}, size=1, casinoColor=property.casino, onStrip=property.onStrip, lastReorgTurn=property.lastReorgTurn}
                table.insert(blockCasinos, newCasino)
                table.insert(casinos, newCasino)
            end
            ::found::
        end
    end

    -- determine bosses
    for _,casino in ipairs(casinos) do
        Board:computeBoss(casino)
    end
    return casinos
end

function Board:computeBoss(casino)
    local bossValue = 0
    local bossPlayer = nil

    local remodelCost = 0
    local reorganizeCost = 0
    for _,casinoProperty in ipairs(casino.properties) do
        if casinoProperty.value > bossValue then
            bossValue = casinoProperty.value
            bossPlayer = casinoProperty.player
        elseif casinoProperty.value == bossValue then
            bossPlayer = nil
        end
        remodelCost = remodelCost + 5
        reorganizeCost = reorganizeCost + casinoProperty.value
    end
    casino.boss = bossPlayer
    casino.remodelCost = remodelCost
    casino.reorganizeCost = reorganizeCost
end

function Board:adjacent(property1, property2)
    difference = math.abs(property1.lot - property2.lot)
    print("Is "..property1.name.." adjacent to "..property2.name.."("..difference..")")
    if difference == 3 then
        return true
    elseif difference == 1 then
        if property1.lot % 3 + property2.lot % 3 == 1 then
            return false
        else
            return true
        end        
    else -- 2 and > 3 can't be neighbors
        return false
    end
end