-- Bufferline: muestra los archivos abiertos como pestañas visuales

-- Auto-revela el archivo en neo-tree al cambiar de buffer
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Revelar archivo actual en neo-tree',
  callback = function()
    -- Solo si neo-tree ya está abierto (no lo fuerza a abrir)
    local manager_ok, manager = pcall(require, 'neo-tree.sources.manager')
    if not manager_ok then return end

    local state = manager.get_state('filesystem', nil, nil)
    if not state or not state.window or not vim.api.nvim_win_is_valid(state.window.winid or -1) then
      return
    end

    local filepath = vim.fn.expand '%:p'
    if filepath == '' or vim.bo.buftype ~= '' then return end

    require('neo-tree.command').execute {
      action = 'focus',
      source = 'filesystem',
      position = 'left',
      reveal = true,
      reveal_force_cwd = false,
    }

    -- Volvé el foco al buffer de código, no al árbol
    vim.schedule(function()
      local wins = vim.api.nvim_tabpage_list_wins(0)
      for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= 'neo-tree' then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
    end)
  end,
})

---@module 'lazy'
---@type LazySpec
return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VimEnter',
    opts = {
      options = {
        -- Muestra los buffers por tab — cada proyecto ve solo SUS archivos
        scope = { use_cwd = true },

        -- Estilo de las pestañas
        mode = 'buffers',
        separator_style = 'slant',
        always_show_bufferline = true,

        -- Cierra buffer con click en la X
        close_command = 'bdelete! %d',
        right_mouse_command = 'bdelete! %d',

        -- Íconos
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = false,

        -- Diagnósticos LSP en las pestañas (muestra errores/warnings)
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = ' ', warning = ' ' }
          local ret = (diag.error and icons.error .. diag.error .. ' ' or '')
            .. (diag.warning and icons.warning .. diag.warning or '')
          return vim.trim(ret)
        end,

        -- No mostrar buffers de neo-tree ni otros tools
        custom_filter = function(buf_number)
          local buftype = vim.bo[buf_number].buftype
          local filetype = vim.bo[buf_number].filetype
          local name = vim.api.nvim_buf_get_name(buf_number)
          if buftype == 'terminal' then return false end
          if filetype == 'neo-tree' then return false end
          if filetype == 'lazy' then return false end
          if filetype == 'mason' then return false end
          if name == '' then return false end
          return true
        end,

        offsets = {
          {
            filetype = 'neo-tree',
            text = 'Explorer',
            highlight = 'Directory',
            separator = true,
          },
        },
      },
    },
    keys = {
      { '<Tab>',   '<cmd>BufferLineCycleNext<CR>', desc = 'Buffer siguiente' },
      { '<S-Tab>', '<cmd>BufferLineCyclePrev<CR>', desc = 'Buffer anterior' },
      { '<leader>bc', '<cmd>bdelete!<CR>',           desc = '[B]uffer [C]errar' },
      { '<leader>bp', '<cmd>BufferLineTogglePin<CR>', desc = '[B]uffer [P]in' },
      -- Revelar archivo actual en neo-tree (abre carpetas hasta llegar al archivo)
      {
        '<leader>bf',
        function()
          require('neo-tree.command').execute {
            action = 'focus',
            source = 'filesystem',
            position = 'left',
            reveal = true,
            reveal_force_cwd = false,
          }
        end,
        desc = '[B]uffer [F]ind in tree',
      },
      -- Ir directo a un buffer por número
      { '<leader>b1', '<cmd>BufferLineGoToBuffer 1<CR>', desc = 'Buffer 1' },
      { '<leader>b2', '<cmd>BufferLineGoToBuffer 2<CR>', desc = 'Buffer 2' },
      { '<leader>b3', '<cmd>BufferLineGoToBuffer 3<CR>', desc = 'Buffer 3' },
      { '<leader>b4', '<cmd>BufferLineGoToBuffer 4<CR>', desc = 'Buffer 4' },
      { '<leader>b5', '<cmd>BufferLineGoToBuffer 5<CR>', desc = 'Buffer 5' },
    },
  },
}
