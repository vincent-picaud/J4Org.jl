#+Tag L:target 
# This is an macro example [[target][]]
macro swap(x,y)
   quote
      local tmp = $(esc(x))
      $(esc(x)) = $(esc(y))
      $(esc(y)) = tmp
    end
end
