-- Recarga el init.lua sin cerrar nvim
-- Keymap: <leader>rr

local function reload_config()
  -- Limpia el cache de todos los módulos custom para forzar recarga completa
  for name, _ in pairs(package.loaded) do
    if name:match '^custom' or name:match '^kickstart' then
      package.loaded[name] = nil
    end
  end

  -- Recarga el init.lua
  dofile(vim.env.MYVIMRC)

  vim.notify('Config recargada ✓', vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>rr', reload_config, { desc = '[R]eload config' })

---@module 'lazy'
---@type LazySpec
return {}
