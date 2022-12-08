--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]

-- general
lvim.log.level = "warn"
lvim.leader = "space"
lvim.colorscheme = "gruvbox-material"

lvim.transparent_window = true
lvim.format_on_save = true

vim.o.background = "dark"

vim.opt.updatetime = 50
vim.opt.rnu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.mouse = "a"
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 4

vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.cmdheight = 1

vim.opt.guicursor = ""
vim.opt.clipboard = ""

-- Formattings
lvim.format_on_save = true

-- Change theme settings
lvim.builtin.theme.options.style = "storm"

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.autopairs.active = false

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"

lvim.builtin.notify.active = false
lvim.builtin.terminal.active = true
lvim.builtin.bufferline.active = false

lvim.builtin.nvimtree.setup.disable_netrw = false
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

lvim.builtin.which_key.setup.window.winblend = 20
lvim.builtin.which_key.setup.plugins.registers = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
    "bash",
    "c",
    "javascript",
    "json",
    "lua",
    "python",
    "typescript",
    "tsx",
    "css",
    "rust",
    "java",
    "yaml",
    "go",
}

-- Activate Emmet to *.tmpl files
-- lvim.builtin.Emmet.filetypes = { "html", "tmpl" }

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true

-- generic LSP settings
lvim.lsp.diagnostics.virtual_text = false
lvim.lsp.document_highlight = true

-- Additional Plugins
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "rust_analyzer" })

lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"
table.insert(lvim.builtin.cmp.sources, 1, { name = "copilot" })

lvim.plugins = {
    {
        "simrat39/rust-tools.nvim",
        -- ft = { "rust", "rs" }, -- IMPORTANT: re-enabling this seems to break inlay-hints
        config = function()
            require("rust-tools").setup {
                tools = {
                    executor = require("rust-tools/executors").termopen, -- can be quickfix or termopen
                    reload_workspace_from_cargo_toml = true,
                    inlay_hints = {
                        auto = true,
                        only_current_line = false,
                        show_parameter_hints = true,
                        parameter_hints_prefix = "<-",
                        other_hints_prefix = "=>",
                        max_len_align = false,
                        max_len_align_padding = 1,
                        right_align = false,
                        right_align_padding = 7,
                        highlight = "Comment",
                    },
                    hover_actions = {
                        border = {
                            { "╭", "FloatBorder" },
                            { "─", "FloatBorder" },
                            { "╮", "FloatBorder" },
                            { "│", "FloatBorder" },
                            { "╯", "FloatBorder" },
                            { "─", "FloatBorder" },
                            { "╰", "FloatBorder" },
                            { "│", "FloatBorder" },
                        },
                        auto_focus = true,
                    },
                },
                server = {
                    on_init = require("lvim.lsp").common_on_init,
                    on_attach = function(client, bufnr)
                        require("lvim.lsp").common_on_attach(client, bufnr)
                        local rt = require "rust-tools"
                        -- Hover actions with Toggle "<C-b>"
                        vim.keymap.set("n", "<C-b>", rt.hover_actions.hover_actions, { buffer = bufnr })

                        -- Code action groups
                        vim.keymap.set("n", "<leader>lg", rt.code_action_group.code_action_group, { buffer = bufnr })
                    end,
                },
            }
        end,
    },
    {
        "folke/trouble.nvim",
        cmd = "TroubleToggle",
    },
    {
        "mbbill/undotree",
    },
    {
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        ft = "markdown",
        config = function()
            vim.g.mkdp_auto_start = 1
        end,
    },
    {
        "zbirenbaum/copilot.lua",
        event = { "VimEnter" },
        config = function()
            vim.defer_fn(function()
                require("copilot").setup {
                    plugin_manager_path = get_runtime_dir() .. "/site/pack/packer",
                    panel = {
                        enabled = true,
                        auto_refresh = true
                    },
                    suggestion = {
                        enabled = true,
                        auto_trigger = true,
                        keymap = {
                            accept = "<C-f>",
                            next = "<C-]>",
                            prev = "<C-[>",
                            dismiss = "<C-p>",
                        }
                    },
                }
            end, 100)
        end,
    },
    { "zbirenbaum/copilot-cmp",
        after = { "copilot.lua", "nvim-cmp" },
    },
    {
        "wakatime/vim-wakatime"
    },
    {
        "sainnhe/gruvbox-material",
    },
    {
        "fatih/vim-go",
    },
    {
        "evanleck/vim-svelte",
    },
    {
        "rest-nvim/rest.nvim",
    }
}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

local function bind(op, outer_opts)
    outer_opts = outer_opts or { noremap = true }
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("force",
            outer_opts,
            opts or {}
        )
        vim.keymap.set(op, lhs, rhs, opts)
    end
end

local nmap = bind("n", { noremap = false })
local nnoremap = bind("n")
local vnoremap = bind("v")
local xnoremap = bind("x")
local inoremap = bind("i")

-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

nnoremap("<leader>]", "}b")
nnoremap("<leader>[", "{w$")

nnoremap("<leader>o", "o<Esc>0")
nnoremap("<leader>O", "O<Esc>0")

-- nnoremap("<leader>pv", ":Ex<CR>")
nnoremap("<leader>h", ":noh<CR>")
nnoremap("<leader>u", ":UndotreeToggle<CR>")

vnoremap("J", ":m '>+1<CR>gv=gv")
vnoremap("K", ":m '<-2<CR>gv=gv")
vnoremap("<leader>s", ":s/\\(\\w.*\\)/")

nnoremap("Y", "yg$")
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")
nnoremap("J", "mzJ`z")
nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")

-- greatest remap ever
xnoremap("<leader>p", "\"_dP")

-- next greatest remap ever : asbjornHaland
nnoremap("<leader>y", "\"+y")
vnoremap("<leader>y", "\"+y")
nmap("<leader>Y", "\"+Y")

nnoremap("<leader>p", "\"+p")
vnoremap("<leader>p", "\"+p")
nmap("<leader>P", "\"+P")

nnoremap("<leader>d", "\"_d")
vnoremap("<leader>d", "\"_d")

vnoremap("<leader>d", "\"_d")

inoremap("<C-c>", "<Esc>")

nnoremap("Q", "<nop>")
nnoremap("<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")


nnoremap("<C-k>", "<cmd>cnext<CR>zz")
nnoremap("<C-j>", "<cmd>cprev<CR>zz")
nnoremap("<leader>k", "<cmd>lnext<CR>zz")
nnoremap("<leader>j", "<cmd>lprev<CR>zz")
nnoremap("<leader>a", "$F{a<Enter><Esc>O")
nnoremap("<leader>v", "va}%V%")

nnoremap("<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
nnoremap("<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

nnoremap("<leader>ge", "_f=F i, err<Esc>oif err != nil {<Enter>}<Esc>ko")
nnoremap("<leader>gE", "_ierr := <Esc>oif err != nil {<Enter>}<Esc>ko")

nnoremap("<leader>ro", "_iOk(<Esc>$a)<Esc>")
nnoremap("<leader>re", "_iErr(<Esc>$a)<Esc>")
nnoremap("<leader>rs", "_iSome(<Esc>$a)<Esc>")
nnoremap("<leader>rn", "iNone<Esc>")
nnoremap("<leader>rw", "$F>WciW")

-- plugin mappings
nnoremap("<leader>R", "<Plug>RestNvim")

nnoremap("<leader>gr", ":GoRun % ")
nnoremap("<leader>gt", ":GoTest")
nnoremap("<leader>gc", ":GoCoverageToggle")

nnoremap("<leader>rr", ":!cargo run -- ")

vim.api.nvim_create_user_command("OpenSayHello", function(input)
    vim.api.nvim_command(":!open 'https://beta.sayhello.so/search?q=" .. input.args .. "'")
end,
    { nargs = 1 }
)

-- open url in browser
nnoremap("<leader>S", ":OpenSayHello ")
