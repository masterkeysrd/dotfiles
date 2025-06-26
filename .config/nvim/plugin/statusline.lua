local icons = require('masterkeysrd.icons')

-- Don't show the command that produced the quickfix list.
vim.g.qf_disable_statusline = 1

-- Show the mode in my custom component instead.
vim.o.showmode = false

--- Keeps track of the highlight groups I've already created.
---@type table<string, boolean>
local statusline_hls = {}

---@param hl string
---@return string
local function get_or_create_hl(hl)
    local hl_name = 'Statusline' .. hl

    if not statusline_hls[hl] then
        -- If not in the cache, create the highlight group using the icon's foreground color
        -- and the statusline's background color.
        local bg_hl = vim.api.nvim_get_hl(0, { name = 'StatusLine' })
        local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
        vim.api.nvim_set_hl(0, hl_name, { bg = ('#%06x'):format(bg_hl.bg), fg = ('#%06x'):format(fg_hl.fg) })
        statusline_hls[hl] = true
    end

    return hl_name
end

--- Get or create a hl group for separators.
---@param hl string
local function get_or_create_sep_hl(hl)
    local hl_name = hl .. "Sep"
    if hl:find("^StatusLine") == nil then
        hl_name = "StatusLine" .. hl_name
    end


    if not statusline_hls[hl_name] then
        -- If not in the cache, create the highlight group using the icon's foreground color
        -- and the statusline's background color.
        local base_hl = vim.api.nvim_get_hl(0, { name = hl })
        if not base_hl or not base_hl.fg then
            return hl_name
        end

        vim.api.nvim_set_hl(0, hl_name, { bg = ('#%06x'):format(base_hl.fg), fg = ('#%06x'):format(base_hl.bg) })
        statusline_hls[hl_name] = true
    end

    return hl_name
end

-- Get the higher diagnostic text.
local function get_higher_diagnostic_text()
    -- Get all diagnostics for the current buffer
    local diagnostics = vim.diagnostic.get(0)

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

    return severity_text
end

--- Get current path formatted.
---@return string
local function get_cwd_formatted()
    local cwd = vim.fn.getcwd()
    local home = os.getenv("HOME") or ""

    local dir = cwd:gsub(home, "~")
    return string.format(dir)
end

--- Current mode.
---@param sep string
---@return string
local function mode_component(sep)
    -- Note that: \19 = ^S and \22 = ^V.
    local mode_to_str = {
        ['n'] = 'NORMAL',
        ['no'] = 'OP-PENDING',
        ['nov'] = 'OP-PENDING',
        ['noV'] = 'OP-PENDING',
        ['no\22'] = 'OP-PENDING',
        ['niI'] = 'NORMAL',
        ['niR'] = 'NORMAL',
        ['niV'] = 'NORMAL',
        ['nt'] = 'NORMAL',
        ['ntT'] = 'NORMAL',
        ['v'] = 'VISUAL',
        ['vs'] = 'VISUAL',
        ['V'] = 'VISUAL',
        ['Vs'] = 'VISUAL',
        ['\22'] = 'VISUAL',
        ['\22s'] = 'VISUAL',
        ['s'] = 'SELECT',
        ['S'] = 'SELECT',
        ['\19'] = 'SELECT',
        ['i'] = 'INSERT',
        ['ic'] = 'INSERT',
        ['ix'] = 'INSERT',
        ['R'] = 'REPLACE',
        ['Rc'] = 'REPLACE',
        ['Rx'] = 'REPLACE',
        ['Rv'] = 'VIRT REPLACE',
        ['Rvc'] = 'VIRT REPLACE',
        ['Rvx'] = 'VIRT REPLACE',
        ['c'] = 'COMMAND',
        ['cv'] = 'VIM EX',
        ['ce'] = 'EX',
        ['r'] = 'PROMPT',
        ['rm'] = 'MORE',
        ['r?'] = 'CONFIRM',
        ['!'] = 'SHELL',
        ['t'] = 'TERMINAL',
    }

    -- Get the respective string to display.
    local mode = mode_to_str[vim.api.nvim_get_mode().mode] or 'UNKNOWN'

    -- Set the highlight group.
    local hl = ''
    if mode:find 'NORMAL' then
        hl = 'Normal'
    elseif mode:find 'PENDING' then
        hl = 'Pending'
    elseif mode:find 'VISUAL' then
        hl = 'Visual'
    elseif mode:find 'INSERT' or mode:find 'SELECT' then
        hl = 'Insert'
    elseif mode:find 'COMMAND' or mode:find 'TERMINAL' or mode:find 'EX' then
        hl = 'Command'
    end

    local mode_hl = "StatuslineMode" .. hl
    local sep_hl = get_or_create_sep_hl(mode_hl)
    return string.format('%%#%s# %s %%#%s#%s', mode_hl, mode, sep_hl, sep)
end

--- Git status (if any).
---@return string
local function git_component()
    local head = vim.b.gitsigns_head
    if not head or head == '' then
        return ''
    end

    local component = icons.misc.git .. " " .. head
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        for _, key in ipairs({ "added", "changed", "removed" }) do
            local sign = gitsigns[key]
            if sign and sign > 0 then
                component = component .. string.format(" %s%d", icons.git_symbol[key], sign)
            end
        end
    end

    return " " .. component
end

--- The current debugging status (if any).
---@return string?
local function dap_component()
    if not package.loaded['dap'] or require('dap').status() == '' then
        return nil
    end

    return string.format('%%#%s#%s  %s', get_or_create_hl('Special'), icons.misc.bug, require('dap').status())
end

---@type table<string, string?>
local progress_status = {
    client = nil,
    kind = nil,
    title = nil,
}

vim.api.nvim_create_autocmd('LspProgress', {
    group = vim.api.nvim_create_augroup('masterkeysrd/statusline', { clear = true }),
    desc = 'Update LSP progress in statusline',
    pattern = { 'begin', 'end' },
    callback = function(args)
        -- This should in theory never happen, but I've seen weird errors.
        if not args.data then
            return
        end

        progress_status = {
            client = vim.lsp.get_client_by_id(args.data.client_id).name,
            kind = args.data.params.value.kind,
            title = args.data.params.value.title,
        }

        if progress_status.kind == 'end' then
            progress_status.title = nil
            -- Wait a bit before clearing the status.
            vim.defer_fn(function()
                vim.cmd.redrawstatus()
            end, 3000)
        else
            vim.cmd.redrawstatus()
        end
    end,
})
--- The latest LSP progress message.
---@return string
local function lsp_progress_component()
    if not progress_status.client or not progress_status.title then
        return ''
    end

    -- Avoid noisy messages while typing.
    if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
        return ''
    end

    return table.concat {
        '%#StatuslineSpinner#󱥸 ',
        string.format('%%#StatuslineTitle#%s  ', progress_status.client),
        string.format('%%#StatuslineItalic#%s...', progress_status.title),
    }
end

local last_diagnostic_component = ''
--- Diagnostic counts in the current buffer.
---@return string
local function diagnostics_component()
    -- Use the last computed value if in insert mode.
    if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
        return last_diagnostic_component
    end

    local counts = vim.iter(vim.diagnostic.get(0)):fold({
        ERROR = 0,
        WARN = 0,
        HINT = 0,
        INFO = 0,
    }, function(acc, diagnostic)
        local severity = vim.diagnostic.severity[diagnostic.severity]
        acc[severity] = acc[severity] + 1
        return acc
    end)

    local parts = vim.iter(counts)
        :map(function(severity, count)
            if count == 0 then
                return nil
            end

            local hl = 'Diagnostic' .. severity:sub(1, 1) .. severity:sub(2):lower()
            return string.format('%%#%s#%s %d', get_or_create_hl(hl), icons.diagnostics[severity], count)
        end)
        :totable()

    if #parts == 0 then
        return ""
    end

    return "%#StatuslineTitle# " .. table.concat(parts, ' ')
end

--- The buffer's filetype.
---@return string
local function filetype_component()
    local devicons = require('nvim-web-devicons')
    local filetype = vim.bo.filetype
    if filetype ~= '' then
        filetype = string.gsub(filetype, "^%l", string.upper)
    else
        filetype = '[No Name]'
    end

    local buf_name = vim.api.nvim_buf_get_name(0)
    local name, ext = vim.fn.fnamemodify(buf_name, ':t'), vim.fn.fnamemodify(buf_name, ':e')

    local icon, icon_hl = devicons.get_icon(name, ext)
    if not icon then
        icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
    end
    icon_hl = get_or_create_hl(icon_hl)
    --
    return string.format('%%#%s#%s %%#StatuslineTitle#%s', icon_hl, icon, filetype)
end

--- Spaces for the current buffer.
---@return string
local function spaces_component()
    ---@diagnostic disable-next-line: undefined-field
    local spaces = vim.opt.shiftwidth:get()
    return spaces ~= '' and string.format('%%#StatuslineModeSeparatorOther#Spaces: %s    ', spaces) or ''
end

local last_filename_component = ""

--- Get the filename of the current buffer without the path (just the basename).
---@return string
local function filename_component()
    -- Use the last computed value if in insert mode.
    if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
        return last_filename_component
    end


    local severity = get_higher_diagnostic_text()
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")

    local hl = "StatuslineTitle"
    if severity ~= "" then
        hl = "Diagnostic" .. severity
    end

    last_filename_component = string.format('%%#%s# %s ', hl, filename)
    return last_filename_component
end

--- File-content encoding for the current buffer.
---@return string
local function encoding_component()
    local encoding = vim.opt.fileencoding:get()
    return encoding ~= '' and string.format('%%#StatuslineModeSeparatorOther# %s    ', string.upper(encoding)) or ''
end

--- The current line, total line count, and column position.
---@return string
local function position_component()
    local line = vim.fn.line '.'
    local line_count = vim.api.nvim_buf_line_count(0)
    local col = vim.fn.virtcol '.'

    return table.concat {
        '%#StatuslineItalic#Ln: ',
        string.format('%%#StatuslineTitle#%d', line),
        string.format('%%#StatuslineItalic#/%d Col: %d   ', line_count, col),
    }
end

--- Modifies the status line when is in nvim-tree buffer
---@param sep string
---@return string
local function nvim_tree_extension(sep)
    if vim.bo.filetype ~= "NvimTree" then
        return ""
    end

    local cwd = get_cwd_formatted()
    local cwd_sep_hl = get_or_create_sep_hl("StatusLineNvimTree")
    local icon_sep_hl = get_or_create_sep_hl("StatusLineNvimTreeIcon")

    local icon_part = string.format("%%#StatusLineNvimTreeIcon# 👻 %%#%s#%s%%*", icon_sep_hl, sep)
    local cwd_part =
        string.format("%%#StatusLineNvimTree# %s %%#%s#%s ", cwd, cwd_sep_hl, sep)
    return icon_part .. cwd_part
end

local extensions = {
    nvim_tree_extension
}

--- Renders the statusline.
---@return string
function _G.StatusLine()
    for _, extension in ipairs(extensions) do
        local text = extension(icons.separator.left)
        if text ~= "" then
            return text .. "%#StatusLine#%="
        end
    end

    ---@param components string[]
    ---@return string
    local function concat_components(components)
        return vim.iter(components):skip(1):fold(components[1], function(acc, component)
            return #component > 0 and string.format('%s%s', acc, component) or acc
        end)
    end

    return table.concat {
        concat_components({
            mode_component(icons.separator.left),
            git_component(),
            diagnostics_component(),
            dap_component() or lsp_progress_component(),
            filename_component(),
        }),
        '%#StatusLine#%=',
        concat_components {
            position_component(),
            spaces_component(),
            encoding_component(),
            filetype_component(),
        },
        ' ',
    }
end

vim.o.statusline = "%!v:lua.StatusLine()"
