
require("actions")

GameState = {
    initial="initial",
    setup="setup",
    payout="payout",
    score="score",
    turn="turn",
    gameover="gameover"
}

Game = {state=GameState.initial}

function Game:init(numberOfPlayers, board)
    self.playerCount = numberOfPlayers
    for i=1,number_of_players do
        self.players[i] = {money = 0, scorePosition=0}
    end
    self.activePlayer=1
    self.state = GameState.initial

    --ToDo set up buttons

    self:setup()
end

function Game:render()
    --ToDo render buttons, activate + confirm, player money, active player
end

function Game:setup()
    -- deal starting cards to players
    -- assign money and properties
    -- insert end card
end

function Game:turnStart()
    self.state = GameState.payout
    lastCard = Deck:draw()

    casinos = Board:casinos(lastCard.color)
    for _,casino in ipairs(casions) do
        self:score(casino.boss, casino.size)
        for _,property in ipairs(casino.properties) do
            self:pay(property.player, property.value)
        end
    end
    --ToDo check the card and trigger endgame
    self.state = GameState.turn
end

function Game:pay(player, amount)
    --ToDo pay them
end


function Game:score(player, amount)
    --ToDo score them if they can
    --ToDo change score data source to players
end

function Game:endTurn()
    self.activePlayer = (self.activePlayer + 1) % self.numberOfPlayers
    self:turnStart()
end