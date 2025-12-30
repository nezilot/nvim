local keymap = vim.keymap.set

keymap("n", "<leader>f", function()
	require("fzf-lua").files({
		actions = {
			["default"] = function(selected, opts)
				require("fzf-lua.actions").file_edit(selected, opts)

				vim.cmd("silent! execute '%bdelete | edit # | normal! \"_dd'")
			end,
		}
	})
end, { desc = "Fzf files" })

keymap("n", "<leader>g", function()
	require("fzf-lua").live_grep({
		actions = {
			["default"] = function(selected, opts)
				require("fzf-lua.actions").file_edit(selected, opts)

				vim.cmd("silent! execute '%bdelete | edit # | normal! \"_dd'")
			end,
		}
	})
end, { desc = "Fzf live grep" })
