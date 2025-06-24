vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.BufferLine()"

local label = "File Explorer"
local tree_filetype = "NvimTree"
local bufferline_hls = {}

---Get or create a hightlight group.
---@param name string
---@param sel boolean
---@return string
local function get_or_create_hl(name, sel)
    local base_hl = sel and "TabLineSel" or "TabLine"
    local hl_name = base_hl .. name

    if not bufferline_hls[hl_name] then
        local fg_hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        local bg_hl = vim.api.nvim_get_hl(0, { name = base_hl, link = false })
        vim.api.nvim_set_hl(0, hl_name, { bg = bg_hl.bg, fg = fg_hl.fg })
        bufferline_hls[hl_name] = true
    end

    return hl_name
end

--- Get the higher diagnostic text.
---@param bufnr integer
---@param sel boolean
---@return string
local function get_higher_diagnostic_hl(bufnr, sel)
    -- Get all diagnostics for the current buffer
    local diagnostics = vim.diagnostic.get(bufnr)

    -- If no diagnostics, return empty
    if #diagnostics == 0 then
        return ""
    end

    -- Find the highest severity diagnostic
    local highest_severity = nil

    for _, diagnostic in ipairs(diagnostics) do
        if not highest_severity or diagnostic.severity < highest_severity then
            highest_severity = diagnostic.severity
        end
    end

    -- Convert severity number to text
    local severity_text = ""
    if highest_severity == vim.diagnostic.severity.ERROR then
        severity_text = "Error"
    elseif highest_severity == vim.diagnostic.severity.WARN then
        severity_text = "Warn"
    elseif highest_severity == vim.diagnostic.severity.INFO then
        severity_text = "Info"
    elseif highest_severity == vim.diagnostic.severity.HINT then
        severity_text = "Hint"
    end

    if severity_text == "" then
        return ""
    end

    return get_or_create_hl("Diagnostic" .. severity_text, sel)
end

---Function to check if nvim-tree is open
---@param filetype string
---@return boolean
local function is_tree_open(filetype)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_filetype = vim.bo[buf].filetype
        if filetype == buf_filetype then
            return true
        end
    end
    return false
end

---Function to get nvim-tree width when open
---@param filetype string
---@return integer
local function get_tree_width(filetype)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_filetype = vim.bo[buf].filetype
        if filetype == buf_filetype then
            return vim.api.nvim_win_get_width(win)
        end
    end
    return 0
end

function _G.BufferLine()
    local devicons = require("nvim-web-devicons")
    local s = ""
    local current = vim.api.nvim_get_current_buf()
    local count = 0

    if is_tree_open(tree_filetype) then
        s = s .. string.format("%%#%sHeader#%s", tree_filetype, label)
        s = s .. string.rep(" ", get_tree_width(tree_filetype) - string.len(label))
        s = s .. string.format("%%#%sWinSeparator#│", tree_filetype)
    end

    -- Create a table to store dynamic highlight groups
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            local name, ext = vim.fn.fnamemodify(buf_name, ":t"), vim.fn.fnamemodify(buf_name, ':e')
            count = count + 1

            if name == "" then
                name = "[No Name]"
            end

            local filetype = vim.bo[buf].filetype
            if filetype == '' then
                filetype = '[No Name]'
            end

            local tab_hl = buf == current and "TabLineSel" or "TabLine"
            local hl_group = "%#" .. tab_hl .. "#"

            local icon, icon_hl = devicons.get_icon(name, ext)
            if not icon then
                icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
            end
            icon_hl = get_or_create_hl(icon_hl, buf == current)
            local icon_str = icon and (icon_hl and string.format("%%#%s#%s%%*", icon_hl, icon) or icon) or ""


            local modified = vim.bo[buf].modified and " [+]" or ""

            local diagnostic_hl = get_higher_diagnostic_hl(buf, buf == current)
            if diagnostic_hl ~= "" then
                name = string.format("%%#%s#%s", diagnostic_hl, name)
            end

            -- Buffer click target
            s = s ..
                string.format("%s%%%d@v:lua.SwitchToBuffer@ %d. %s%s %s%s │", hl_group, buf, count, icon_str, hl_group,
                    name,
                    modified)
        end
    end

    s = s .. "%#TabLineFill#"
    return s
end

function _G.SwitchToBuffer(bufnr, _)
    vim.api.nvim_set_current_buf(bufnr)
end
