require("colors")
require("board")

GameState = {
    initial="initial",
    setup="setup",
    turn="turn",
    gameover="gameover",
}

ActionType = {
    playerSelect= "playerSelect",
    build = "build",
    sprawl = "sprawl",
    remodel = "remodel",
    reorganize = "reorganize",
    gamble = "gamble",
}

Game = {state=GameState.initial, pendingAction=nil, players={}, selectedBlock=nil}

BUTTON_HEIGHT = 50
BUTTON_WIDTH = 100

-- Buttons

TwoPlayerButton = Touchable:new("TwoPlayerButton", 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
function TwoPlayerButton:pressed()
    Game:setPendingPlayerCount(2)
end
Touch:add(TwoPlayerButton)

ThreePlayerButton = Touchable:new("ThreePlayerButton", 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
function ThreePlayerButton:pressed()
    Game:setPendingPlayerCount(3)
end
Touch:add(ThreePlayerButton)

FourPlayerButton = Touchable:new("FourPlayerButton", 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
function FourPlayerButton:pressed()
    Game:setPendingPlayerCount(4)
end
Touch:add(FourPlayerButton)

PendingActionButton = Touchable:new("PendingActionButton", 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
function PendingActionButton:new(name, pendingAction)
    local newButton = {name=name, pendingAction=pendingAction}
    self.__index = self                      
    return setmetatable(newButton, self)
end

function PendingActionButton:pressed()
    Game:setPendingAction(self.pendingAction)
end

BuildButton = PendingActionButton:new("Build", ActionType.build)
Touch:add(BuildButton)

SprawlButton = PendingActionButton:new("Sprawl", ActionType.sprawl)
Touch:add(SprawlButton)

RemodelButton = PendingActionButton:new("Remodel", ActionType.remodel)
Touch:add(RemodelButton)

ReorganizeButton = PendingActionButton:new("Reorganize", ActionType.reorganize)
Touch:add(ReorganizeButton)

GambleButton = PendingActionButton:new("Gamble", ActionType.gamble)
Touch:add(GambleButton)

EndTurnButton = Touchable:new("End Turn", 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
function EndTurnButton:pressed()
    Game:endTurn()
end
Touch:add(EndTurnButton)

CasinoSelectButton = Touchable:new("CasinoSelectButton", 0, 0, BUTTON_WIDTH, BUTTON_WIDTH)
function CasinoSelectButton:new(name, casinoColor)
    local newButton = {name=name, casinoColor=casinoColor}
    self.__index = self                      
    return setmetatable(newButton, self)
end

function CasinoSelectButton:pressed()
    Game:setPendingCasinoColor(self.casinoColor)
end

PurpleCasinoSelectButton = CasinoSelectButton:new("Purple Casino", "purple")
Touch:add(PurpleCasinoSelectButton)

GreyCasinoSelectButton = CasinoSelectButton:new("Grey Casino", "grey")
Touch:add(GreyCasinoSelectButton)

GreenCasinoSelectButton = CasinoSelectButton:new("Green Casino", "green")
Touch:add(GreenCasinoSelectButton)

RedCasinoSelectButton = CasinoSelectButton:new("Red Casino", "red")
Touch:add(RedCasinoSelectButton)

GoldCasinoSelectButton = CasinoSelectButton:new("Gold Casino", "gold")
Touch:add(GoldCasinoSelectButton)

ConfirmButton = Touchable:new("Confirm", 0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
function ConfirmButton:pressed()
    Game:confirm()
end
Touch:add(ConfirmButton)

function Game:init(numberOfPlayers)
    
    self.playerCount = numberOfPlayers
    for i=1,numberOfPlayers do
        self.players[i] = {money=0, scorePosition=1, playerNumber=i}
    end
    self.activePlayer=1

    self:setup()
end

function Game:render(x,y)
    --ToDo render buttons, activate + confirm, player money, active player
    if self.state == GameState.turn then
        local buttons = {BuildButton, SprawlButton, RemodelButton, ReorganizeButton, GambleButton}
        for i,button in ipairs(buttons) do
            buttonX = x + (i-1) * (BUTTON_WIDTH + 10)
            self:renderButton(button, buttonX, y)
        end
        
        self:renderButton(EndTurnButton, x + 5 * (BUTTON_WIDTH + 10) + 30, y + BUTTON_HEIGHT + 10, ScoreTextColors.high)

        if self.pendingAction then

            if self.pendingAction.type == ActionType.build or self.pendingAction.type == ActionType.remodel then
                local buttons = {PurpleCasinoSelectButton, GreyCasinoSelectButton, GreenCasinoSelectButton, RedCasinoSelectButton, GoldCasinoSelectButton}
                for i,button in ipairs(buttons) do
                    buttonX = x + (i-1) * (BUTTON_WIDTH + 10)
                    self:renderCasinoButton(button, buttonX, y + BUTTON_HEIGHT + 10)
                end
            end

            if self:canConfirm() then
                self:renderButton(ConfirmButton, x + 5 * (BUTTON_WIDTH + 10) + 30, y)
            end
        end
    end
end

function Game:renderCasinoButton(button, x, y)
    button.x = x
    button.y = y

    size = PROPERTY_SIZE
    innerSize = DIE_SIZE

    if button.casinoColor and self.pendingAction and self.pendingAction.casinoColor == button.casinoColor then
        love.graphics.setLineWidth(4)
    end

    love.graphics.setColor(CasinoColors[button.casinoColor])
    love.graphics.rectangle("fill", x, y, size, size)
    love.graphics.setColor(BackgroundColor)
    love.graphics.rectangle("fill", x + (size - innerSize)/2, y + (size - innerSize)/2, innerSize, innerSize)
    love.graphics.setColor({1, 1, 1})
    love.graphics.rectangle("line", x, y, size, size)
    love.graphics.setLineWidth(1)
end

function Game:renderButton(button, x, y, color)
    button.x = x
    button.y = y

    if button.pendingAction and self.pendingAction and self.pendingAction.type == button.pendingAction then
        love.graphics.setLineWidth(4)
    end

    love.graphics.setColor(color or ButtonColor)
    love.graphics.rectangle("fill", x, y, BUTTON_WIDTH, BUTTON_HEIGHT)
    love.graphics.setColor({1, 1, 1})
    love.graphics.rectangle("line", x, y, BUTTON_WIDTH, BUTTON_HEIGHT)
    love.graphics.printf(button.name, x, y + BUTTON_HEIGHT / 3, BUTTON_WIDTH, "center")
    love.graphics.setLineWidth(1)
end

-- State actions

function Game:setup()
    self.state = GameState.setup
        
    for _,player in pairs(self.players) do
        local card1 = Deck:draw()
        local card2 = Deck:draw()

        Game:pay(player, card1.startMoney + card2.startMoney)

        Game:actionTakeOver(player, card1)
        Game:actionTakeOver(player, card2)
    end

    Deck:insertEnd()

    Game:turnStart()
end

function Game:updateButtonState()
    local activeButtons = {}
    local inactiveButtons = {}

    if self.state == GameState.turn then
        table.insert(activeButtons, BuildButton)
        table.insert(activeButtons, SprawlButton)
        table.insert(activeButtons, RemodelButton)
        table.insert(activeButtons, ReorganizeButton)
        table.insert(activeButtons, GambleButton)
        table.insert(activeButtons, ConfirmButton)

        table.insert(inactiveButtons, TwoPlayerButton)
        table.insert(inactiveButtons, ThreePlayerButton)
        table.insert(inactiveButtons, FourPlayerButton)
    end

    for i,button in pairs(activeButtons) do
        button.active = true
    end

    for i,button in pairs(inactiveButtons) do
        button.active = false
    end
end

function Game:turnStart()
    Game:updateButtonState()
    Deck:draw()
    casinos = Board:casinos(Deck.lastCard.color)
    -- for _,casino in ipairs(casions) do
    --     self:score(casino.boss, casino.size)
    --     for _,property in ipairs(casino.properties) do
    --         self:pay(property.player, property.value)
    --     end
    -- end
    --ToDo pay non casinos
    for _,block in pairs(Board.blocks) do
        for _,property in ipairs(block) do
            if property.player and not property.casino then
                Game:pay(self.players[property.player], 1)
            end
        end
    end
    --ToDo check the card and trigger endgame
    self.state = GameState.turn
end


function Game:endTurn()
    local nextPlayer = (self.activePlayer + 1) % (self.playerCount + 1)
    if nextPlayer == 0 then nextPlayer = 1 end
    self.activePlayer = nextPlayer
    self:turnStart()
end

-- Bookkeeping

function Game:pay(player, amount)
    player.money = player.money + amount
end

function Game:score(player, amount)
    --ToDo score them if they can
    --ToDo change score data source to players
end

-- Action selection

function Game:setPendingPlayerCount(players)
    self.pendingAction = {type=ActionType.player}
end

function Game:setPendingCasinoColor(color)
    self.pendingAction.casinoColor = color
end

function Game:setPendingAction(actionType)
    self.pendingAction = {type=actionType}
end

function Game:selectPosition(property)
    if self.pendingAction then
        self.selectedBlock = property
        self.pendingAction.position = property
    end
end

function Game:setPendingPlayerCount(players)
    self.pendingAction = {type=ActionType.player, value=players}
end

function Game:canConfirm()
    if self.pendingAction.type == ActionType.build
    and self.pendingAction.position
    and self.pendingAction.casinoColor
    and self.pendingAction.position.player == self.activePlayer
    and not self.pendingAction.position.casino
    and self.players[self.activePlayer].money >= self.pendingAction.position.price then
        return true
    end

    return false
end

function Game:confirm()
    if self.pendingAction and self.pendingAction.type == ActionType.build then
        self:actionBuild(activePlayer, self.pendingAction.position, self.pendingAction.casinoColor)
    end
    --ToDo confirm action
    self.pendingAction = nil
    self.selectedBlock = nil
end

function Game:actionTakeOver(player, property)
    Board.blocks[property.block][property.lot].player = player.playerNumber
end

function Game:actionBuild(player, property, casinoType)
    print("Build. "..property.block..property.lot.." Casino color"..casinoType.." for $"..self.pendingAction.position.price)
    self.players[self.activePlayer].money = self.players[self.activePlayer].money - self.pendingAction.position.price
    Board.blocks[property.block][property.lot].casino = casinoType
    self:resolveTies()
end

function Game:actionSprawl(player, source, destination)
    self.players[self.activePlayer].money = self.players[self.activePlayer].money - self.pendingAction.position.price * 2
    Board.blocks[property.block][property.lot].casino = casinoType
    self:resolveTies()
end

function Game:actionRemodel(player, casinoMemberPosition)

    self:resolveTies()
end

function Game:actionReorganize(player, casinoMemberPosition)

    self:resolveTies()
end

function Game:actionGamble(gamblerPlayerNum, casinoPlayerNum, wager)

end

function Game:ResolveTies()

end