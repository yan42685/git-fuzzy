#!/usr/bin/env bash
# shellcheck disable=2016

GIT_FUZZY_STATUS_ADD_KEY="${GIT_FUZZY_STATUS_ADD_KEY:-Alt-S}"
GIT_FUZZY_STATUS_EDIT_KEY="${GIT_FUZZY_STATUS_EDIT_KEY:-Alt-V}"
GIT_FUZZY_STATUS_COMMIT_KEY="${GIT_FUZZY_STATUS_COMMIT_KEY:-Alt-C}"
GIT_FUZZY_STATUS_RESET_KEY="${GIT_FUZZY_STATUS_RESET_KEY:-Alt-U}"
GIT_FUZZY_STATUS_DISCARD_KEY="${GIT_FUZZY_STATUS_DISCARD_KEY:-Alt-O}"

GF_STATUS_HEADER='   '"   ${GREEN}all ☑${NORMAL}  ${WHITE}Ctrl-A${NORMAL}      ${GREEN}stage ${BOLD}⇡${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_ADD_KEY${NORMAL}      * ${GREEN}${BOLD}edit ✎${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_EDIT_KEY${NORMAL}"'
  '"${RED}${BOLD}discard ✗${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_DISCARD_KEY${NORMAL}     ${GREEN}unstage ${RED}${BOLD}⇣${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_RESET_KEY${NORMAL}    * ${RED}${BOLD}commit ${NORMAL}${RED}⇧${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_COMMIT_KEY${NORMAL}"'
'

gf_fzf_status() {
  RELOAD="reload:git fuzzy helper status_menu_content"
  # doesn't work

  gf_fzf -m --header "$GF_STATUS_HEADER" \
            --header-lines=2 \
            --expect="$GIT_FUZZY_STATUS_EDIT_KEY,$GIT_FUZZY_STATUS_COMMIT_KEY" \
            --nth=2 \
            --preview 'git fuzzy helper status_preview_content {1} {2..}' \
            --bind "$GIT_FUZZY_STATUS_ADD_KEY:execute-silent(git fuzzy helper status_add {+2..})+down+$RELOAD" \
            --bind "$GIT_FUZZY_STATUS_RESET_KEY:execute-silent(git fuzzy helper status_reset {+2..})+down+$RELOAD" \
            --bind "$GIT_FUZZY_STATUS_DISCARD_KEY:execute-silent(git fuzzy helper status_discard {2..})+$RELOAD"
}

gf_status_interpreter() {
  CONTENT="$(cat -)"
  HEAD="$(echo "$CONTENT" | head -n1)"
  TAIL="$(echo "$CONTENT" | tail -n +2)"
  if [ "$HEAD" = "$GIT_FUZZY_STATUS_EDIT_KEY" ]; then
    eval "git fuzzy helper status_edit $(echo "$TAIL" | cut -c4- | join_lines_quoted)"
  elif [ "$HEAD" = "$GIT_FUZZY_STATUS_COMMIT_KEY" ]; then
    eval "git fuzzy helper status_commit"
  else
    echo "$TAIL" | cut -c4-
  fi
}

gf_status() {
  gf_snapshot "status"
  if [ -n "$(git status -s)" ]; then
    # shellcheck disable=2086
    git fuzzy helper status_menu_content | gf_fzf_status | gf_status_interpreter
  else
    gf_log_debug "nothing to commit, working tree clean"
    exit 1
  fi
}
