
local rotationType = require "game.rotation_type"
local color = require "graphics.color"

local function pack(r,g,b)
  return {r,g,b}
end

return {
  {
    spriteIndex = 1,
    color=pack(color.red:rgb()),
    rotationType=rotationType.r0,
    arrangement = {
      {1,1},
      {1,1}
    }
  },
  {
    spriteIndex = 2,
    color=pack(color.cyan:rgb()),
    rotationType=rotationType.r4,
    arrangement = {
      {0,1,0},
      {0,1,0},
      {0,1,1}
    }
  },
  {
    spriteIndex = 3,
    color=pack(color.yellow:rgb()),
    rotationType=rotationType.r4,
    arrangement = {
      {0,1,0},
      {0,1,0},
      {1,1,0}
    }
  },
  {
    spriteIndex = 4,
    color=pack(color.blue:rgb()),
    rotationType=rotationType.r2,
    arrangement = {
      {1,0,0},
      {1,1,0},
      {0,1,0}
    }
  },
  {
    spriteIndex = 5,
    color=pack(color.magenta:rgb()),
    rotationType=rotationType.r2,
    arrangement = {
      {0,1,0},
      {1,1,0},
      {1,0,0}
    }
  },
  {
    spriteIndex = 6,
    color=pack(color.green:rgb()),
    rotationType=rotationType.r4,
    arrangement = {
      {0,1,0},
      {1,1,1},
      {0,0,0}
    }
  },
  {
    spriteIndex = 7,
    color=pack(color.white:rgb()),
    rotationType=rotationType.r2,
    arrangement = {
      {0,0,1,0},
      {0,0,1,0},
      {0,0,1,0},
      {0,0,1,0}
    }
  }
}
