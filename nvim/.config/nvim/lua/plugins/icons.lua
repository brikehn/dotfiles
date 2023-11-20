return {
  {
    "yamatsum/nvim-nonicons",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" }
    },
    config = function()
      require("nvim-nonicons").setup()
    end
  },
}
