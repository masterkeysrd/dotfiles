local split_resize = require("masterkeysrd.split.resize")

local M = {}

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

function M.left()
  if split_resize.left() then
    return
  end

  vim.fn.system("tmux resize-pane -L 5")
end

function M.down()
  if split_resize.down() then
    return
  end

  vim.fn.system("tmux resize-pane -D 5")
end

function M.up()
  if split_resize.up() then
    return
  end

  vim.fn.system("tmux resize-pane -U 5")
end

function M.right()
  if split_resize.right() then
    return
  end

  vim.fn.system("tmux resize-pane -R 5")
end

return M
