return function()
  local git_worktree = safe_require("git-worktree")
  if not git_worktree then
    return
  end

  git_worktree.setup()
  require("telescope").load_extension("git_worktree")
end
