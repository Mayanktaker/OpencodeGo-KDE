# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Zsh tab completion script for opencode-usage CLI tool

#compdef opencode-usage

_opencode_usage() {
    _arguments -s \
        '(-w --workspace-id)'{-w,--workspace-id}'[OpenCode Workspace ID]:workspace_id:' \
        '(-c --cookie)'{-c,--cookie}'[OpenCode Auth Cookie]:auth_cookie:' \
        '(-j --json)'{-j,--json}'[Output raw JSON format]' \
        '(-d --demo)'{-d,--demo}'[Force demo mock data mode]' \
        '(-h --help)'{-h,--help}'[Show help options]'
}

_opencode_usage "$@"
