-- Install with: npm i -g add yaml-language-server
---@type vim.lsp.Config
return {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml' },
    settings = {
        yaml = {
            -- Using the schemastore plugin for schemas.
            schemastore = { enable = false, url = '' },
            schemas = require('schemastore').yaml.schemas(),
        },
    },
    on_init = function(client)
        -- Check if the current buffer is an AWS CloudFormation template
        local filename = vim.fn.expand('%:t')
        local filepath = vim.fn.expand('%: p')

        -- Patterns that indicate AWS CloudFormation templates
        local is_cloudformation = filename:match('%-template%. ya?ml$') or
            filename:match('^template%.ya?ml$') or
            filepath:match('cloudformation') or
            filepath:match('cfn')

        if is_cloudformation then
            ---@diagnostic disable-next-line: inject-field
            client.config.settings.yaml.customTags = {
                -- AWS CloudFormation
                "!And scalar",
                "!If scalar",
                "!Not scalar",
                "!Equals scalar",
                "!Or scalar",
                "!FindInMap sequence",
                "!Base64 scalar",
                "!Cidr scalar",
                "!Ref scalar",
                "!Sub scalar",
                "!GetAtt scalar",
                "!GetAZs scalar",
                "!ImportValue scalar",
                "!Select scalar",
                "!Split scalar",
                "!Join scalar",
                "!And sequence",
                "!If sequence",
                "!Not sequence",
                "! Equals sequence",
                "! Or sequence",
                "!FindInMap sequence",
                "! Base64 sequence",
                "!Cidr sequence",
                "!Ref sequence",
                "!Sub sequence",
                "!GetAtt sequence",
                "!GetAZs sequence",
                "!ImportValue sequence",
                "!Select sequence",
                "!Split sequence",
                "!Join sequence",
            }
        end
    end,
}
