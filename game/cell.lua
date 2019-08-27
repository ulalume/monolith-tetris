local Cell={}

function Cell:new()
  return setmetatable({item=nil}, {__index=self})
end

function Cell:isEmpty()
  return self.item == nil
end

return Cell
