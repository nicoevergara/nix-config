-- Standard Neovim settings needed for dropbar
vim.opt.mouse = "a" -- Required for clicking the breadcrumbs
vim.opt.termguicolors = true -- Required for icon colors

vim.opt.number = true

-- Enable Treesitter syntax highlighting (parsers are provided via Nix).
-- The nvim-treesitter "main" branch only installs parsers; highlighting is
-- started per-buffer via vim.treesitter.start() in a FileType autocommand.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "nix", "rust", "lua", "python", "typescript", "javascript", "typescriptreact", "javascriptreact" },
	callback = function()
		vim.treesitter.start()
	end,
})

-- Auto-enter terminal-insert mode when a terminal opens or regains focus, so
-- the Claude pane is immediately interactive instead of landing in normal mode.
vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter", "WinEnter" }, {
	pattern = "term://*",
	callback = function()
		vim.cmd("startinsert")
	end,
})

-- Python: ruff handles linting/formatting; ty provides type checking, hover
-- types, completion, and go-to-definition. Run them together.
vim.lsp.config("ruff", {
	-- Let ty own hover/type info; ruff stays focused on lint diagnostics.
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
})
vim.lsp.enable("ruff")
vim.lsp.config("ty", {
	cmd = { "ty", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ty.toml", ".git" },
	-- Show inferred types inline (instead of having to press K) for variables
	-- and parameters without explicit annotations.
	on_attach = function(_, bufnr)
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end,
})
vim.lsp.enable("ty")

-- TypeScript / JavaScript: ts_ls provides hover types, completion, go-to-def,
-- and inlay hints. Unlike ty, the server ships inlay hints OFF by default, so
-- each category is opted into via `settings`, then rendered via inlay_hint.enable.
local ts_inlay_hints = {
	includeInlayParameterNameHints = "all",
	includeInlayParameterNameHintsWhenArgumentMatchesName = false,
	includeInlayFunctionParameterTypeHints = true,
	includeInlayVariableTypeHints = true,
	includeInlayVariableTypeHintsWhenTypeMatchesName = false,
	includeInlayPropertyDeclarationTypeHints = true,
	includeInlayFunctionLikeReturnTypeHints = true,
	includeInlayEnumMemberValueHints = true,
}
vim.lsp.config("ts_ls", {
	settings = {
		typescript = { inlayHints = ts_inlay_hints },
		javascript = { inlayHints = ts_inlay_hints },
	},
	on_attach = function(_, bufnr)
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end,
})
vim.lsp.enable("ts_ls")

vim.lsp.enable("lua_ls")

-- lazydev configures lua_ls's workspace library with the Neovim runtime and
-- your installed plugins, so `vim.*` and plugin APIs get type hints/completion.
require("lazydev").setup({})

-- Initialize dropbar
require("dropbar").setup({
	-- You can leave this empty for defaults
	-- or customize the symbols/icons here
})
require("blink.cmp").setup({
	keymap = { preset = "default" },

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		documentation = { auto_show = false },
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer", "lazydev" },
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				-- show lazydev completions above LSP
				score_offset = 100,
			},
		},
	},

	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})
require("conform").setup({
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		-- Conform will run multiple formatters sequentially
		python = { "ruff" },
		-- You can customize some of the format options for the filetype (:help conform.format)
		rust = { "rustfmt", lsp_format = "fallback" },
	},
})

-- mini.icons is the icon provider; mock nvim-web-devicons so plugins that
-- expect it (neo-tree, blink.cmp, etc.) get icons from mini.icons.
require("mini.icons").setup({})
MiniIcons.mock_nvim_web_devicons()

require("neo-tree").setup({})

-- Open Neo-tree as a left sidebar on startup (focus stays in the editor window).
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("neo-tree.command").execute({ action = "show", position = "left" })
	end,
})

require("catppuccin").setup({
	flavour = "latte", -- 'latte'|'frappe'|'macchiato'|'mocha'
	transparent_background = false,
	integrations = {
		blink_cmp = true,
		neotree = true,
		treesitter = true,
		native_lsp = { enabled = true },
		mini = { enabled = true },
	},
})
vim.cmd.colorscheme("catppuccin")

-- Telescope: fuzzy finder for files, grep, buffers, etc.
require("telescope").setup({})
-- Native FZF sorter for faster/better fuzzy matching (prebuilt via Nix).
require("telescope").load_extension("fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: help tags" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Telescope: recent files" })

-- Claude Code: connects to the `claude` CLI (installed via Nix).
require("claudecode").setup({})
vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Claude: toggle" })
vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude: focus" })
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Claude: add current buffer" })
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude: send selection" })
vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Claude: accept diff" })
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Claude: deny diff" })
