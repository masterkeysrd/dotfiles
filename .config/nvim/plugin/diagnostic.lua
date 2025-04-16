vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
	virtual_lines = {
		enable = true,
		current_line = true
	},
	float = {
		border = "double",
	},
	jump = {
		float = true,
		wrap = false
	},
})
