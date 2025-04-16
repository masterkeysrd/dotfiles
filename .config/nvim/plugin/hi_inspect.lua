local function get_highlight_chain()
	local line = vim.fn.line('.')
	local col = vim.fn.col('.')

	local syn_id = vim.fn.synID(line, col, 1)
	local chain = {}

	-- Get initial group name
	local current = vim.fn.synIDattr(syn_id, "name")
	table.insert(chain, current)

	-- Follow the highlight links using hlID (via synIDtrans is not enough for nested links)
	while current and current ~= "" do
		local hl_id = vim.fn.hlID(current)
		local next_name = vim.fn.synIDattr(vim.fn.synIDtrans(hl_id), "name")

		if not next_name or next_name == "" or next_name == current then
			break
		end

		table.insert(chain, next_name)
		current = next_name
	end

	return chain
end

local function get_semantic_token_under_cursor()
	local bufnr = vim.api.nvim_get_current_buf()
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local tokens = vim.lsp.semantic_tokens.get_at_pos(bufnr, { line = lnum, character = col })
	if not tokens or #tokens == 0 then
		print("No semantic token found under cursor")
		return
	end

	local chain = {}
	for _, token in ipairs(tokens) do
		table.insert(chain,
			token.type .. (token.modifiers and (" [" .. table.concat(token.modifiers, ", ") .. "]") or ""))
	end

	-- Display nicely with arrows between groups
	local msg = "Highlight chain: " .. table.concat(chain, " → ")
	-- vim.api.nvim_echo({ { msg, "Normal" } }, false, {})
	return msg
end

local function get_lsp_semantic_token_hl()
  local params = vim.lsp.util.make_position_params()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })

  local msg = ""
  for _, client in ipairs(clients) do
    if client.server_capabilities.semanticTokensProvider then
      local tokens = vim.lsp.semantic_tokens.get_at_pos(0, params.position)
      if tokens and #tokens > 0 then
        for _, token in ipairs(tokens) do
          local hl_group = "@lsp.type." .. token.type
          if token.modifiers and #token.modifiers > 0 then
            hl_group = hl_group .. " [" .. table.concat(token.modifiers, ", ") .. "]"
          end
	  msg = msg .. " " .. hl_group
        end
        return "LSP HL " .. msg
      end
    end
  end
  print("No LSP semantic token under cursor")
end

local function inspect()
	local lsp_hl = get_lsp_semantic_token_hl() or ""
	local token = get_semantic_token_under_cursor() or ""
	local chain = get_highlight_chain()

	if #chain == 0 then
	  vim.api.nvim_echo({ { "No highlight group under cursor", "WarningMsg" } }, false, {})
	  return
	end

	-- Display nicely with arrows between groups
	local msg = "Highlight chain: " .. table.concat(chain, " → ") .. " | " .. token .. " | " .. lsp_hl
	vim.api.nvim_echo({ { msg, "Normal" } }, false, {})
end

local group = vim.api.nvim_create_augroup("inspector", { clear = true })

vim.api.nvim_create_autocmd("CursorMoved", {
	group = group,
	callback = function()
		inspect()
	end,
})
