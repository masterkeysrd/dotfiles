local config = {
    components = {
        {
            text = "%s", -- Signs
        },
        {
            text = "%l", -- Line Numbers
        },
        {
            text = "%{%v:lua.StatusColumnFolding()%} " -- Custom Folding Indicator
        },
    },
    ft_ignore = {
        "NvimTree"
    },
}

local format_str = ""

--- Returns the folding indicator only for open folding lines.
---@return string
function _G.StatusColumnFolding()
    -- Skip virtual lines (e.g. wrapped lines)
    if vim.v.virtnum ~= 0 then
        return ""
    end

    local lnum = vim.v.lnum
    local fold_level = vim.fn.foldlevel(lnum)
    if fold_level < 1 then
        return " "
    end

    -- Skip folding that are not news, that just places folding when
    -- a new identation will start.
    local prev_fold_level = vim.fn.foldlevel(lnum - 1)
    if fold_level <= prev_fold_level then
        return " "
    end

    return "%C"
end

function _G.StatusColumn()
    return format_str
end

local function format_component(component)
    return component.text
end

format_str = table.concat(
    vim.tbl_map(format_component, config.components),
    " "
)


-- Set statusclumn
local statusline_text = "%{%v:lua.StatusColumn()%}"

-- Aply statusclumn to allowed windws
vim.api.nvim_set_option_value("statuscolumn", statusline_text, { scope = "global" })
for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if not vim.api.nvim_buf_get_name(buf):find("vim._extui") and
            not vim.tbl_contains(config.ft_ignore, vim.bo[buf].filetype) then
            vim.api.nvim_set_option_value("statuscolumn", statusline_text, { win = win })
        end
    end
end

-- Set up autocommands for filetype handling
local id = vim.api.nvim_create_augroup("statuscolumn", {})

if config.ft_ignore then
    -- Clear statuscolumn for ignored filetypes
    vim.api.nvim_create_autocmd("FileType", {
        group = id,
        pattern = config.ft_ignore,
        command = "setlocal stc="
    })

    -- Handle buffer window enter
    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = id,
        callback = function()
            if vim.tbl_contains(config.ft_ignore, vim.bo.filetype) then
                vim.api.nvim_set_option_value("stc", "", { scope = "local" })
            end
        end,
    })
end
