local Player = require "game.player"
local scene = {}
local TImer = require "util.timer"

function scene:new(monolith, musicSystem, activeControllers)
  return setmetatable(
    {
      musicSystem=musicSystem,
      monolith=monolith,
      activeControllers=activeControllers,

      players={},
      deleteLineNum=0,
    },
    {__index=self}
  )
end

function scene:onDeleteLine(index, deleteNum)
  self.deleteLineNum = self.deleteLineNum + deleteNum
  for _,player in ipairs(self.players) do
    player:speedUp()
  end

  if deleteNum <= 1 then return end

  print("---", index, deleteNum)

  local line = {0,1,2,4}
  for _, player in ipairs(self.players) do
    if index ~= player.index then
      print("---", player.obstacleLine, deleteNum)
      player.obstacleLine = player.obstacleLine + line[deleteNum]
    end
  end
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

  function onDeleteLine(index, deleteNum)
    self:onDeleteLine(index, deleteNum)
  end

  self.players = {}
  for index, isActive in ipairs(self.activeControllers) do
    if isActive then
      table.insert(self.players, Player:new(index, 10, 19, randoms, self.monolith.input, onDeleteLine))
    end
  end

  self.deleteLineNum = 0
end

function scene:update(dt)
  for _, player in ipairs(self.players) do
    player:update(dt)
  end
end

local rotateScreen = require "graphics.rotate_screen":new(128, 128)
local rs = {0,math.pi,math.pi/2*3,math.pi/2}
function scene:draw()
  for _, player in ipairs(self.players) do
    rotateScreen:beginDraw(rs[player.index])
    player:draw()
    rotateScreen:endDraw()
  end
end

return scene
