require("colors")
require("board")

--ToDo Casino color limits, player dice limits

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

Game = {state=GameState.initial, pendingAction=nil, players={}, gambled = false, eventLog={}}

BUTTON_HEIGHT = 50
BUTTON_WIDTH = 110

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

ConfirmButton = Touchable:new("Confirm", 0, 0, BUTTON_WIDTH, BUTTON_WIDTH)
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
            buttonX = x + (i-1) * (BUTTON_WIDTH + SPACER)
            self:renderButton(button, buttonX, y, PlayerColors[self.activePlayer])
        end
        
        self:renderButton(EndTurnButton, x + 5 * (BUTTON_WIDTH + SPACER) + SPACER*3, y + BUTTON_WIDTH + SPACER)

        if self.pendingAction then

            if self.pendingAction.type == ActionType.build or self.pendingAction.type == ActionType.remodel then
                local buttons = {PurpleCasinoSelectButton, GreyCasinoSelectButton, GreenCasinoSelectButton, RedCasinoSelectButton, GoldCasinoSelectButton}
                for i,button in ipairs(buttons) do
                    buttonX = x + (i-1) * (PROPERTY_SIZE * 1.5) + PROPERTY_SIZE
                    self:renderCasinoButton(button, buttonX, y + BUTTON_HEIGHT + SPACER)
                end
            end

            local confirmAlpha = 0.5
            if self:canConfirm() then
                confirmAlpha = 1.0
                ConfirmButton.active = true
            else
                ConfirmButton.active = false
            end            
            self:renderButton(ConfirmButton, x + 5 * (BUTTON_WIDTH + SPACER) + SPACER*3, y, PlayerColors[self.activePlayer], confirmAlpha)
        end
    elseif self.state == GameState.gameover then
        --ToDo new game
        love.graphics.printf("Game Over", x, y, 6 * BUTTON_WIDTH, "center")
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

function Game:renderButton(button, x, y, color, alpha)
    button.x = x
    button.y = y

    backgroundColor = color or ButtonColor
    backgroundColor[4] = alpha

    love.graphics.setColor(backgroundColor)
    love.graphics.rectangle("fill", x, y, button.width, button.height)

    love.graphics.setColor({0, 0, 0, alpha})
    love.graphics.printf(button.name, x, y + button.height / 3, button.width, "center")

    if button.pendingAction and self.pendingAction and self.pendingAction.type == button.pendingAction then
        love.graphics.setLineWidth(4)
        love.graphics.setColor({1, 1, 1, alpha})
    end

    love.graphics.rectangle("line", x, y, button.width, button.height)
        
    love.graphics.setLineWidth(1)
end

-- State actions

function Game:setup()
    self.state = GameState.setup
        
    for _,player in pairs(self.players) do
        ::drawcard1::
        local card1 = Deck:draw()
        if self.playerCount == 2 and card1.block == "F" then goto drawcard1 end
        ::drawcard2::
        local card2 = Deck:draw()
        if self.playerCount == 2 and card2.block == "F" then goto drawcard2 end

        self:pay(player.playerNumber, card1.startMoney + card2.startMoney)

        self:actionTakeOver(player.playerNumber, card1)
        self:actionTakeOver(player.playerNumber, card2)
    end

    Deck:insertEnd()

    self.currentTurn = 1
    self:turnStart()
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

        if self.pendingAction and (self.pendingAction.type == ActionType.build or self.pendingAction.type == ActionType.remodel) then
            table.insert(activeButtons, PurpleCasinoSelectButton)
            table.insert(activeButtons, GreyCasinoSelectButton)
            table.insert(activeButtons, GreenCasinoSelectButton)
            table.insert(activeButtons, GoldCasinoSelectButton)
            table.insert(activeButtons, RedCasinoSelectButton)
        else
            table.insert(inactiveButtons, PurpleCasinoSelectButton)
            table.insert(inactiveButtons, GreyCasinoSelectButton)
            table.insert(inactiveButtons, GreenCasinoSelectButton)
            table.insert(inactiveButtons, GoldCasinoSelectButton)
            table.insert(inactiveButtons, RedCasinoSelectButton)
        end

        table.insert(inactiveButtons, TwoPlayerButton)
        table.insert(inactiveButtons, ThreePlayerButton)
        table.insert(inactiveButtons, FourPlayerButton)
    elseif self.state == GameState.gameover then
        table.insert(inactiveButtons, BuildButton)
        table.insert(inactiveButtons, SprawlButton)
        table.insert(inactiveButtons, RemodelButton)
        table.insert(inactiveButtons, ReorganizeButton)
        table.insert(inactiveButtons, GambleButton)
        table.insert(inactiveButtons, ConfirmButton)

        table.insert(inactiveButtons, PurpleCasinoSelectButton)
        table.insert(inactiveButtons, GreyCasinoSelectButton)
        table.insert(inactiveButtons, GreenCasinoSelectButton)
        table.insert(inactiveButtons, GoldCasinoSelectButton)
        table.insert(inactiveButtons, RedCasinoSelectButton)

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
    startMessage = "Start Player "..self.activePlayer.."'s Turn ^"
    print(startMessage)
    table.insert( self.eventLog,1, startMessage)
    self:updateButtonState()

    ::startofturndraw::
    local redraw = false
    card = Deck:draw()
    if card.block and not (self.playerCount == 2 and card.block == "F") then
        self:actionTakeOver(self.activePlayer, card)
    elseif self.playerCount == 2 and card.block == "F" then
        local redrawMessage = "F block card drawn. Scoring and then drawing another."
        print(redrawMessage)
        table.insert(self.eventLog, 1, redrawMessage)
        redraw = true
    end

    local casinos = {}
    if card.color == "strip" then
        casinos = Board:casinosOnStrip()
    else
        casinos = Board:casinosColored(card.color)
    end
    for _,casino in ipairs(casinos) do
        local scoreMessage = "Player "..casino.boss.." scores "..casino.size.." for casino containing "..casino.properties[1].name
        print(scoreMessage)
        table.insert(self.eventLog, 1, scoreMessage)
        self:score(casino.boss, casino.size)
        for _,property in ipairs(casino.properties) do
            local payMessage = "Pay $"..property.value.." million for "..property.casino.." casino at "..property.name.." to player "..property.player
            print(payMessage)
            table.insert(self.eventLog, 1, payMessage)
            self:pay(property.player, property.value)
        end
    end
    --pay non casinos
    for _,block in pairs(Board.blocks) do
        for _,property in ipairs(block) do
            if property.player and not property.casino then
                local payMessage = "Pay $1 million for property "..property.name.." to player "..property.player
                print(payMessage)
                table.insert(self.eventLog, 1, payMessage)
                self:pay(property.player, 1)
            end
        end
    end

    if redraw then goto startofturndraw end

    if card.endOfGame then
        self.state = GameState.gameover
    else
       self.state = GameState.turn
    end
end

function Game:endTurn()
    self.pendingAction = nil
    self.selectedBlock = nil
    self.selectedDestination = nil
    self.selectedCasino = nil
    self.gambled = false
    local nextPlayer = (self.activePlayer + 1) % (self.playerCount + 1)
    if nextPlayer == 0 then nextPlayer = 1 end
    self.activePlayer = nextPlayer
    self.currentTurn = self.currentTurn + 1
    table.insert(self.eventLog, 1, "-")
    self:turnStart()
end


-- Bookkeeping

function Game:pay(playerNumber, amount)
    local player = self.players[playerNumber]
    player.money = player.money + amount
end

function Game:score(playerNumber, amount)
    local player = self.players[playerNumber]
    local currentPosition = player.scorePosition
    local currentScore = Board.scores[currentPosition].pointValue

    local desiredScore = currentScore + amount

    repeat
        local nextScorePosition = currentPosition + 1
        local nextScoreValue = Board.scores[nextScorePosition].pointValue
        if desiredScore >= nextScoreValue then
            currentPosition = nextScorePosition
        end
        print("Checking "..nextScoreValue)
    until(nextScoreValue > desiredScore)
    player.scorePosition = currentPosition
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
    self.selectedBlock = nil
    self.selectedDestination = nil
    self.selectedCasino = nil
    self:updateButtonState()
end

function Game:selectPosition(property)
    if self.pendingAction then
        if self.pendingAction.type == ActionType.build then
            if property.player == self.activePlayer then
                self.selectedBlock = property
                self.pendingAction.position = property
                ConfirmButton.name = "Confirm ($"..property.price.."M)"
            end
        elseif self.pendingAction.type == ActionType.sprawl then
            if property.player == self.activePlayer then
                self.selectedBlock = property
                self.pendingAction.position = property
            elseif self.pendingAction.position and not property.player and Board:adjacent(self.pendingAction.position, property) then
                self.selectedDestination = property
                self.pendingAction.destination = property
                ConfirmButton.name = "Confirm ($"..(property.price*2).."M)"
            end
        elseif self.pendingAction.type == ActionType.remodel then
            local casino = Board:casinoContaining(property)
            if casino and casino.boss == self.activePlayer then
                self.selectedCasino = casino
                self.pendingAction.casino = casino
                ConfirmButton.name = "Confirm ($"..casino.remodelCost.."M)"
            end
        elseif self.pendingAction.type == ActionType.reorganize then
            local casino = Board:casinoContaining(property)
            if casino then
                local hasStake = false
                for _,property in ipairs(casino.properties) do
                    if property.player == self.activePlayer then hasStake = true end
                end
                if hasStake then
                    self.selectedCasino = casino
                    self.pendingAction.casino = casino
                    ConfirmButton.name = "Confirm ($"..casino.reorganizeCost.."M)"
                end
            end
        end
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
    elseif self.pendingAction.type == ActionType.sprawl
    and self.pendingAction.position
    and self.pendingAction.position.casino
    and Board:casinoContaining(self.pendingAction.position).boss == self.activePlayer
    and self.pendingAction.destination
    and self.pendingAction.position.player == self.activePlayer
    and not self.pendingAction.destination.player
    and self.players[self.activePlayer].money >= self.pendingAction.destination.price * 2 then
        return true
    elseif self.pendingAction.type == ActionType.remodel
    and self.pendingAction.casino
    and self.pendingAction.casino.boss == self.activePlayer
    and self.pendingAction.casinoColor
    and self.players[self.activePlayer].money >= self.pendingAction.casino.remodelCost then
        return true
    elseif self.pendingAction.type == ActionType.reorganize
    and self.pendingAction.casino
    and self.players[self.activePlayer].money >= self.pendingAction.casino.reorganizeCost
    and not (self.pendingAction.casino.lastReorgTurn == self.currentTurn) then
        return true
    end

    return false
end

function Game:confirm()
    if self.pendingAction and self.pendingAction.type == ActionType.build then
        self:actionBuild(activePlayer, self.pendingAction.position, self.pendingAction.casinoColor)
    elseif self.pendingAction and self.pendingAction.type == ActionType.sprawl then
        self:actionSprawl(activePlayer, self.pendingAction.position, self.pendingAction.destination)
    elseif self.pendingAction and self.pendingAction.type == ActionType.remodel then
        self:actionRemodel(activePlayer, self.pendingAction.casino, self.pendingAction.casinoColor)
    elseif self.pendingAction and self.pendingAction.type == ActionType.reorganize then
        self:actionReorganize(activePlayer, self.pendingAction.casino)
    end
    --ToDo confirm action
    self.pendingAction = nil
    self.selectedBlock = nil
    self.selectedDestination = nil
    self.selectedCasino = nil
    --ToDo remove selected, render action only
end

function Game:actionTakeOver(playerNumber, card)
    Board.blocks[card.block][card.lot].player = playerNumber
end

function Game:actionBuild(player, property, casinoType)
    local buildMessage = "Build. "..property.name.." "..casinoType.." casino for $"..property.price
    print(buildMessage)
    table.insert(self.eventLog, 1, buildMessage)
    self.players[self.activePlayer].money = self.players[self.activePlayer].money - property.price
    property.casino = casinoType
    self:resolveTies()
end

function Game:actionSprawl(player, source, destination)
    sprawlMessage = "Sprawl. From "..source.name.." to "..destination.name.." for $"..destination.price
    print(sprawlMessage)
    table.insert(self.eventLog, 1, sprawlMessage)
    self.players[self.activePlayer].money = self.players[self.activePlayer].money - destination.price * 2
    destination.player = source.player
    destination.casino = source.casino
    self:resolveTies()
end

function Game:actionRemodel(player, casino, casinoType)
    remodelMessage = "Remodel. Casino containing "..casino.properties[1].name.." to "..casinoType.." for $"..casino.remodelCost
    print(remodelMessage)
    table.insert(self.eventLog, 1, remodelMessage)
    self.players[self.activePlayer].money = self.players[self.activePlayer].money - casino.remodelCost

    for _,property in ipairs(casino.properties) do
        property.casino = casinoType
    end

    self:resolveTies()
end

function Game:actionReorganize(player, casino)
    reorganizeMessage = "Reorganize. Casino containing "..casino.properties[1].name.." for $"..casino.reorganizeCost
    print(reorganizeMessage)
    table.insert(self.eventLog, 1, reorganizeMessage)

    self.players[self.activePlayer].money = self.players[self.activePlayer].money - casino.reorganizeCost

    for _,property in ipairs(casino.properties) do
        property.value = math.random(1, 6)
        property.lastReorgTurn = self.currentTurn
    end

    self:resolveTies()
end

function Game:actionGamble(gamblerPlayerNum, casinoPlayerNum, wager)
    self.gambled = true
end

function Game:resolveTies()
    local casinos = Board:casinos()
    for _,casino in ipairs(casinos) do
        Board:computeBoss(casino)
        if not casino.boss then
            for _,property in ipairs(casino.properties) do --one full reroll
                rerollMessage = "Contested casino. Rerolled "..property.name
                print(rerollMessage)
                table.insert(self.eventLog, 1, rerollMessage)
                property.value = math.random(1, 6)
            end
        end
        Board:computeBoss(casino)
        if not casino.boss then --then only reroll max values
            repeat
                maxProperties = {}
                maxValue = 0
                for _,property in ipairs(casino.properties) do
                    if value >= maxValue then table.insert(maxProperties, property) end
                end

                for _,property in ipairs(maxProperties) do
                    rerollMessage = "Contested casino continues. Rerolled "..property.name
                    print(rerollMessage)
                    table.insert(self.eventLog, 1, rerollMessage)
                    property.value = math.random(1, 6)
                end
                Board:computeBoss(casino)
            until(casino.boss)
        end
    end
end