# Quicklook.yazi

This is a plugin to preview your files with QuickLook in Yazi.

## Installation

This plugin only works with macOS.

You can install it with this command:

```bash
ya pkg add sunruisjtu2020/quicklook
```

## Usage

Add a keybinding to your `~/.config/yazi/keymaps.toml`:

```toml
[[mgr.prepend_keymap]]
on    = "I"          # Press 'I' in manager view
run   = "plugin quicklook"  # Run quicklook plugin
desc  = "QuickLook Preview"
block = false
```

You can press `I` in the manager view to preview the selected file with QuickLook.

You can change to your favorite keybinding.

To enable notification, add this to `~/.config/yazi/init.lua`:

```lua
require("quicklook"):setup({
  showPreviewNotification = true,
})
```
