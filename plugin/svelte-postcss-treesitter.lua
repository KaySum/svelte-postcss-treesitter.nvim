-- svelte-postcss-treesitter.nvim
--
-- Deterministically override nvim-treesitter's bundled svelte `injections`
-- query so `<style lang="postcss">` blocks are parsed by the `css` grammar
-- (which handles Tailwind's `@apply`) instead of `scss`.
--
-- We read the bundled queries/svelte/injections.scm and register it with
-- `vim.treesitter.query.set()`. An explicitly-set query always wins over
-- file-based resolution, so this works no matter where this plugin lands in
-- the runtimepath relative to nvim-treesitter.

if vim.g.loaded_svelte_postcss_treesitter then
  return
end
vim.g.loaded_svelte_postcss_treesitter = true

-- Resolve the bundled query file relative to this script, not via runtime
-- lookup (which could return nvim-treesitter's copy instead of ours).
local source = debug.getinfo(1, "S").source:sub(2)
local plugin_root = vim.fn.fnamemodify(source, ":h:h")
local query_file = plugin_root .. "/queries/svelte/injections.scm"

local fd = io.open(query_file, "r")
if not fd then
  return
end
local query_text = fd:read("*a")
fd:close()

pcall(vim.treesitter.query.set, "svelte", "injections", query_text)
