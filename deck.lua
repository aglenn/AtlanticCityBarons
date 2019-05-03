
require("colors")
Deck = {drawIndex=0, discards={}, lastCard=nil}

CARD_WIDTH=120
CARD_HEIGHT=200
DISCARD_WIDTH = CARD_WIDTH / 5

function Deck:init()
    counts = {6, 6, 12, 9, 6, 9}
    blocks = {"A", "B", "C", "D", "E", "F"}
    
    cards = {}
    colors = {}

    for i,color in ipairs({"red", "purple", "grey", "gold", "green"}) do
        for num=1,9 do
            colors[#colors+1] = color
        end
    end
    colors[#colors+1] = "strip"
    colors[#colors+1] = "strip"
    colors[#colors+1] = "strip"
    shuffle_util(colors)

    colorIndex = 1

    for i,b in ipairs(blocks) do
        for j=1,counts[i] do
            cards[#cards+1] = {block=b, lot=j, color=colors[colorIndex], startMoney=math.random(3,8)}
            colorIndex = colorIndex + 1
        end
    end

    self.cards = cards
    self:shuffle()
end

function Deck:render(x, y)
    if self.lastCard then
        self:renderCard(self.lastCard, x, y)
    end
    local i = 0
    for _,colorName in ipairs({"purple", "grey", "green", "red", "gold", "strip"}) do
        local color = CasinoColors[colorName]
        Deck:renderDiscard(x+i*(DISCARD_WIDTH + SPACER/2), y + CARD_HEIGHT + SPACER, self.discards[colorName], color)
        i = i + 1
    end
    
end

function Deck:renderCard(card, x, y)
    love.graphics.push()

    love.graphics.setColor(CasinoColors[card.color])
    love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, CARD_WIDTH, CARD_HEIGHT)
    love.graphics.setLineWidth(1)

    if card.block then     
        locationText = string.format("%s%d", card.block, card.lot)
        love.graphics.printf(locationText, x , y + CARD_HEIGHT/4, CARD_WIDTH, "center")
    else
        locationText= "End of Game"
        love.graphics.printf(locationText, x, y + CARD_HEIGHT/4, CARD_WIDTH - 8, "center")
    end
    

    if card.block then
        moneyText = string.format("%d million", card.startMoney)
        love.graphics.printf(moneyText,  x, y + CARD_HEIGHT/2, CARD_WIDTH, "center")
    end

    love.graphics.pop()
end

function Deck:renderDiscard(x, y, discard, color)
    love.graphics.setColor(color)
    love.graphics.circle("fill", x+DISCARD_WIDTH/2, y+DISCARD_WIDTH/2, DISCARD_WIDTH/2)
    love.graphics.setColor({1, 1, 1})
    love.graphics.printf(discard or 0,  x, y + DISCARD_WIDTH / 10, DISCARD_WIDTH, "center")
end

function Deck:draw()
    self.drawIndex = self.drawIndex + 1    
    self.lastCard = self.cards[self.drawIndex]
    self.discards[self.lastCard.color] = (self.discards[self.lastCard.color] or 0) + 1
    return self.lastCard
end

function Deck:insertEnd()
    endIndex = #self.cards+1
    threeQuarters = math.floor(3*endIndex/4)
    self.cards[endIndex] = {endOfGame=true,color="strip"}
    self.cards[threeQuarters], self.cards[endIndex] = self.cards[endIndex], self.cards[threeQuarters]
end

function Deck:shuffle()
    shuffle_util(self.cards)
end

function shuffle_util(t)
    for i=1,3 do
        for i,item in ipairs(t) do
            newIndex = math.random(1, #t)
            t[i], t[newIndex] = t[newIndex], t[i]
        end
    end
end