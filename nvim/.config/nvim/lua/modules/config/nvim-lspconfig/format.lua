local prettier = { formatCommand = "prettierd ${INPUT}", formatStdin = true }

local eslint = {
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true,
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %m" },
  lintIgnoreExitCode = true,
}

local stylua = { formatCommand = "stylua -s --indent-type='Spaces' --indent-width=2 -", formatStdin = true }

local shfmt = { formatCommand = "shfmt -i 2 -ci -s -bn", formatStdin = true }

local shellcheck = {
  lintCommand = "shellcheck -f gcc -x",
  lintFormats = { "%f:%l:%c: %trror: %m", "%f:%l:%c: %tote: %m" },
}

local black = { formatCommand = "black --quiet -", formatStdin = true }

local flake8 = {
  lintCommand = "flake8 --stdin-display-name ${INPUT} -",
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %m" },
}

local yamllint = { lintCommand = "yamllint -f parsable -", lintStdin = true }

return {
  lua = { stylua },
  sh = { shfmt, shellcheck },
  typescript = { prettier, eslint },
  javascript = { prettier, eslint },
  typescriptreact = { prettier, eslint },
  javascriptreact = { prettier, eslint },
  html = { prettier },
  css = { prettier },
  json = { prettier },
  ["markdown.mdx"] = { prettier },
  markdown = { prettier },
  graphql = { prettier },
  python = { black, flake8 },
  yaml = { prettier, yamllint },
}
