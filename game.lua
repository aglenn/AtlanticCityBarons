Game = {}

GameState = {
    initial="initial",
    setup="setup",
    flip="flip",
    payout="payout",
    score="score",
    turn="turn",
    resolution="resolution",
    gameover="gameover"
}

function Game:init(number_of_players, board)
    for i=1,number_of_players do
        self.players[i] = {
            money=4 + (i-1)
        }
    end
end

function Game:render()


end