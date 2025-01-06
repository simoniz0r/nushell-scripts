# Name: sysfork
# Author: Syretia
# License: MIT
# Dependencies: nushell, systemd
# Description: runs nushell commands or scripts in background using 'systemd-run'

# Restarts given unit
export def --wrapped "sysfork restart" [
    ...flags # Any flags not listed above will be passed to 'systemctl'
    --unit (-u):string # Name of unit to restart (required)
    --verbose (-v) # Enable verbose output mode
    --help (-h) # Display the help message for this command
]: nothing -> record {
    # return if no unit input
    if $unit == null { return ("Missing unit input" | wrap Error) }
    # check if systemctl is found
    if (which systemctl | is-empty) { return ("Failed to find 'systemctl' in PATH" | wrap Error) }
    # restart given unit
    let status = systemctl restart --user ...$flags ($unit) | complete
    if $status.exit_code != 0 {
        return ($status | wrap Systemctl)
    }
    # if verbose mode return status of unit with verbose flag
    if $verbose == true {
        return (sysfork status --unit $unit --verbose)
    # else just get status of unit
    } else {
        return (sysfork status --unit $unit)
    }
}

# Shows runtime status of given unit
export def --wrapped "sysfork status" [
    ...flags # Any flags not listed above will be passed to 'systemctl'
    --unit (-u):string # Name of unit to show status of (required)
    --verbose (-v) # Enable verbose output mode
    --help (-h) # Display the help message for this command
]: nothing -> record {
    # return if no unit input
    if $unit == null { return ("Missing unit input" | wrap Error) }
    # check if systemctl is found
    if (which systemctl | is-empty) { return ("Failed to find 'systemctl' in PATH" | wrap Error) }
    # get status of given unit
    let status = systemctl status --user --lines=0 ...$flags ($unit) | complete
    # parse systemctl output into record if exit not 4
    if $status.exit_code != 4 {
        let output = try {
            $status.stdout
            | str replace '● ' 'Unit: '
            | str replace " - " "\nExecStart: "
            | lines
            | take until { |r| $r =~ '└─[0-9]+' }
            | str trim -l
            | split column -n 2 ': ' name value
            | group-by name
            | items { |name, value| $value | get 0.value? | wrap $name }
            | into record
        } catch {
            $status | wrap Systemctl
        }
        # get journalctl output of given unit for current invocation
        let invocation = try { $output.Invocation } catch { |e| return ("Failed to find Invocation ID for unit" | wrap Error) }
        let journal = journalctl --user-unit=($unit) --output=cat _SYSTEMD_INVOCATION_ID=($invocation) | complete
        # if verbose mode add journalctl and systemctl results to output
        if $verbose == true {
            return ($output| merge ($journal.stdout | wrap Output) |  merge ($journal | wrap Journalctl) | merge ($status | wrap Systemctl))
        # else just output parsed results
        } else {
            return ($output| merge ($journal.stdout | wrap Output))
        }
    # else get last 20 lines from journalctl and output systemctl without parsing
    } else {
        # if verbose mode get journalctl output of given unit
        if $verbose == true {
            let journal = journalctl --user-unit=($unit) --output=cat --lines=20 | complete
            return ($journal | wrap Journalctl | merge ($status | wrap Systemctl))
        # else just output systemctl result
        } else {
            return ($status | wrap Systemctl)
        }
    }
}

# Stops given unit
export def --wrapped "sysfork stop" [
    ...flags # Any flags not listed above will be passed to 'systemctl'
    --unit (-u):string # Name of unit to stop (required)
    --help (-h) # Display the help message for this command
]: nothing -> record {
    # return if no unit input
    if $unit == null { return ("Missing unit input" | wrap Error) }
    # check if systemctl is found
    if (which systemctl | is-empty) { return ("Failed to find 'systemctl' in PATH" | wrap Error) }
    # stop given unit
    let status = systemctl stop --user ...$flags ($unit) | complete
    return ($status | wrap Systemctl)
}

# Manages nushell background processes using transient systemd services
#
# Runs nushell command or script in background using 'systemd-run'
export def --wrapped sysfork [
    ...flags # Any flags not listed above will be passed to 'systemd-run'
    --run (-r):string # Command or script to run (required)
    --unit (-u):string # Name to give systemd unit (default: sysfork_unixtime)
    --verbose (-v) # Enable verbose output mode
    --help (-h) # Display the help message for this command
]: nothing -> record {
    # check if systemd-run is found
    if (which systemd-run | is-empty) { return ("Failed to find 'systemd-run' in PATH" | wrap Error) }
    # get nushell path
    let nupath = try { $nu.current-exe } catch { return ("Failed to find 'nu' binary" | wrap Error) }
    # set unit to nu_unixtime if no unit input
    let unit = if $unit == null {
        try { date now | format date "%s" | prepend "sysfork" | str join "_" } catch { |e| return ($e.msg | wrap Error) }
    } else {
        $unit
    }
    # run script in background
    if $run != null and ($run | path type) == "file" {
        let sysrun = systemd-run --user --remain-after-exit --unit=($unit) --same-dir ...$flags ($nupath) ($run) | complete
        # return if exit not 0
        if $sysrun.exit_code != 0 {
            return ($sysrun | wrap Systemctl)
        }
    # run command in background
    } else if $run != null {
        let sysrun = systemd-run --user --remain-after-exit --unit=($unit) --same-dir ...$flags ($nupath) -c ($run) | complete
        # return if exit not 0
        if $sysrun.exit_code != 0 {
            return ($sysrun | wrap Systemctl)
        }
    # return error if no command or script input
    } else {
        return ("Missing command or script to run" | wrap Error)
    }
    # if verbose mode return status of unit with verbose flag
    if $verbose == true {
        return (sysfork status --unit $unit --verbose)
    # else just get status of unit
    } else {
        return (sysfork status --unit $unit)
    }
}
