---@module 'lazy'
---@type LazySpec
return {
  {
    'tpope/vim-fugitive',
    cmd = {
      'Git',
      'G',
      'Gdiffsplit',
      'Gvdiffsplit',
      'Gblame',
      'Gread',
      'Gwrite',
      'Gclog',
      'Gmove',
      'Gdelete',
      'Gbrowse',
    },
    keys = {
      { '<leader>gs', '<cmd>Git<CR>', desc = '[G]it [S]tatus' },
      { '<leader>gb', '<cmd>Gblame<CR>', desc = '[G]it [B]lame' },
      { '<leader>gd', '<cmd>Gdiffsplit<CR>', desc = '[G]it [D]iff split' },
    },
  },
}
