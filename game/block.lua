local quads = require "game.util.quads"
local Block = {}

local image = love.graphics.newImage("assets/block.png")
local sprites = quads(image, 3, 3)

function Block:new(color, spriteIndex)
  return setmetatable({color=color, spriteIndex=spriteIndex}, {__index=self})
end

function Block:draw(x, y, gameover)
  love.graphics.setColor(1, 1, 1)
  if gameover then
    love.graphics.draw(image, sprites[8], x, y);
  else
    love.graphics.draw(image, sprites[self.spriteIndex], x, y);
  end
end

return Block
