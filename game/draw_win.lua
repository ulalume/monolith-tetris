local math2 = require "util.math2"
local color = require "graphics.color"
local rainbowBase = require "graphics.rainbow":new(1/30, {color.black, color.black, color.black, color.blue, color.cyan, color.red})
local rainbow = require "graphics.rainbow":new(1/30, {color.white, color.magenta, color.white, color.green, color.white, color.yerrow})

local font = love.graphics.newFont("assets/font/Chack'n-Pop.ttf", 8)

local txt = "I WON"
local fontSize = 8
local xd = -#txt * fontSize / 2

local d = 2
local rxs = xd - d

return function (x, y)

  local yd = math2.round(-fontSize * 2.3 + math.sin(love.timer.getTime()*6)*2)

  local xs = xd
  local ys = yd

  local rys = yd - d
  local rws = fontSize*#txt + d * 2
  local rhs = fontSize + d * 2

  love.graphics.push()

  love.graphics.setColor(rainbowBase:color():rgb())
  love.graphics.rectangle("fill", x + rxs, y + rys, rws, rhs)
  love.graphics.setColor(rainbow:color():rgb())
  love.graphics.rectangle("line", x + rxs-1, y + rys, rws+2, rhs)
  love.graphics.rectangle("line", x + rxs, y + rys - 1, rws, rhs+2)
  love.graphics.rectangle("line", x + rxs, y + rys, rws, rhs)

  love.graphics.setFont(font)
  love.graphics.print(txt, x + xs, y + ys)

  love.graphics.pop()
end
