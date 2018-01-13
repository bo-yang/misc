#!/bin/sh

#
# Automatically install/setup MacVim and Vim plugins
#

# Install MacVim - manual work
if [ ! -d /Applications/MacVim.app/Contents/MacOS/ ]; then
  echo "Please download & install MacVim first, link https://github.com/macvim-dev/macvim/releases"
  exit 1
fi

# Add alias
bashrc=$HOME/.bashrc
echo "alias mvim='/Applications/MacVim.app/Contents/MacOS/MacVim'" >> $bashrc
echo "alias mvimdiff='/Applications/MacVim.app/Contents/MacOS/MacVim'" >> $bashrc
echo "alias gvim='/Applications/MacVim.app/Contents/MacOS/Vim -g'" >> $bashrc
echo "alias gvimdiff='/Applications/MacVim.app/Contents/MacOS/Vim -g'" >> $bashrc

# Download .vimrc
#TODO

# Install Pathogen, link https://github.com/tpope/vim-pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install Exuberant Ctags
brew install ctags
if [ -e /usr/local/bin/ctags ]; then
  echo "Error: failed to install Exuberant Ctags"
fi

vimbundle=$HOME/.vim/bundle
# Install Tagbar
git clone https://github.com/majutsushi/tagbar.git $vimbundle/tagbar

# Install NERDTree
git clone https://github.com/scrooloose/nerdtree.git $vimbundle/nerdtree

# Install SuperTab
git clone https://github.com/ervandew/supertab.git $vimbundle/supertab
