# Languages

Every file in this folder is one language. They are plain text — open them in any
editor and change them.

## Switching language

Set the code in `shared/config.lua`:

```lua
Config.Language = "fr"
```

The code is the file name without `.lua`. Included: `ar`, `bg`, `cs`, `de`, `en`,
`es-ES`, `fr`, `hu`, `id`, `it`, `nl`, `pt-BR`, `ro-RO`, `zh-CN`, `zh-TW`.

## Adding your own language

1. Copy `en.lua` and rename the copy to your language code, e.g. `tr.lua`.
2. Open it and change the first line from `Locales["en"] = {` to `Locales["tr"] = {`.
3. Translate the text on the right of each `=`. Leave the names on the left alone.
4. Set `Config.Language = "tr"` in `shared/config.lua` and restart the resource.

The file is picked up automatically — there is nothing to register anywhere else.

Anything you don't translate falls back to English, so you can ship a half-finished
file and keep going later.

### Things to keep

- `%s` is a placeholder the script fills in (a name, a price, a number). Keep every
  `%s` in a line, in the same order.
- Keep the quotes and the commas. If the game logs a syntax error for your file,
  it is almost always a missing `"` or `,`.
- If your language uses non-Latin characters, save the file as UTF-8.
