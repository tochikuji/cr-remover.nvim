# cr-remover.nvim

## Description

A neovim plugin that automatically removes unneccesary <CR> (viz. ^M in the EOL) that appear when copying text from host windows environment to neovim on WSL.

## Installation

with Lazy.nvim

```lua
{
    "tochikuji/cr-remover.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        exclude_patterns = { "%.git/" },
        auto_remove_on_save = true,
        auto_remove_on_paste = true,
        debug = true
    }
}
```

## License

MIT

## Author

Aiga SUZUKI (<ai-suzuki@neocognition.dev>)
