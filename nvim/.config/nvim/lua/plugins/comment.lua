return {
    { 
	"JoosepAlviste/nvim-ts-context-commentstring",
	opts = {
	    enable_autocmd = false,
	}
    },
    {
	'numToStr/Comment.nvim',
	opts = function(_, opts)
	    opts.pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
	end,
    },
}
