local M = {}

local directions = {
  h = "L",
  j = "D",
  k = "U",
  l = "R",
}

function M.setup(config)
  -- check if tmux is installed
  if vim.fn.executable("tmux") == 0 then
    return
  end

  -- check if we are in tmux
  if vim.fn.getenv("TMUX") == "" then
    return
  end

  if config then
    if config.on_attach then
      config.on_attach()
    end
  end
end

local function navigate_vim_split(direction)
  local winnr = vim.fn.winnr()
  vim.cmd("wincmd " .. direction)
  return winnr ~= vim.fn.winnr()
end

local function navigate_pane(direction)
  if not navigate_vim_split(direction) then
    vim.fn.system("tmux select-pane -" .. directions[direction])
  end
end

-- Navigate to the specified direction
-- @param direction string: The direction to navigate to
function M.navigate(direction)
  return function()
    navigate_pane(direction)
  end
end

-- Navigate to the left pane
function M.left()
  navigate_pane("h")
end

-- Navigate to the down pane
function M.down()
  navigate_pane("j")
end

-- Navigate to the up pane
function M.up()
  navigate_pane("k")
end

-- Navigate to the right pane
function M.right()
  navigate_pane("l")
end

return M
