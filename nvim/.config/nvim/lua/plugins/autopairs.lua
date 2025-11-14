return {
    {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function ()
	    local npairs = require("nvim-autopairs")
	    local Rule = require("nvim-autopairs.rule")

	    npairs.setup({
		check_ts = true,
	    })

	    npairs.add_rules({
		Rule(" ", " "):with_pair(function(opts)
		    local pair = opts.line:sub(opts.col - 1, opts.col)
		    return vim.tbl_contains({ "()", "[]", "{}" }, pair)
		end),
		Rule("( ", " )")
		    :with_pair(function()
			return false
		    end)
		    :with_move(function(opts)
			return opts.prev_char:match(".%)") ~= nil
		    end)
		    :use_key(")"),
		Rule("{ ", " }")
		    :with_pair(function()
			return false
		    end)
		    :with_move(function(opts)
			return opts.prev_char:match(".%}") ~= nil
		    end)
		    :use_key("}"),
		Rule("[ ", " ]")
		    :with_pair(function()
			return false
		    end)
		    :with_move(function(opts)
			return opts.prev_char:match(".%]") ~= nil
		    end)
		    :use_key("]"),
	    })

	    for _, punct in pairs({ ",", ";" }) do
		npairs.add_rules({
		    Rule("", punct)
			:with_move(function(opts)
			    return opts.char == punct
			end)
			:with_pair(function()
			    return false
			end)
			:with_del(function()
			    return false
			end)
			:with_cr(function()
			    return false
			end)
			:use_key(punct),
		})
	    end

	    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	    local cmp = require("cmp")
	    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

	end
    },
    {
	"kylechui/nvim-surround",
	version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	opts = {},
    }
}
