PROMPT='%(!.%{$fg[red]%}.%{$fg[green]%})%~$(_git_info)%{$reset_color%} '

SYMBOL_GIT_BRANCH='⑂'
SYMBOL_GIT_MODIFIED='*'
SYMBOL_GIT_PUSH='↑'
SYMBOL_GIT_PULL='↓'

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[blue]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[blue]%})"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔"


function _git_info {
    hash git 2>/dev/null || return  # git not found

    # get current branch
    local ref=$(git symbolic-ref --short HEAD 2>/dev/null)

    if [[ -n "$ref" ]]; then
        # prepend branch symbol
        ref=$SYMBOL_GIT_BRANCH$ref
    else
        # get most recent tag or abbreviated unique hash
        ref=$(git describe --tags --always 2>/dev/null)
    fi

    [[ -n "$ref" ]] || return   # not a git repo

    local marks

    # scan first two lines of output from `git status`
    while IFS= read -r line; do
        if [[ $line =~ ^## ]]; then # header line
            [[ $line =~ ahead\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PUSH$match[1]"
            [[ $line =~ behind\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PULL$match[1]"
        else # branch is modified if output contains more lines after the header line
            marks="$SYMBOL_GIT_MODIFIED$marks"
            break
        fi
    done < <(git status --porcelain --branch 2>/dev/null)  # note the space between the two <

    # print without a trailing newline
    printf " [$ref$marks]"
}

