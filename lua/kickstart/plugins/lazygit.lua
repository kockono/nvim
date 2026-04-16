-- LazyGit — Git UI completa en terminal flotante
-- https://github.com/kdheepak/lazygit.nvim

---@module 'lazy'
---@type LazySpec
return {
  'kdheepak/lazygit.nvim',
  lazy = true,
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>gg', '<cmd>LazyGit<CR>', desc = 'LazyGit', silent = true },
  },
}
