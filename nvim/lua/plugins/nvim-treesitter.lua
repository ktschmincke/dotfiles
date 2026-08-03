-- The main branch ships parsers and queries but enables nothing, so
-- highlighting, indentation and incremental selection are all set up here.
-- Requires Neovim 0.12+ and the tree-sitter-cli homebrew formula.

local PARSERS = {
  'angular',
  'bash',
  'c',
  'css',
  'diff',
  'go',
  'gomod',
  'gosum',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'scss',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
  -- Don't add `jsonc` (Neovim maps it to json) or `tmux` (no parser upstream;
  -- falls back to regex syntax). Both only produce warnings.
}

-- Filetypes whose name differs from their parser. Nothing registers these for
-- us, and without them these filetypes get no treesitter at all.
local FT_ALIASES = {
  angular = { 'htmlangular' },
  bash = { 'sh' },
  tsx = { 'typescriptreact' },
}

-- Incremental selection, which upstream no longer provides:
--   gnn  (normal) select the node under the cursor
--   v    (visual) grow to the enclosing node
--   V    (visual) shrink back

local sel_stack = {}

-- node:range() reports an exclusive end column. Convert to an inclusive cursor
-- position, stepping back a line when a node ends at column 0.
local function node_range(node)
  local sr, sc, er, ec = node:range()
  if ec == 0 and er > sr then
    er = er - 1
    ec = #(vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1] or '')
  end
  return sr, sc, er, math.max(ec - 1, 0)
end

local function select_range(sr, sc, er, ec)
  if vim.fn.mode():match '[vV\22]' then
    vim.cmd 'normal! \27'
  end
  vim.fn.setpos('.', { 0, sr + 1, sc + 1, 0 })
  vim.cmd 'normal! v'
  vim.fn.setpos('.', { 0, er + 1, ec + 1, 0 })
end

local function visual_range()
  local _, sl, sc = unpack(vim.fn.getpos 'v')
  local _, el, ec = unpack(vim.fn.getpos '.')
  local a, b = { sl - 1, sc - 1 }, { el - 1, ec - 1 }
  if a[1] > b[1] or (a[1] == b[1] and a[2] > b[2]) then
    a, b = b, a
  end
  return a[1], a[2], b[1], b[2]
end

local function grow()
  local sr, sc, er, ec = visual_range()
  local ok, node = pcall(vim.treesitter.get_node, { pos = { sr, sc } })
  if not ok or not node then
    return
  end
  -- Climb until a node covers strictly more than the selection. Re-deriving from
  -- the selection rather than the stack means a stale stack self-heals.
  while node do
    local nsr, nsc, ner, nec = node_range(node)
    local starts_earlier = nsr < sr or (nsr == sr and nsc < sc)
    local ends_later = ner > er or (ner == er and nec > ec)
    if starts_earlier or ends_later then
      table.insert(sel_stack, { sr, sc, er, ec })
      select_range(nsr, nsc, ner, nec)
      return
    end
    node = node:parent()
  end
end

local function shrink()
  local prev = table.remove(sel_stack)
  if prev then
    select_range(prev[1], prev[2], prev[3], prev[4])
  end
end

local function init_selection()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    return
  end
  sel_stack = {}
  select_range(node_range(node))
end

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false, -- upstream does not support lazy-loading
  build = ':TSUpdate', -- parsers are version-locked to the plugin
  config = function()
    for lang, filetypes in pairs(FT_ALIASES) do
      for _, ft in ipairs(filetypes) do
        vim.treesitter.language.register(lang, ft)
      end
    end

    -- no-op when the parsers are already present
    require('nvim-treesitter').install(PARSERS)

    vim.api.nvim_create_autocmd('FileType', {
      desc = 'Start treesitter highlighting and indentation where available',
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
          return
        end

        -- No parser installed: keep Neovim's regex syntax highlighting.
        if not pcall(vim.treesitter.start, ev.buf) then
          return
        end

        -- Treesitter indent is experimental, so only enable it where indent
        -- queries exist. Keying off the query file avoids a list to maintain.
        if #vim.api.nvim_get_runtime_file('queries/' .. lang .. '/indents.scm', false) > 0 then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    vim.keymap.set('n', 'gnn', init_selection, { desc = 'Select node under cursor' })
    vim.keymap.set('x', 'v', grow, { desc = 'Grow selection to enclosing node' })
    vim.keymap.set('x', 'V', shrink, { desc = 'Shrink selection to previous node' })
  end,
}
