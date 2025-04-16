vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.BufferLine()"

function _G.BufferLine()
  local s = "" local current = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "buflisted") then
      local buf_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
      if buf_name == "" then buf_name = "[No Name]" end

      if buf == current then
        s = s .. "%#TabLineSel#"
      else
        s = s .. "%#TabLine#"
      end

      -- Buffer click target
      s = s .. "%" .. buf .. "@v:lua.SwitchToBuffer@ " .. buf_name .. " "
    end
  end

  s = s .. "%#TabLineFill#"
  return s
end

function _G.SwitchToBuffer(bufnr, _)
  vim.api.nvim_set_current_buf(bufnr)
end
