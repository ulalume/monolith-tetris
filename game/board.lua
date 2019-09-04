local Cell = require "game.cell"
local Block = require "game.block"

local Board={}
function Board:new(w, h)
  local t = setmetatable({w=w, h=h}, {__index=self})
  t:reset()
  return t
end

function Board:reset()
  local data = {}
  for y=1, self.h do
    data[y]={}
    for x=1, self.w do
      data[y][x] = Cell:new()
    end
  end
  self.data=data
  for i=1,100 do
    self:deleteRow(1)
  end
end

function Board:getBlock(x, y)
  if not self:inArea(x, y) then return Block:new({1,1,1}, 9) end


    --print("getBlock", x, y)
  if self:isEmpty(x, y) then return nil end
  return self.data[y][x].item
end

function Board:setBlock(x, y, block)
  if not self:inArea(x, y) then return end

  self.data[y][x].item = block
end

function Board:inArea(x, y)
  return (x < 1 or y < 1 or x > self.w or y > self.h) == false
end

function Board:isEmpty(x, y)
  --print("isEmpty", x, y)
  if not self:inArea(x, y) then return false end
  return self.data[y][x]:isEmpty()
end


function Board:deleteRow(deleteY)
  for i=deleteY, self.h - 1 do
    self.data[i] = self.data[i + 1]
  end
  self.data[self.h] = {}
  for x=1, self.w do
    self.data[self.h][x] = Cell:new()
  end
end

function Board:merge(x, y, board)
  for x2=1, board.w do
    for y2=1, board.h do
      local block = board:getBlock(x2, y2)
      if block ~= nil then
        self:setBlock(x + x2 - 1, y + y2 - 1, block)
      end
    end
  end
end

function Board:hasEmptyCellInRow(y)
  for x=1, self.w do
    --print("hasEmptyCellInRow", x, y)
    if self:isEmpty(x, y) then
      return true
    end
  end
  return false
end

function Board:insertObstacleRow()
  for i=self.h, 2, -1 do
    self.data[i] = self.data[i-1]
  end
  self.data[1] = {}
  local empty = love.math.random(1, self.w)
  for x=1, self.w do
    self.data[1][x] = Cell:new()
    if empty ~= x then
      self.data[1][x].item = Block:new({0.5,0.5,0.5}, 8)
    end
  end
end
function Board:searchFullRow()
  for y=1, self.h do
    if not  self:hasEmptyCellInRow(y) then
      return y
    end
  end
  return nil
end

function Board:hitTest(x, y, board)
  for x2=1, board.w do
    for y2=1, board.h do
      --print("hitTest", x, y, x2, y2)
      if not board:isEmpty(x2, y2) and not self:isEmpty(x + x2 - 1, y + y2 - 1) then
        return true
      end
    end
  end
  return false
end

function Board:draw(x, y, boardW, boardH, emptyColor, gameover, screenPositionX, screenPositionY)
  screenPositionX = screenPositionX or 0
  screenPositionY = screenPositionY or 0
  if needEmpty == nil then needEmpty = false end

  local h = self.h

  local cellSize = 4
  local pixelFirstX = (x - 1) * cellSize + screenPositionX--+ (128 - boardW * cellSize) / 2
  local pixelFirstY = (boardH - 1) * cellSize - (y - 1) * cellSize + 128 - boardH * cellSize + screenPositionY

  local pixels = {}
  for x2=1, self.w do
    pixels[x2] = {}
    for y2=1, self.h do
      pixels[x2][y2] = {
        pixelFirstX + (x2-1) * cellSize,
        pixelFirstY - (y2-1) * cellSize
      }
    end
  end

  love.graphics.push()
  if emptyColor ~= nil then
    for x2=1, self.w do
      for y2=1, h do
        love.graphics.setColor(unpack(emptyColor))
        love.graphics.rectangle("fill", pixels[x2][y2][1] + 1, pixels[x2][y2][2] + 1, 1, 1)
      end
    end
  end
  love.graphics.pop()

  love.graphics.push()
  for x2=1, self.w do
    for y2=1, self.h do
      local block = self:getBlock(x2, y2)
      if block ~= nil then
        block:draw(pixels[x2][y2][1], pixels[x2][y2][2], gameover)
      end
    end
  end
  love.graphics.pop()
end

return Board
