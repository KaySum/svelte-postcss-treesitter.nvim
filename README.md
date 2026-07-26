# svelte-postcss-treesitter.nvim

Treesitter injection override so Svelte `<style lang="postcss">` blocks highlight
cleanly with Tailwind's `@apply`.

## The problem

nvim-treesitter's bundled Svelte injections query routes `<style lang="postcss">`
blocks to the **scss** grammar. The scss grammar can't parse Tailwind's `@apply`
directive — it produces `ERROR` nodes, which gives inconsistent, broken-looking
highlighting:

```svelte
<style lang="postcss">
  .btn {
    @apply px-4 py-2 rounded bg-blue-500;  /* ERROR nodes under scss */
  }
</style>
```

## The fix

This plugin overrides that one query so `lang="postcss"` blocks are parsed by the
plain **css** grammar instead. The css grammar parses `@apply` cleanly as a
`postcss_statement`, with each utility class as a uniform `plain_value` — so the
whole block highlights consistently.

`scss`/`less` blocks still go to scss, and `ts`/`js` script blocks are unchanged;
only the `postcss` route is redirected.

## Requirements

- Neovim 0.9+ (uses `vim.treesitter.query.set`)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- The `svelte`, `css`, `scss`, `typescript`, and `javascript` parsers:
  ```
  :TSInstall svelte css scss typescript javascript
  ```

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "KaySum/svelte-postcss-treesitter.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = "svelte",
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "KaySum/svelte-postcss-treesitter.nvim",
  requires = { "nvim-treesitter/nvim-treesitter" },
}
```

No `setup()` call needed — the override registers itself on load.

## How it works

The bundled `queries/svelte/injections.scm` is a full copy of the upstream Svelte
injections query with the `postcss` branch pointed at `css`. Rather than relying
on runtimepath ordering to shadow nvim-treesitter's copy (which isn't guaranteed),
`plugin/svelte-postcss-treesitter.lua` reads the bundled file and registers it via
`vim.treesitter.query.set()`. An explicitly-set query always wins over file-based
resolution, so the override is deterministic.

## License

MIT
