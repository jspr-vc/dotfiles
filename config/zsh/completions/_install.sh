#compdef install.sh
# Steps come from the STEPS=(...) line of the script being completed, so a new
# step completes without touching this file. Any other install.sh falls back
# to plain file completion.

local script=${~words[1]}
local -a steps
[[ -r $script ]] && steps=(${=${${(M)${(f)"$(<$script)"}:#STEPS=\(*}#STEPS=\(}%\)})
(( $#steps )) || { _default; return }

_arguments \
    '*--only[run only this step]:step:($steps)' \
    '*--skip[skip this step]:step:($steps)' \
    '(- *)'{-h,--help}'[list the steps]'
