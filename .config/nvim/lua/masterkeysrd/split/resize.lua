local M = {}

local function resize_vertical(direction)
  local current_width = vim.api.nvim_win_get_width(0)
  vim.cmd("vertical resize " .. direction)
  return current_width ~= vim.api.nvim_win_get_width(0)
end

local function resize_horizontal(direction)
  local current_height = vim.api.nvim_win_get_height(0)
  vim.cmd("resize " .. direction)
  return current_height ~= vim.api.nvim_win_get_height(0)
end

-- resizes the current split to the left
function M.left()
  return resize_vertical("-5")
end

-- resizes the current split to the right
function M.right()
  return resize_vertical("+5")
end

-- resizes the current split to the top
function M.up()
  return resize_horizontal("-5")
end

-- resizes the current split to the bottom
function M.down()
  return resize_horizontal("+5")
end

return M
