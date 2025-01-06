pastery uploads stdin to [pastery.net](https://pastery.net)

# Example Installation

Download to nushell config dir:

```
http get https://github.com/simoniz0r/nushell-scripts/raw/main/modules/pastery/mod_pastery.nu | save $"($nu.default-config-dir)/mod_pastery.nu"
```

Add to env.nu:

```
'use $"($nu.default-config-dir)/mod_pastery.nu" *' | prepend '' | save --append $"($nu.default-config-dir)/env.nu"
```

# Basic Usage

```
Uploads stdin to pastery.net

Usage:
  > pastery {flags}

Flags:
  -d, --duration <int>: Duration in minutes paste will live for; 43200 max (default: 43200)
  -l, --language <string>: Language for syntax highlighting (default: 'autodetect')
  -m, --max-views <int>: Number of views allowed before paste expires; 0 disables (default: 0)
  -t, --title <string>: Title for paste (default: '')
  -v, --verbose: Enable verbose output mode
  -h, --help: Display the help message for this command
```

Example:

`open ~/git/nushell-scripts/modules/pastery/mod_pastery.nu | pastery --title mod_pastery.nu`

```
──────────┬─────────────────────────────────
 id       │ nmcxxx
 title    │ mod_pastery.nu
 url      │ https://www.pastery.net/nmcxxx/
 language │ gdscript
 duration │ 43199
──────────┴─────────────────────────────────
```
