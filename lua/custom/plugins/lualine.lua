---@module 'lazy'
---@type LazySpec
return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      local separators = vim.g.have_nerd_font
          and { section = { left = '', right = '' }, component = { left = '', right = '' } }
        or { section = { left = '', right = '' }, component = { left = '|', right = '|' } }

      return {
        options = {
          theme = 'auto',
          globalstatus = true,
          icons_enabled = vim.g.have_nerd_font,
          component_separators = separators.component,
          section_separators = separators.section,
          disabled_filetypes = {
            statusline = { 'alpha', 'dashboard' },
          },
        },
        sections = {
          lualine_a = {
            {
              'mode',
              separator = { left = separators.section.left },
              right_padding = 2,
            },
          },
          lualine_b = {
            {
              'branch',
              icon = vim.g.have_nerd_font and '' or 'git',
            },
            'diff',
          },
          lualine_c = {
            {
              'filename',
              path = 1,
              shorting_target = 60,
              newfile_status = true,
              symbols = {
                modified = ' [+]',
                readonly = ' [-]',
                unnamed = '[No Name]',
                newfile = '[New]',
              },
            },
          },
          lualine_x = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              sections = { 'error', 'warn', 'info', 'hint' },
              symbols = vim.g.have_nerd_font
                  and { error = ' ', warn = ' ', info = ' ', hint = ' ' }
                or { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
            },
          },
          lualine_y = { 'location' },
          lualine_z = {
            {
              'progress',
              separator = { right = separators.section.right },
              left_padding = 2,
            },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              'filename',
              path = 1,
              symbols = { unnamed = '[No Name]' },
            },
          },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
  },
}
