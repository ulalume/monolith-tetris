local Player = require "game.player"
local scene = {}
local Timer = require "util.timer"

function scene:new(monolith, musicSystem, activeControllers)
  return setmetatable(
    {
      musicSystem=musicSystem,
      monolith=monolith,
      activeControllers=activeControllers,


      endingTimer=Timer:new(5),
      players={},
    },
    {__index=self}
  )
end

local line = {0,1,2,4}
function scene:onDeleteLine(fromIndex, toIndex, deleteNum)
  local toPlayer
  for _, player in ipairs(self.players) do
    player:speedUp()
    if player.index == toIndex then
      toPlayer = player
    end
  end
  if deleteNum <= 1 or toPlayer == nil then return end
  toPlayer:addObstacleLine(fromIndex, line[deleteNum])
end

function scene:reset()
  -- 配置
  --   2P
  -- 4P  3P
  --   1P
  local randoms={}

  for i=1, 4000 do
    randoms[i] = love.math.random()
  end

  function onDeleteLine(fromIndex, toIndex, deleteNum)
    self:onDeleteLine(fromIndex, toIndex, deleteNum)
  end

  self.players = {}
  for index, isActive in ipairs(self.activeControllers) do
    if isActive then
      table.insert(self.players, Player:new(index, 10, 19, randoms, self.monolith.input, onDeleteLine))
    end
  end
end

function scene:update(dt)
  local playerLive = 0
  local livePlayerIndex
  for _, player in ipairs(self.players) do
    player:update(dt)
    if not player.isDead then
      playerLive = playerLive + 1
      livePlayerIndex = player.index
    end
  end

  if playerLive == 1 then
    self.livePlayerIndex = livePlayerIndex
  else
    self.livePlayerIndex = nil
  end

  if playerLive <= 1 then
    if self.endingTimer:executable(dt) then
      love.event.quit()
    end
  end
end

local rotateScreen = require "graphics.rotate_screen":new(128, 128)
local rs = {0, math.pi, math.pi/2*3, math.pi/2}
function scene:draw()
  for _, player in ipairs(self.players) do
    rotateScreen:beginDraw(rs[player.index])
    player:draw()
    rotateScreen:endDraw()
  end
  if self.livePlayerIndex ~= nil then
    for _, player in ipairs(self.players) do
      if self.livePlayerIndex == player.index then
        rotateScreen:beginDraw(rs[player.index])
        require "game.draw_win"(40-16, 128 - 4 * 18)
        rotateScreen:endDraw()
        break
      end
    end
  end
end

return scene
