local RepeatInput = {}

function RepeatInput:new(input, index, key, time)
  return setmetatable({input=input,index=index,key=key,time=time or 0.25,now=0,isDown=false}, {__index=self})
end

function RepeatInput:executable(dt)
  local nowIsDown = self.input:getButton(self.index, self.key)

  if not self.isDown and nowIsDown then
    self.now = 0
    self.isDown = true
    return true
  elseif nowIsDown then
    self.now = self.now + dt
    if self.now > self.time then
      self.now = self.now - self.time
      return true
    end
  else
    self.isDown = false
  end
  return false
end

return RepeatInput
