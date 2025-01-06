# Name: pastery
# Author: Syretia
# License: MIT
# Dependencies: nushell
# Description: Uploads stdin to pastery.net

# Uploads stdin to pastery.net
export def pastery [
    --duration (-d):int = 43200 # Duration in minutes paste will live for; 43200 max
    --language (-l):string = "autodetect" # Language for syntax highlighting
    --max-views (-m):int = 0 # Number of views allowed before paste expires; 0 disables
    --title (-t):string # Title for paste
    --verbose (-v) # Enable verbose output mode
]: any -> record {
    # set title to nothing if null
    let title = $title | default ""
    # convert stdin into binary
    let file = $in
    # return if $file is null
    if $file == null { return ("Missing input from stdin" | wrap error) }
    # create url query string from flags
    let query = try {
        $language | wrap language
        | merge ($title | wrap title)
        | merge ($duration | wrap duration)
        | merge ($max_views | wrap max_views)
        | url build-query
    } catch {
        |e| return ($e.json | from json | wrap error)
    }
    # post paste data
    let pastepost = try {
        # enable full http output if verbose output mode
        if $verbose == true {
            http post -f -H [content-type mulipart/form-data] $"https://www.pastery.net/api/paste/?($query)" $file
        # else just use normal http output
        } else {
            http post -H [content-type mulipart/form-data] $"https://www.pastery.net/api/paste/?($query)" $file
        }
    } catch {
        |e| return ($e.json | from json | wrap error)
    }
    # return result
    return $pastepost
}
