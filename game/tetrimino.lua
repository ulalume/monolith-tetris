local table2 = require "util.table2"

local Board = require "game.board"
local Block = require "game.block"

local rotationType = require "game.rotation_type"

local function rotateLeft(board)
    local s = board.w
    local newBoard = Board:new(s, s)
    for x=1, s do
      for y=1, s do
        newBoard:setBlock(y, s + 1 - x, board:getBlock(x, y))
      end
    end
    return newBoard
end

local function rotateRight(board)
  local s = board.w
  local newBoard = Board:new(s, s)
  for x=1, s do
    for y=1, s do
      newBoard:setBlock(s + 1 - y, x, board:getBlock(x, y))
    end
  end
  return newBoard
end

local Tetrimino = {}

function Tetrimino:new(type)
  local s = #type.arrangement

  local board = Board:new(s, s)
  for x=1, s do
    for y=1, s do
      if type.arrangement[x][y] == 1 then
        board:setBlock(x, y, Block:new(type.color, type.spriteIndex))
      end
    end
  end

  local boards = {board}
  for i=2, type.rotationType do
    boards[i] = rotateRight(board)
    board = boards[i]
  end

  return setmetatable({board=boards[1], boards=boards, rotationType=type.rotationType}, {__index = self})
end


function Tetrimino:rotateLeft()
  local i = table2.indexOf(self.boards, self.board)
  i = i - 1
  if i < 1 then i = #self.boards end
  return self.boards[i]
end

function Tetrimino:rotateRight()
  local i = table2.indexOf(self.boards, self.board)
  i = i + 1
  if i > #self.boards then i = 1 end
  return self.boards[i]
end


return Tetrimino
