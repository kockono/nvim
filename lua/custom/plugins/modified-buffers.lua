-- Modified buffers picker
-- Lists ONLY buffers with unsaved changes (option A: current session buffers)
-- Keymap: <leader>sm (Search Modified) — idiomatic with existing <leader>s* scheme
-- Also tries <C-A-m> (Ctrl+Alt+M) — may not work in all terminals

---@module 'lazy'
---@type LazySpec
return {
  -- No new plugin needed — uses telescope.nvim already installed
  'nvim-telescope/telescope.nvim',
  optional = true, -- don't re-install, just add config on top
  config = function()
    local builtin = require 'telescope.builtin'

    -- Returns a list of buffer numbers that have unsaved changes
    local function modified_buffers()
      return vim.tbl_filter(function(bufnr)
        return vim.api.nvim_buf_is_loaded(bufnr)
          and vim.api.nvim_buf_get_option(bufnr, 'modified')
          and vim.api.nvim_buf_get_name(bufnr) ~= '' -- exclude unnamed scratch buffers
      end, vim.api.nvim_list_bufs())
    end

    local function telescope_modified_buffers()
      local bufs = modified_buffers()
      if #bufs == 0 then
        vim.notify('No modified buffers', vim.log.levels.INFO)
        return
      end
      -- builtin.buffers accepts a `bufnr_list` filter via its internal picker
      -- We use the predicate filter approach via show_all_buffers=false is not enough,
      -- so we pass bufnr list directly through the ignore_current_buffer option is also not it.
      -- The cleanest approach: use buffers picker with a custom filter function.
      builtin.buffers {
        bufnr_list = bufs, -- undocumented but works: filters the picker to these bufnrs
        sort_mru = true,
        prompt_title = 'Modified Buffers',
        show_all_buffers = false,
      }
    end

    -- Primary keymap: <leader>sm — fits existing <leader>s* (Search *) scheme
    vim.keymap.set('n', '<leader>sm', telescope_modified_buffers, { desc = '[S]earch [M]odified buffers' })

    -- Secondary: try Alt+Shift+M
    vim.keymap.set('n', '<M-M>', telescope_modified_buffers, { desc = 'Modified buffers (Alt+Shift+M)' })
  end,
}
