local setRandomTheme = function()
  local keys = {}
  for key, _ in pairs(themes) do
    table.insert(keys, key)
  end
  local randomTheme = keys[math.random(1, #keys)]
  themes[randomTheme]()
end
