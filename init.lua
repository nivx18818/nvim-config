-- settings.lua

-- Clipboard
vim.opt.clipboard = 'unnamedplus'

-- Search ignoring case
vim.opt.ignorecase = true

-- Disable "ignorecase" when searching with uppercase letters
vim.opt.smartcase = true

-- Leader key
vim.g.mapleader = ' '

-- Simulate same tab behavior
vim.keymap.set('n', '<Tab>', ':Tabnext<CR>', { silent = true })
vim.keymap.set('n', '<S-Tab>', ':Tabprev<CR>', { silent = true })

-- Clear search highlighting
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { silent = true })

-- -- Keep cursor centered when scrolling
-- vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true });
-- vim.keymap.set('n', '<C-u>', '<C-u>zz', { silent = true });
-- vim.keymap.set('n', '<C-f>', '<C-f>zz', { silent = true });
-- vim.keymap.set('n', '<C-b>', '<C-b>zz', { silent = true });

-- NORMAL MODE: keep cursor in place after search
vim.keymap.set('n', '*', '*N', { silent = true }) -- highlight word under cursor, stay on it
vim.keymap.set('n', '#', '#N', { silent = true }) -- same for backwards search

-- VISUAL MODE: search for selection and reselect
vim.keymap.set('v', '*', '"vy/<C-r>v<CR>gv', { silent = true }) -- search forward for visual selection, reselect it
vim.keymap.set('v', '#', '"vy?<C-r>v<CR>gv', { silent = true }) -- search backward for visual selection, reselect it

-- Yank from first to last non-blank character
vim.keymap.set('n', 'Y', '^yg_');

-- Better Navigation
local directions = {
  ['<C-j>'] = 'workbench.action.navigateDown',
  ['<C-k>'] = 'workbench.action.navigateUp',
  ['<C-h>'] = 'workbench.action.navigateLeft',
  ['<C-l>'] = 'workbench.action.navigateRight',
}

for key, cmd in pairs(directions) do
  vim.keymap.set('n', key, function() vim.fn.VSCodeNotify(cmd) end, { silent = true })
  vim.keymap.set('x', key, function() vim.fn.VSCodeNotify(cmd) end, { silent = true })
end

vim.keymap.set('n', 'gr', function() vim.fn.VSCodeNotify('editor.action.goToReferences') end, { silent = true })
vim.keymap.set('n', '<C-w>_', function() vim.fn.VSCodeNotify('workbench.action.toggleEditorWidths') end, { silent = true })

-- <Space> to whichkey
vim.keymap.set('n', '<Space>', function() vim.fn.VSCodeNotify('whichkey.show') end, { silent = true })

-- Visual mode open whichkey
vim.keymap.set('x', '<Space>', function()
  vim.cmd('normal! gv')
  local mode = vim.fn.visualmode()
  if mode == 'V' then
    vim.fn.VSCodeNotifyRange('whichkey.show', vim.fn.line('v'), vim.fn.line('.'), 1)
  else
    local startPos = vim.fn.getpos('v')
    local endPos = vim.fn.getpos('.')
    vim.fn.VSCodeNotifyRangePos('whichkey.show', startPos[2], endPos[2], startPos[3], endPos[3], 1)
  end
end, { silent = true })

-- Visual mode: open vscode commands
vim.keymap.set('x', '<C-P>', function()
  vim.cmd('normal! gv')
  local mode = vim.fn.visualmode()
  if mode == 'V' then
    vim.fn.VSCodeNotifyRange('workbench.action.showCommands', vim.fn.line('v'), vim.fn.line('.'), 1)
  else
    local startPos = vim.fn.getpos('v')
    local endPos = vim.fn.getpos('.')
    vim.fn.VSCodeNotifyRangePos('workbench.action.showCommands', startPos[2], endPos[2], startPos[3], endPos[3], 1)
  end
end, { silent = true })

-- Tab-style commentary mappings
vim.keymap.set('x', 'gc', '<Plug>VSCodeCommentary')
vim.keymap.set('n', 'gc', '<Plug>VSCodeCommentary')
vim.keymap.set('o', 'gc', '<Plug>VSCodeCommentary')
vim.keymap.set('n', 'gcc', '<Plug>VSCodeCommentaryLine')

-- <C-/> mappings with operatorfunc
vim.keymap.set('n', '<C-_>', function()
  vim.o.operatorfunc = 'v:lua.vscode_commentary'
  return 'g@'
end, { expr = true })

vim.keymap.set('x', '<C-_>', function()
  return vscode_commentary()
end, { expr = true })

-- Commentary function for operator mode
function _G.vscode_commentary(...)
  local line1, line2
  if select('#', ...) == 0 then
    return 'g@'
  elseif select('#', ...) > 1 then
    line1, line2 = ...
  else
    line1 = vim.fn.line("'[")
    line2 = vim.fn.line("']")
  end
  vim.fn.VSCodeCallRange("editor.action.commentLine", line1, line2, 0)
  return ''
end

-- Optional: manageEditorSize (you may not need it)
function _G.manageEditorSize(count, to)
  count = count or 1
  local cmd = to == 'increase' and 'workbench.action.increaseViewSize' or 'workbench.action.decreaseViewSize'
  for _ = 1, count do
    vim.fn.VSCodeNotify(cmd)
  end
end

-- lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- nvim-surround setup
require("lazy").setup({
  {
    "kylechui/nvim-surround",
    version = "*",
    config = function()
      require("nvim-surround").setup()
    end
  }
})

