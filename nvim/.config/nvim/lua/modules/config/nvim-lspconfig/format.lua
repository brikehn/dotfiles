local prettier = { formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true }

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %m" },
  lintIgnoreExitCode = true,
}

local stylua = { formatCommand = "stylua -s --indent-type='Spaces' --indent-width=2 -", formatStdin = true }

local shfmt = { formatCommand = "shfmt -i 2 -ci -s -bn", formatStdin = true }

local black = { formatCommand = "black --quiet -", formatStdin = true }

local flake8 = {
  lintCommand = "flake8 --stdin-display-name ${INPUT} -",
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %m" },
}

local rustfmt = { formatCommand = "rustfmt", formatStdin = true }

local gofmt = { formatCommand = "gofmt", formatStdin = true }

return {
  lua = { stylua },
  sh = { shfmt },
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
  yaml = { prettier },
  rust = { rustfmt },
  prisma = { prettier }
  go = { gofmt },
}
