-- Color scales for gradient effects
local scale = {
    black = { "#010409", "#161b22", "#21262d", "#30363d", "#484f58", "#6e7681", "#8b949e", "#c9d1d9", "#f0f6fc" },
    white = { "#f0f6fc", "#c9d1d9", "#8b949e", "#6e7681", "#484f58", "#30363d", "#21262d", "#161b22", "#010409" },
    gray = { "#fafbfc", "#f6f8fa", "#e1e4e8", "#d1d5da", "#959da5", "#6a737d", "#586069", "#444d56", "#2f363d", "#24292e" },
    blue = { "#cae8ff", "#a5d6ff", "#79c0ff", "#58a6ff", "#388bfd", "#1f6feb", "#1158c7", "#0d419d", "#051d4d" },
    green = { "#aff5b4", "#7ee787", "#56d364", "#3fb950", "#2ea043", "#238636", "#196c2e", "#0f5323", "#033a16" },
    yellow = { "#f8e3a1", "#f2cc60", "#e3b341", "#d29922", "#bb8009", "#9e6a03", "#845306", "#693e00", "#4b2900" },
    orange = { "#ffdfb6", "#ffc680", "#ffa657", "#f0883e", "#db6d28", "#bd561d", "#9b4215", "#762d0a", "#5a1e02" },
    red = { "#ffdcd7", "#ffc1ba", "#ffa198", "#ff7b72", "#f85149", "#da3633", "#b62324", "#8e1519", "#67060c" },
    purple = { "#eddeff", "#d8b9ff", "#c297ff", "#a371f7", "#8957e5", "#6e40c9", "#553098", "#3c1e70", "#271052" },
    pink = { "#ffdaec", "#ffbedd", "#ff9bce", "#f778ba", "#db61a2", "#bf4b8a", "#9e3670", "#7d2457", "#5e103e" },
}


local colors = {
    -- Base colors from GitHub Dark theme
    fg_color = {
        attention = "#9a6700",
        default = scale.gray[2],
        muted = scale.gray[6],
        on_emphasis = "#ffffff",
    },
    accent = {
        fg = "#2f81f7",
        emphasis = "#1f6feb",
        subtle = "#1a2c42", -- Converted from rgba(56, 139, 253, 0.1)
    },
    canvas = {
        default = scale.gray[10],
        overlay = scale.gray[9],
        inset = "#010409",
        subtle = "#1a1f23",
    },
    border = {
        default = "#30363d",
        muted = "#21262d",
        subtle = "#0d1117",
    },
    neutral = {
        emphasis = "#6e7681",
        emphasisPlus = "#6e7681",
        muted = "#4d545d",  -- Converted from rgba(110, 118, 129, 0.4)
        subtle = "#272c32", -- Converted from rgba(110, 118, 129, 0.1)
    },
    severe = {
        fg = "#db6d28",
        emphasis = "#bd561d",
        muted = "#9e542b",  -- Converted from rgba(219, 109, 40, 0.4)
        subtle = "#341a09", -- Converted from rgba(219, 109, 40, 0.1)
    },
    danger = {
        fg = "#f85149",
        emphasis = "#da3633",
        muted = "#c04a45",  -- Converted from rgba(248, 81, 73, 0.4)
        subtle = "#36181b", -- Converted from rgba(248, 81, 73, 0.1)
    },
    done = {
        fg = "#a371f7",
        emphasis = "#8957e5",
        muted = "#8e66cc",  -- Converted from rgba(163, 113, 247, 0.4)
        subtle = "#2c1d40", -- Converted from rgba(163, 113, 247, 0.1)
    },
    sponsors = {
        fg = "#db61a2",
        emphasis = "#bf4b8a",
        muted = "#b35c8c",  -- Converted from rgba(219, 97, 162, 0.4)
        subtle = "#341a2d", -- Converted from rgba(219, 97, 162, 0.1)
    },
    success = {
        fg = "#3fb950",
        emphasis = "#2ea043",
        muted = "#46954a",  -- Converted from rgba(46, 160, 67, 0.4)
        subtle = "#132a1c", -- Converted from rgba(46, 160, 67, 0.1)
    },
    attention = {
        fg = "#d29922",
        emphasis = "#bb8009",
        muted = "#946b20",  -- Converted from rgba(187, 128, 9, 0.4)
        subtle = "#2c2003", -- Converted from rgba(187, 128, 9, 0.15)
    },
    -- ANSI Colors for terminal
    ansi = {
        black = "#484f58",
        red = "#ff7b72",
        green = "#3fb950",
        yellow = "#d29922",
        blue = "#58a6ff",
        magenta = "#bc8cff",
        cyan = "#39c5cf",
        white = "#b1bac4",
        blackBright = "#6e7681",
        redBright = "#ffa198",
        greenBright = "#56d364",
        yellowBright = "#e3b341",
        blueBright = "#79c0ff",
        magentaBright = "#d2a8ff",
        cyanBright = "#56d4dd",
        whiteBright = "#f0f6fc",
    },
}

-- Set up Neovim theme
vim.cmd("highlight clear")
vim.cmd("syntax reset")
vim.cmd("set termguicolors")
vim.o.background = "dark"
vim.g.colors_name = "github-dark"

local set = vim.api.nvim_set_hl

-- UI Elements
set(0, "Normal", { fg = colors.fg_color.default, bg = colors.canvas.default })
set(0, "EndOfBuffer", { fg = colors.border.default, bg = colors.canvas.default })
set(0, "Cursor", { bg = colors.accent.fg })
set(0, "CursorLine", { bg = colors.canvas.overlay })
set(0, "CursorLineNr", { fg = colors.fg_color.default, bold = true })
set(0, "LineNr", { fg = scale.gray[6], bg = colors.canvas.default })
set(0, "Visual", { bg = scale.gray[8] })
set(0, "VisualNOS", { bg = colors.neutral.subtle })
set(0, "NonText", { fg = colors.border.muted })
set(0, "SpecialKey", { fg = colors.border.muted })
set(0, "Directory", { fg = colors.accent.fg })
set(0, "Title", { fg = scale.blue[2], bold = true })
set(0, "Search", { fg = colors.canvas.default, bg = scale.yellow[2] })
set(0, "IncSearch", { fg = colors.canvas.default, bg = scale.yellow[1] })
set(0, "MatchParen", { bg = scale.green[8], fg = scale.green[2] })

-- Status Line
set(0, "StatusLine", { fg = scale.gray[5], bg = colors.canvas.subtle })
set(0, "StatusLineNC", { fg = colors.fg_color.muted, bg = colors.border.muted })
set(0, "WildMenu", { fg = colors.fg_color.default, bg = colors.accent.subtle })
set(0, "VertSplit", { fg = colors.border.default, bg = colors.canvas.default })
set(0, "StatuslineModeNormal", { fg = colors.canvas.subtle, bg = scale.green[3], bold = true })
set(0, "StatuslineModeInsert", { fg = colors.canvas.subtle, bg = scale.orange[3], bold = true })
set(0, "StatuslineModeVisual", { fg = colors.canvas.subtle, bg = scale.yellow[3], bold = true })
set(0, "StatuslineModeCommand", { fg = colors.canvas.subtle, bg = scale.blue[3], bold = true })
set(0, "StatuslineModePending", { fg = colors.canvas.subtle, bg = scale.pink[3], bold = true })
set(0, "StatuslineTitle", { fg = scale.gray[5], bg = colors.canvas.subtle })

-- Tabline
set(0, "TabLine", { fg = colors.fg_color.muted, bg = colors.canvas.subtle })
set(0, "TabLineFill", { fg = colors.fg_color.muted, bg = colors.canvas.subtle })
set(0, "TabLineSel", { fg = colors.fg_color.default, bg = colors.canvas.default })

-- Popup Menu
set(0, "Pmenu", { fg = colors.fg_color.default, bg = colors.canvas.overlay })
set(0, "PmenuSel", { fg = colors.fg_color.default, bg = colors.neutral.muted })
set(0, "PmenuSbar", { bg = colors.neutral.muted })
set(0, "PmenuThumb", { bg = colors.neutral.emphasis })

-- Folds
set(0, "Folded", { fg = colors.fg_color.muted, bg = colors.neutral.subtle })
set(0, "FoldColumn", { fg = colors.fg_color.muted, bg = colors.canvas.default })

-- Signs and Columns
set(0, "SignColumn", { fg = colors.fg_color.default, bg = colors.canvas.default })
set(0, "ColorColumn", { bg = colors.neutral.subtle })

-- Spelling
set(0, "SpellBad", { sp = colors.danger.fg, undercurl = true })
set(0, "SpellCap", { sp = colors.attention.fg, undercurl = true })
set(0, "SpellLocal", { sp = colors.accent.fg, undercurl = true })
set(0, "SpellRare", { sp = colors.done.fg, undercurl = true })

-- Messages
set(0, "ErrorMsg", { fg = colors.danger.fg })
set(0, "WarningMsg", { fg = colors.attention.fg })
set(0, "MoreMsg", { fg = colors.success.fg })
set(0, "Question", { fg = colors.accent.fg })
set(0, "Todo", { fg = colors.attention.fg, bg = colors.attention.subtle, bold = true })

-- Diff
set(0, "DiffAdd", { bg = colors.success.subtle })
set(0, "DiffChange", { bg = colors.attention.subtle })
set(0, "DiffDelete", { bg = colors.danger.subtle, fg = colors.danger.muted })
set(0, "DiffText", { bg = colors.attention.muted })

-- Syntax
set(0, "Comment", { fg = colors.fg_color.muted, italic = true })
set(0, "Constant", { fg = scale.blue[2] })
set(0, "String", { fg = scale.blue[2] })
set(0, "Character", { fg = scale.red[3] })
set(0, "Number", { fg = scale.blue[3] })
set(0, "Boolean", { fg = scale.blue[3] })
set(0, "Float", { fg = scale.blue[3] })

set(0, "Identifier", { fg = scale.orange[2] })
set(0, "Function", { fg = scale.purple[3] })

set(0, "Statement", { fg = scale.red[3] })
set(0, "Conditional", { fg = scale.red[3] })
set(0, "Repeat", { fg = scale.red[3] })
set(0, "Label", { fg = scale.red[3] })
set(0, "Operator", { fg = scale.red[4] })
set(0, "Keyword", { fg = scale.red[4] })
set(0, "Exception", { fg = scale.red[3] })

set(0, "PreProc", { fg = scale.red[3] })
set(0, "Include", { fg = scale.red[3] })
set(0, "Define", { fg = scale.red[3] })
set(0, "Macro", { fg = scale.red[3] })
set(0, "PreCondit", { fg = scale.red[3] })

set(0, "Type", { fg = scale.purple[3] })
set(0, "StorageClass", { fg = scale.red[3] })
set(0, "Structure", { fg = scale.red[3] })
set(0, "Typedef", { fg = scale.red[3] })

set(0, "Special", { fg = scale.orange[3] })
set(0, "SpecialChar", { fg = scale.orange[3] })
set(0, "Tag", { fg = scale.green[1] })
set(0, "Delimiter", { fg = colors.fg_color.default })
set(0, "SpecialComment", { fg = scale.gray[3], italic = true })
set(0, "Debug", { fg = scale.red[3] })
set(0, "Underlined", { underline = true })
set(0, "Ignore", { fg = colors.border.muted })
set(0, "Error", { fg = colors.danger.fg })

-- Treesitter syntax groups
set(0, "@comment", { link = "Comment" })
set(0, "@error", { link = "Error" })
set(0, "@none", { fg = colors.fg_color.default })
set(0, "@preproc", { link = "PreProc" })
set(0, "@define", { link = "Define" })
set(0, "@operator", { link = "Operator" })

-- Literals
set(0, "@string", { link = "String" })
set(0, "@string.special.url", { fg = scale.blue[2] })
set(0, "@character", { link = "Character" })
set(0, "@character.special", { link = "SpecialChar" })
set(0, "@boolean", { link = "Boolean" })
set(0, "@number", { link = "Number" })
set(0, "@float", { link = "Float" })

-- Functions
set(0, "@function", { link = "Function" })
set(0, "@function.call", { link = "Function" })
set(0, "@function.builtin", { fg = scale.blue[2] })
set(0, "@function.macro", { link = "Macro" })
set(0, "@method", { link = "Function" })
set(0, "@method.call", { link = "Function" })
set(0, "@constructor", { fg = scale.purple[2] })
set(0, "@parameter", { fg = scale.orange[3] })

-- Keywords
set(0, "@keyword", { link = "Keyword" })
set(0, "@keyword.function", { link = "Keyword" })
set(0, "@keyword.operator", { link = "Keyword" })
set(0, "@keyword.return", { link = "Keyword" })
set(0, "@conditional", { link = "Conditional" })
set(0, "@repeat", { link = "Repeat" })
set(0, "@debug", { link = "Debug" })
set(0, "@label", { link = "Label" })
set(0, "@include", { link = "Include" })
set(0, "@exception", { link = "Exception" })

-- Types
set(0, "@type", { link = "Type" })
set(0, "@type.builtin", { link = "Keyword" })
set(0, "@type.qualifier", { link = "Type" })
set(0, "@type.definition", { link = "Typedef" })
set(0, "@storageclass", { link = "StorageClass" })
set(0, "@attribute", { fg = scale.blue[2] })
set(0, "@field", { fg = scale.orange[2] })
set(0, "@property", { fg = scale.purple[3] })

-- Identifiers
set(0, "@variable", { fg = colors.fg_color.default })
set(0, "@variable.builtin", { fg = scale.blue[3] })
set(0, "@constant", { link = "Constant" })
set(0, "@constant.builtin", { link = "Constant" })
set(0, "@constant.macro", { link = "Constant" })
set(0, "@namespace", { fg = scale.blue[4] })
set(0, "@symbol", { fg = scale.blue[2] })

-- Text
set(0, "@text", { fg = colors.fg_color.default })
set(0, "@text.strong", { bold = true })
set(0, "@text.emphasis", { italic = true })
set(0, "@text.underline", { underline = true })
set(0, "@text.strike", { strikethrough = true })
set(0, "@text.title", { link = "Title" })
set(0, "@text.literal", { fg = scale.blue[2] })
set(0, "@text.uri", { fg = scale.blue[1], underline = true })
set(0, "@text.math", { fg = scale.blue[2] })
set(0, "@text.reference", { fg = scale.blue[2] })
set(0, "@text.todo", { link = "Todo" })
set(0, "@text.note", { fg = colors.success.fg, bg = colors.success.subtle })
set(0, "@text.warning", { fg = colors.attention.fg, bg = colors.attention.subtle })
set(0, "@text.danger", { fg = colors.danger.fg, bg = colors.danger.subtle })

-- Tags
set(0, "@tag", { link = "Tag" })
set(0, "@tag.attribute", { fg = scale.orange[2] })
set(0, "@tag.delimiter", { fg = colors.fg_color.muted })

-- Punctuation
set(0, "@punctuation.delimiter", { fg = colors.fg_color.default }) -- Generic delimiters
set(0, "@punctuation.bracket", { fg = scale.orange[3] })           -- Generic brackets

-- LSP semantic tokens
set(0, "@lsp.type.namespace", { link = "@namespace" })
set(0, "@lsp.type.type", { link = "@type" })
set(0, "@lsp.type.class", { link = "@type" })
set(0, "@lsp.type.enum", { link = "@type" })
set(0, "@lsp.type.interface", { link = "@type" })
set(0, "@lsp.type.struct", { link = "@type" })
set(0, "@lsp.type.parameter", { link = "@parameter" })
set(0, "@lsp.type.variable", { link = "@variable" })
set(0, "@lsp.type.property", { link = "@property" })
set(0, "@lsp.type.enumMember", { link = "@constant" })
set(0, "@lsp.type.function", { link = "@function" })
set(0, "@lsp.type.method", { link = "@method" })
set(0, "@lsp.type.keyword", { link = "@keyword" })
set(0, "@lsp.type.comment", { link = "@comment" })
set(0, "@lsp.type.string", { link = "@string" })
set(0, "@lsp.type.number", { link = "@number" })
set(0, "@lsp.type.regexp", { link = "@string.regex" })
set(0, "@lsp.type.operator", { link = "@operator" })
set(0, "@lsp.type.decorator", { link = "@attribute" })
set(0, "@lsp.typemod.type.defaultLibrary", { link = "@keyword" })
set(0, "@lsp.typemod.variable.defaultLibrary", { link = "@variable.builtin" })
set(0, "@lsp.typemod.string.format", { fg = scale.blue[4] })

-- Diagnostics
set(0, "DiagnosticError", { fg = colors.danger.fg })
set(0, "DiagnosticWarn", { fg = colors.attention.fg })
set(0, "DiagnosticInfo", { fg = colors.accent.fg })
set(0, "DiagnosticHint", { fg = colors.done.fg })
set(0, "DiagnosticUnderlineError", { sp = colors.danger.fg, undercurl = true })
set(0, "DiagnosticUnderlineWarn", { sp = colors.attention.fg, undercurl = true })
set(0, "DiagnosticUnderlineInfo", { sp = colors.accent.fg, undercurl = true })
set(0, "DiagnosticUnderlineHint", { sp = colors.done.fg, undercurl = true })

-- Git
set(0, "GitSignsAdd", { fg = colors.success.fg })
set(0, "GitSignsChange", { fg = colors.attention.fg })
set(0, "GitSignsDelete", { fg = colors.danger.fg })

-- Markdown
set(0, "markdownH1", { fg = scale.blue[2], bold = true })
set(0, "markdownH2", { fg = scale.blue[2], bold = true })
set(0, "markdownH3", { fg = scale.blue[2], bold = true })
set(0, "markdownH4", { fg = scale.blue[2], bold = true })
set(0, "markdownH5", { fg = scale.blue[2], bold = true })
set(0, "markdownH6", { fg = scale.blue[2], bold = true })
set(0, "markdownCode", { fg = scale.blue[2] })
set(0, "markdownCodeBlock", { fg = scale.blue[2] })
set(0, "markdownBlockquote", { fg = scale.green[1] })
set(0, "markdownListMarker", { fg = scale.orange[2] })
set(0, "markdownOrderedListMarker", { fg = scale.orange[2] })
set(0, "markdownRule", { fg = scale.blue[2] })
set(0, "markdownHeadingRule", { fg = scale.blue[2] })
set(0, "markdownUrlDelimiter", { fg = colors.fg_color.muted })
set(0, "markdownLinkDelimiter", { fg = colors.fg_color.muted })
set(0, "markdownLinkTextDelimiter", { fg = colors.fg_color.muted })
set(0, "markdownHeadingDelimiter", { fg = scale.blue[2] })
set(0, "markdownUrl", { fg = scale.blue[1], underline = true })
set(0, "markdownUrlTitle", { fg = scale.blue[1] })
set(0, "markdownLinkText", { fg = scale.blue[2], underline = true })
set(0, "markdownIdDeclaration", { link = "markdownLinkText" })

-- Plugins: NvimTree
set(0, "NvimTreeNormal", { fg = colors.fg_color.default, bg = colors.canvas.inset })
set(0, "NvimTreeFolderIcon", { fg = colors.fg_color.muted })
set(0, "NvimTreeRootFolder", { fg = colors.fg_color.muted, bold = true })
set(0, "NvimTreeFolderName", { fg = colors.fg_color.default })
set(0, "NvimTreeOpenedFolderName", { fg = colors.fg_color.default, bold = true })
set(0, "NvimTreeEmptyFolderName", { fg = colors.fg_color.muted, italic = true })
set(0, "NvimTreeIndentMarker", { fg = colors.border.muted })
set(0, "NvimTreeGitNew", { fg = colors.success.fg })
set(0, "NvimTreeGitModified", { fg = colors.attention.fg })
set(0, "NvimTreeGitDeleted", { fg = colors.danger.fg })
set(0, "NvimTreeGitIgnored", { fg = colors.fg_color.muted })


-- Completion
set(0, "CmpItemAbbrMatch", { fg = colors.accent.fg, bold = true })
set(0, "CmpItemAbbrMatchFuzzy", { fg = colors.accent.fg })
set(0, "CmpItemKind", { fg = colors.fg_color.muted })
set(0, "CmpItemKindVariable", { fg = scale.orange[2] })
set(0, "CmpItemKindFunction", { fg = scale.purple[2] })
set(0, "CmpItemKindMethod", { fg = scale.purple[2] })
set(0, "CmpItemKindKeyword", { fg = scale.red[3] })
set(0, "CmpItemKindText", { fg = colors.fg_color.default })
set(0, "CmpItemKindConstant", { fg = scale.blue[2] })
set(0, "CmpItemKindConstructor", { fg = scale.purple[2] })
set(0, "CmpItemKindField", { fg = scale.orange[2] })
set(0, "CmpItemKindClass", { fg = scale.orange[2] })
set(0, "CmpItemKindInterface", { fg = scale.orange[2] })
set(0, "CmpItemKindModule", { fg = scale.red[3] })
set(0, "CmpItemKindProperty", { fg = scale.blue[2] })
set(0, "CmpItemKindEnum", { fg = scale.orange[2] })
set(0, "CmpItemKindSnippet", { fg = scale.green[1] })
set(0, "CmpItemKindFile", { fg = scale.blue[2] })
set(0, "CmpItemKindFolder", { fg = scale.blue[2] })

-- Terminal colors
vim.g.terminal_color_0 = colors.ansi.black
vim.g.terminal_color_1 = colors.ansi.red
vim.g.terminal_color_2 = colors.ansi.green
vim.g.terminal_color_3 = colors.ansi.yellow
vim.g.terminal_color_4 = colors.ansi.blue
vim.g.terminal_color_5 = colors.ansi.magenta
vim.g.terminal_color_6 = colors.ansi.cyan
vim.g.terminal_color_7 = colors.ansi.white
vim.g.terminal_color_8 = colors.ansi.blackBright
vim.g.terminal_color_9 = colors.ansi.redBright
vim.g.terminal_color_10 = colors.ansi.greenBright
vim.g.terminal_color_11 = colors.ansi.yellowBright
vim.g.terminal_color_12 = colors.ansi.blueBright
vim.g.terminal_color_13 = colors.ansi.magentaBright
vim.g.terminal_color_14 = colors.ansi.cyanBright
vim.g.terminal_color_15 = colors.ansi.whiteBright

return colors
