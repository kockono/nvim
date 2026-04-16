---@module 'lazy'
---@type LazySpec
return {
  {
    'tanvirtin/monokai.nvim',
    lazy = false,
    priority = 900,
    config = function()
      require('monokai').setup {}
    end,
  },
}
