-- Project management: sesiones automáticas + navegación entre proyectos

-- Tus 3 proyectos — editá los paths si cambian
local projects = {
  { name = 'App-Menu',        path = 'E:/Codigos/Proyectos/App-Menu' },
  { name = 'Crafting-POE2',   path = 'E:/Codigos/Proyectos/Crating-POE2' },
  { name = 'Proyecto-Fechac', path = 'E:/Codigos/Proyectos/Proyecto-Fechac' },
}

local function project_short_name(name)
  local initials = {}

  for part in name:gmatch('[^_-]+') do
    if part ~= '' then table.insert(initials, part:sub(1, 1):upper()) end
    if #initials == 2 then break end
  end

  if #initials == 0 then return name:sub(1, 1):upper() end
  return table.concat(initials)
end

local function is_current_tab_empty()
  local tab = vim.api.nvim_get_current_tabpage()
  local ok, _ = pcall(vim.api.nvim_tabpage_get_var, tab, 'project_name')
  if ok then return false end

  local wins = vim.api.nvim_tabpage_list_wins(tab)
  if #wins ~= 1 then return false end

  local buf = vim.api.nvim_win_get_buf(wins[1])
  if vim.bo[buf].modified or vim.bo[buf].buftype ~= '' then return false end
  if vim.api.nvim_buf_get_name(buf) ~= '' then return false end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return #lines == 1 and lines[1] == ''
end

local function find_reusable_empty_tab()
  local current_tab = vim.api.nvim_get_current_tabpage()
  if is_current_tab_empty() then return current_tab end

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    vim.api.nvim_set_current_tabpage(tab)
    if is_current_tab_empty() then return tab end
  end

  vim.api.nvim_set_current_tabpage(current_tab)
  return nil
end

-- Tabline personalizada que muestra el nombre del proyecto por tab
local function get_tab_name(tab)
  -- Primero buscá si la tab tiene un nombre de proyecto guardado
  local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, 'project_name')
  if ok and name then return project_short_name(name) end
  -- Fallback: nombre de la carpeta del CWD
  local tabnr = vim.api.nvim_tabpage_get_number(tab)
  return project_short_name(vim.fn.fnamemodify(vim.fn.getcwd(-1, tabnr), ':t'))
end

local function render_tabline()
  local result = ''
  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local is_current = tab == vim.api.nvim_get_current_tabpage()
    local name = get_tab_name(tab)
    -- %{i}T activa el click del mouse en esta tab
    if is_current then
      result = result .. '%' .. i .. 'T' .. '%#TabLineSel# ' .. i .. ' ' .. name .. ' %#TabLineFill#'
    else
      result = result .. '%' .. i .. 'T' .. '%#TabLine# ' .. i .. ' ' .. name .. ' %#TabLineFill#'
    end
  end
  -- %T cierra el último bloque clickeable
  result = result .. '%T'
  return result
end

-- Abre un proyecto en una tab de nvim (crea la tab si no existe)
local function open_project_tab(project)
  -- Buscá si ya hay una tab con ese proyecto
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, 'project_name')
    if ok and name == project.name then
      vim.api.nvim_set_current_tabpage(tab)
      return
    end
  end

  -- Reutilizá una tab vacía si existe; si no, creá una nueva.
  local current_tab = find_reusable_empty_tab()
  if current_tab then
    vim.api.nvim_set_current_tabpage(current_tab)
  else
    vim.cmd 'tabnew'
    current_tab = vim.api.nvim_get_current_tabpage()
  end

  -- Usá tcd (tab-local) en lugar de cd (global) para aislar el CWD por tab
  vim.cmd('tcd ' .. vim.fn.fnameescape(project.path))
  -- Guardá el nombre del proyecto en la variable de la tab
  vim.api.nvim_tabpage_set_var(current_tab, 'project_name', project.name)
  -- Abrí neo-tree apuntando al proyecto
  vim.cmd('Neotree position=left dir=' .. vim.fn.fnameescape(project.path))
  vim.cmd 'redrawtabline'
end

-- Expuesta globalmente para que vim.o.tabline pueda llamarla
_G.projects_tabline = render_tabline

---@module 'lazy'
---@type LazySpec
return {
  -- Guarda y restaura la sesión automáticamente por directorio
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {
      dir = vim.fn.stdpath 'data' .. '/sessions/',
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp' },
      pre_save = nil,
      save_empty = false,
    },
    keys = {
      { '<leader>pw', function() require('persistence').save() end,               desc = '[P]roject [W]rite: guardar sesión ahora' },
      { '<leader>ps', function() require('persistence').load() end,               desc = '[P]roject [S]ession: restaurar sesión actual' },
      { '<leader>pl', function() require('persistence').load { last = true } end, desc = '[P]roject [L]ast: restaurar última sesión' },
      { '<leader>pq', function() require('persistence').stop() end,               desc = '[P]roject [Q]uit: salir sin guardar sesión' },
    },
  },

  -- Detecta raíces de proyecto y permite cambiar entre proyectos con Telescope
  {
    'ahmedkhalf/project.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('project_nvim').setup {
        detection_methods = { 'pattern', 'lsp' },
        patterns = { '.git', 'package.json', 'Cargo.toml', 'go.mod', 'pyproject.toml', '*.sln' },
        scope_chdir = 'global',
        silent_chdir = true,
        datapath = vim.fn.stdpath 'data',
      }

      require('telescope').load_extension 'projects'

      -- Tabline personalizada con nombres de proyecto
      vim.o.tabline = '%!v:lua.projects_tabline()'
      vim.o.showtabline = 2

      -- <leader>pp → picker de proyectos (historial dinámico)
      vim.keymap.set('n', '<leader>pp', '<cmd>Telescope projects<CR>', { desc = '[P]roject [P]icker' })

      -- <leader>1/2/3 → ir directo a cada proyecto en su propia tab
      for i, project in ipairs(projects) do
        vim.keymap.set('n', '<leader>' .. i, function()
          open_project_tab(project)
        end, { desc = 'Proyecto ' .. i .. ': ' .. project.name })
      end

      -- <leader>tn → nueva tab vacía
      vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>',   { desc = '[T]ab [N]ueva' })
      -- <leader>tc → cerrar tab actual
      vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = '[T]ab [C]errar' })
      -- <leader>tl → siguiente tab
      vim.keymap.set('n', '<leader>tl', '<cmd>tabnext<CR>',  { desc = '[T]ab [L]siguiente' })
      -- <leader>th → tab anterior
      vim.keymap.set('n', '<leader>th', '<cmd>tabprev<CR>',  { desc = '[T]ab [H]anterior' })
    end,
  },
}
