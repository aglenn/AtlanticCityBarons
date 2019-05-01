function takeOver(playerNum, position)
    Board.blocks[position.block][position.number].player = playerNum
end

function build(playerNum, position, casinoType)
    --TODO: Check player money
    -- Board.blocks[position.block][position.number].player = playerNum
    Board.blocks[position.block][position.number].casino = casinoType
end

function sprawl(playerNum, source, destination)

end

function remodel(playerNum, casinoMemberPosition)

end

function reorganize(playerNum, casinoMemberPosition)

end

function gamble(gamblerPlayerNum, casinoPlayerNum, wager)

end