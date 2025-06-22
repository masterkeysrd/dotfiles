local M = {}

--- Diagnostic severities.
M.diagnostics = {
    ERROR = '',
    WARN = '',
    HINT = '',
    INFO = '',
}

---- For folding.
M.arrows = {
    right = '',
    left = '',
    up = '',
    down = '',
}

--- Shared icons that don't really fit into a category.
M.misc = {
    bug = '',
    dashed_bar = '┊',
    ellipsis = '…',
    git = '',
    palette = '󰏘',
    robot = '󰚩',
    search = '',
    terminal = '',
    toolbox = '󰦬',
    vertical_bar = '│',
}

M.symbol_kinds = {
    '', --- [1] Text
    '', --- [2] Method
    '', --- [3] Function
    '', --- [4] Constructor
    '', --- [5] Field
    '', --- [6] Variable
    '', --- [7] Class
    '', --- [8] Interface
    '', --- [9] Module
    '', --- [10] Property
    '', --- [11] Unit
    '', --- [12] Value
    '', --- [13] Enum
    '', --- [14] Keyword
    '', --- [15] Snippet
    '', --- [16] Color
    '', --- [17] File
    '', --- [18] Reference
    '', --- [19] Folder
    '', --- [20] EnumMember
    '', --- [21] Constant
    '', --- [22] Struct
    '', --- [23] Event
    '', --- [24] Operator
    '', --- [25] TypeParameter
}


return M
