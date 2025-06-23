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
    Text = '', --- [1] Text
    Method = '', --- [2] Method
    Function = '', --- [3] Function
    Constructor = '', --- [4] Constructor
    Field = '', --- [5] Field
    Variable = '', --- [6] Variable
    Class = '', --- [7] Class
    Interface = '', --- [8] Interface
    Module = '', --- [9] Module
    Propery = '', --- [10] Property
    Unit = '', --- [11] Unit
    Value = '', --- [12] Value
    Enum = '', --- [13] Enum
    Keyword = '', --- [14] Keyword
    Snippet = '', --- [15] Snippet
    Color = '', --- [16] Color
    File = '', --- [17] File
    Reference = '', --- [18] Reference
    Folder = '', --- [19] Folder
    EnumMember = '', --- [20] EnumMember
    Constant = '', --- [21] Constant
    Struct = '', --- [22] Struct
    Event = '', --- [23] Event
    Operator = '', --- [24] Operator
    TypeParameter = '', --- [25] TypeParameter
}


return M
