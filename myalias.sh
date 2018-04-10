# Aliases defined in $HOME/.bashrc

#Linux
alias lf='ls -pa --color=auto'
alias ll='ls -l --color=auto'
alias save_terms='gnome-terminal --save-config=$HOME/gnome_tabs'
alias load_terms='gnome-terminal --load-config=$HOME/gnome_tabs'

#macOS
alias lf='ls -aG'
alias ll='ls -lG'
alias mvim='/Applications/MacVim.app/Contents/MacOS/MacVim'
alias mvimdiff='/Applications/MacVim.app/Contents/MacOS/MacVim'
alias gvim='/Applications/MacVim.app/Contents/MacOS/Vim -g'
alias gvimdiff='/Applications/MacVim.app/Contents/MacOS/Vim -g'

#Git
alias git_add_gerrit='git remote add gerrit ssh://$LOGNAME@<server>:29418/<name>'
alias git_clone_router='git clone -b master-cisco ssh://$LOGNAME@<server>:29418/<name>'
alias git_pull_rebase='git pull --rebase origin $(git rev-parse --abbrev-ref HEAD)'
alias git_push='git pull --rebase; git push origin HEAD:refs/for/$(git rev-parse --abbrev-ref HEAD)'
alias git_push_master='git push gerrit HEAD:refs/for/<branch>'
alias git_submod_add='git remote add rw ssh://$LOGNAME@<server>:29418/${PWD##*router/}'
alias git_submod_init='git submodule update --init'
alias git_submod_push='git push rw HEAD:refs/for/$(git rev-parse --abbrev-ref HEAD)'
alias git_submod_push_master='git push rw HEAD:refs/for/master'
