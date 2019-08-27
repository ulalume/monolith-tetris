package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.lua'
package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?/init.lua'
package.cpath = package.cpath .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.so'

local monolith = require('monolith.core')
  .new({ windowScale = 4.0, ledColorBits = 2 })

local shutdownkey = require "util.shutdownkey":new(monolith.input)
local musicSystem



local game

function getInputSettings()
  if require "util.osname" == "Linux" then
    return require "config.linux_input_settings"
  else
    return require "config.input_settings"
  end
end

function love.load(arg)
  -- active な controller を取得
  -- 全員 active だと {true, true, true, true}
  -- 1P と2P が active だと {true, true, false, false}
  -- デフォルトは全員 active です。
  local activeControllers = require "util.parse_arguments" (arg).activeControllers

  -- コントローラとボタンの設定データを登録します。
  -- くわしくは config/input_settings と config/linux_input_settings を参考
  for i, input in ipairs(getInputSettings()) do monolith.input:setUserSetting(i, input) end

  -- 音楽登録
  local devices, musicPathTable, priorityTable = unpack(require "config.music_data")
  musicSystem = require "music.music_system":new(activeControllers, devices, musicPathTable, priorityTable)

  -- pixel 強調
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  love.graphics.setLineStyle('rough')

  -- game 本体を作成
  game = require "game.scene":new(monolith, musicSystem, activeControllers)
  game:reset()
end

--------------------------------------------------
function love.update(dt)
  musicSystem:update(dt)
  shutdownkey:update(dt)

  -- ここで任意の処理
  game:update(dt)
end

--------------------------------------------------
function love.draw()
  monolith:beginDraw()

  -- ここで任意の描画をしてください
  game:draw()

  monolith:endDraw()
end

--------------------------------------------------
function love.quit()
  musicSystem:gc()
  require "util.open_launcher"()
end
