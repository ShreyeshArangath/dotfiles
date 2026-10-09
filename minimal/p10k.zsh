# Small Powerlevel10k prompt: directory, Git status, and command result.
typeset -g POWERLEVEL9K_MODE=nerdfont-v3
typeset -ga POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs prompt_char)
typeset -ga POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs)
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
