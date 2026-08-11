# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Bash tab completion script for opencode-usage CLI tool

_opencode_usage_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--workspace-id --cookie --json --demo --help"

    case "${prev}" in
        --workspace-id|-w)
            return 0
            ;;
        --cookie|-c)
            return 0
            ;;
    esac

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

complete -F _opencode_usage_completion opencode-usage
