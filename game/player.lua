
local Board = require "game.board"
local Tetrimino = require "game.tetrimino"
local tetriminoType = require "game.tetrimino_type"

local Timer = require "util.timer"

local RepeatInput = require "game.util.repeat_input"



local quads = require "game.util.quads"

local image = love.graphics.newImage("assets/stock.png")
local sprites = quads(image, 21, 8)

local obstacleBlock = require "game.block":new({0.5,0.5,0.5}, 8)

local Player = {}
function Player:new(index, boardW, boardH, randoms, input, onDeleteLine)
  return setmetatable(
    {
      index=index,

      board=Board:new(boardW, boardH),
      randoms = randoms,
      onDeleteLine=onDeleteLine,

      randomIndex=1,

      x=nil,
      y=nil,
      nextX=nil,
      nextY=nil,

      tetrimino=nil,
      stockTetrimino=nil,
      nextTetrimino=nil,

      obstacleLine=0,

      input=input,
      leftKey=RepeatInput:new(input, index, "left", 0.2),
      rightKey=RepeatInput:new(input, index, "right", 0.2),
      downKey=RepeatInput:new(input, index, "down", 0.05),

      falldownTimer=Timer:new(1.0),

      isDead=false
    },

    {
      __index=self,
    }
  )
end

function Player:speedUp()
  self.leftKey.time = self.leftKey.time*0.99
  self.rightKey.time = self.rightKey.time*0.99
  self.downKey.time = self.downKey.time*0.99
  self.falldownTimer.time = self.falldownTimer.time*0.99
end

function Player:randomRange(min, max)
  local value =  math.floor(min + (max - min) * self.randoms[self.randomIndex] + 0.5)
  self.randomIndex = self.randomIndex + 1
  return value
end

function Player:reset()
  self.board:reset()
  self.x = nil
  self.y = nil
  self.obstacleLine = 0

  self.tetrimino = nil
  self.stockTetrimino = nil

  self.nextTetrimino = nil
  self.nextX = nil
  self.nextY = nil
  self.visibleNext = false

  self.falldownTimer = Time:new(1.0)

  self.isDead = false

  self.leftKey=RepeatInput:new(input, index, "left", 0.2)
  self.rightKey=RepeatInput:new(input, index, "right", 0.2)
  self.downKey=RepeatInput:new(input, index, "down", 0.05)
  self.falldownTimer=Timer:new(1.0)
end

function Player:update(dt)
  if self.isDead then return end

  if self.stockTetrimino == nil then
    self.stockTetrimino = Tetrimino:new(
      tetriminoType[self:randomRange(1, #tetriminoType)]
    )
  end

  if self.nextTetrimino == nil then
    self.nextTetrimino = Tetrimino:new(
      tetriminoType[self:randomRange(1, #tetriminoType)]
    )
    local rotateNum = self:randomRange(0, 3)
    for i=1, rotateNum do
      self.nextTetrimino.board = self.nextTetrimino:rotateRight()
    end
    self.nextX = math.floor((self.board.w - self.nextTetrimino.board.w) / 2) + 1
    self.nextY = self.board.h - self.nextTetrimino.board.h + 1
  end

  if self.tetrimino == nil then

    local deleteNum = 0
    while true do
      local y = self.board:searchFullRow()
      if y ~= nil then
        self.board:deleteRow(y)
        deleteNum = deleteNum + 1
      else break end
    end

    if deleteNum > 0 then
      while self.obstacleLine > 0 and deleteNum > 0 do
        deleteNum = deleteNum - 1
        self.obstacleLine = self.obstacleLine - 1
      end
      if deleteNum > 0 then
        onDeleteLine(self.index, deleteNum)
      end
    end
    while self.obstacleLine > 0 do
      self.obstacleLine = self.obstacleLine - 1
      self.board:insertObstacleRow()
    end

    self.tetrimino = self.nextTetrimino
    self.x = self.nextX
    self.y = self.nextY

    self.nextTetrimino = Tetrimino:new(
      tetriminoType[self:randomRange(1, #tetriminoType)]
    )
    local rotateNum = self:randomRange(0, 3)
    for i=1, rotateNum do
      self.nextTetrimino.board = self.nextTetrimino:rotateRight()
    end
    self.nextX = math.floor((self.board.w - self.nextTetrimino.board.w) / 2) + 1
    self.nextY = self.board.h - self.nextTetrimino.board.h + 1

    self.visibleNext = false

    if self.board:hitTest(self.x, self.y, self.tetrimino.board) then
      self.isDead = true
    end

    return
  else


    if self.leftKey:executable(dt) then
      if not self.board:hitTest(self.x - 1, self.y, self.tetrimino.board) then
        self.x = self.x - 1
      end

    elseif self.rightKey:executable(dt)then
      if not self.board:hitTest(self.x + 1, self.y, self.tetrimino.board) then
        self.x = self.x + 1
      end

    elseif self.downKey:executable(dt)then

      self.falldownTimer:reset()
      if not self.board:hitTest(self.x, self.y - 1, self.tetrimino.board) then
        self.y = self.y - 1
        self.visibleNext = self.y < self.board.h - 5
      else
        self.board:merge(self.x, self.y, self.tetrimino.board)
        self.tetrimino = nil
      end

    elseif self.input:getButtonDown(self.index, "a") then
      local newBoard = self.tetrimino:rotateLeft()
      if not self.board:hitTest(self.x, self.y, newBoard) then
        self.tetrimino.board = newBoard
      end

    elseif self.input:getButtonDown(self.index, "b") then
      local newBoard = self.tetrimino:rotateRight()
      if not self.board:hitTest(self.x, self.y, newBoard) then
        self.tetrimino.board = newBoard
      end
    elseif self.input:getButtonDown(self.index, "up") then
      if not self.board:hitTest(self.x, self.y, self.stockTetrimino.board) then
        self.tetrimino, self.stockTetrimino = self.stockTetrimino, self.tetrimino
      end
    end

    if self.falldownTimer:executable(dt) then
      if self.board:hitTest(self.x, self.y - 1, self.tetrimino.board) then
        self.board:merge(self.x, self.y, self.tetrimino.board)
        self.tetrimino = nil
      else
        self.y = self.y - 1
        self.visibleNext = self.y < self.board.h - 5
      end
    end
  end

end

function Player:draw()
  self.board:draw(1, 1, self.board.w, self.board.h, true, self.isDead, true)

  if self.visibleNext and self.nextTetrimino then
    self.nextTetrimino.board:draw(self.nextX, self.nextY, self.board.w, self.board.h, false, self.isDead)
  end


  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(image, sprites[1], 30-3, 128 - 20-3)
  if self.stockTetrimino then
    self.stockTetrimino.board:draw(-4, 2, self.board.w, self.board.h, false, self.isDead)
  end

  if self.tetrimino then
    self.tetrimino.board:draw(self.x, self.y, self.board.w, self.board.h, false, self.isDead)
  end

  love.graphics.push()
  love.graphics.setColor(0.5, 0.5, 0.5)
  if not self.isDead then
    for i=1, self.obstacleLine do
      obstacleBlock:draw(79, 128 - i*3, self.isDead)
    end
  end
  love.graphics.pop()
end

return Player
