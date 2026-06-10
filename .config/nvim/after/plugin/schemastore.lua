local add = require('vim-pack').add

add {
    {
        src = 'b0o/SchemaStore.nvim',
        setup = false, -- It's a data-only plugin, no .setup()
    }
}
