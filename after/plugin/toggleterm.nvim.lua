require("toggleterm").setup{
  size = function(term)
  if term.direction == "float" then
    return 15
  elseif term.direction == "vertical" then
    return 50 
    end
  end,
  open_mapping = [[<c-\>]],
  direction = 'vertical',
}

