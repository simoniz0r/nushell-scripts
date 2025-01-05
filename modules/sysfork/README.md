`sysfork` manages nushell background processes using transient systemd services.  Background processes are ran as services are started using `systemd-run` with the `--remain-after-exit` flag so status can be viewed after the process is finished.

# Example Installation

Download to nushell config dir:

```
http get https://github.com/simoniz0r/nushell-scripts/raw/main/modules/sysfork/mod_sysfork.nu | save $"($nu.default-config-dir)/mod_sysfork.nu"
```

Add to env.nu:

```
'use $"($nu.default-config-dir)/mod_sysfork.nu" *' | save --append $"($nu.default-config-dir)/env.nu"
```

# Fork a Command or Script Into Background

```
Runs nushell command or script in background using 'systemd-run'

Usage:
  > sysfork {flags} ...(flags)

Subcommands:
  sysfork restart (custom) - Restarts given unit
  sysfork status (custom) - Shows runtime status of given unit
  sysfork stop (custom) - Stops given unit

Flags:
  -r, --run <string>: Command or script to run (required)
  -u, --unit <string>: Name to give systemd unit (default: sysfork_unixtime)
  -v, --verbose: Enable verbose output mode
  -h, --help: Display the help message for this command

Parameters:
  ...flags <any>: Any flags not listed above will be passed to 'systemd-run'
```

Example:

`sysfork --unit nutest --run ~/Public/test.nu`

```
────────────┬────────────────────────────────────────────────────────────────────────
 Unit       │ nutest.service
 ExecStart  │ /usr/bin/nu ~/Public/test.nu
 Loaded     │ loaded (/run/user/1000/systemd/transient/nutest.service; transient)
 Transient  │ yes
 Active     │ active (running) since Sun 2025-01-05 04:55:34 CST; 47ms ago
 Invocation │ 80cc1f9a902944e7b343b698e1567cc3
 Main PID   │ 1512887 (nu)
 Tasks      │ 1 (limit: 15655)
 CPU        │ 5ms
 CGroup     │ /user.slice/user-1000.slice/user@1000.service/app.slice/nutest.service
 Output     │ 1736074534
            │
────────────┴────────────────────────────────────────────────────────────────────────
```

# Restart a Unit

```
Restarts given unit

Usage:
  > sysfork restart {flags} ...(flags)

Flags:
  -u, --unit <string>: Name of unit to restart (required)
  -v, --verbose: Enable verbose output mode
  -h, --help: Display the help message for this command

Parameters:
  ...flags <any>: Any flags not listed above will be passed to 'systemctl'
```

Example:

`sysfork restart --unit nutest`

```
────────────┬────────────────────────────────────────────────────────────────────────
 Unit       │ nutest.service
 ExecStart  │ /usr/bin/nu ~/Public/test.nu
 Loaded     │ loaded (/run/user/1000/systemd/transient/nutest.service; transient)
 Transient  │ yes
 Active     │ active (running) since Sun 2025-01-05 05:01:42 CST; 14ms ago
 Invocation │ eaf124ee0ca944aba0d4dd7959322748
 Main PID   │ 1513284 ((nu))
 Tasks      │ 1 (limit: 15655)
 CPU        │ 5ms
 CGroup     │ /user.slice/user-1000.slice/user@1000.service/app.slice/nutest.service
 Output     │ 1736074902
            │
────────────┴────────────────────────────────────────────────────────────────────────
```

# Show Runtime Status

```
Shows runtime status of given unit

Usage:
  > sysfork status {flags} ...(flags)

Flags:
  -u, --unit <string>: Name of unit to show status of (required)
  -v, --verbose: Enable verbose output mode
  -h, --help: Display the help message for this command

Parameters:
  ...flags <any>: Any flags not listed above will be passed to 'systemctl'
```

Example:

`sysfork status --unit nutest`

```
────────────┬────────────────────────────────────────────────────────────────────────────────
 Unit       │ nutest.service
 ExecStart  │ /usr/bin/nu ~/Public/test.nu
 Loaded     │ loaded (/run/user/1000/systemd/transient/nutest.service; transient)
 Transient  │ yes
 Active     │ active (exited) since Sun 2025-01-05 05:01:42 CST; 3min 38s ago
 Invocation │ eaf124ee0ca944aba0d4dd7959322748
 Process    │ 1513284 ExecStart=/usr/bin/nu ~/Public/test.nu (code=exited, status=0/SUCCESS)
 Main PID   │ 1513284 (code=exited, status=0/SUCCESS)
 CPU        │ 26ms
 Output     │ 1736074902
            │ 1736074903
            │ 1736074904
            │ 1736074905
            │ 1736074906
            │
────────────┴────────────────────────────────────────────────────────────────────────────────
```

# Stop a Unit

```
Stops given unit

Usage:
  > sysfork stop {flags} ...(flags)

Flags:
  -u, --unit <string>: Name of unit to stop (required)
  -h, --help: Display the help message for this command

Parameters:
  ...flags <any>: Any flags not listed above will be passed to 'systemctl'
```

Example:

`sysfork stop --unit nutest`

```
───────────┬─────────────────
           │ ───────────┬───
 Systemctl │  stdout    │
           │  stderr    │
           │  exit_code │ 0
           │ ───────────┴───
───────────┴─────────────────
```
