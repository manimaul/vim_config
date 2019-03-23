#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

install_plugin() {
  plugin_repo=$1
  plugin_dir=$2
  if [[ ! -d $plugin_dir ]]; then
    echo "installing $1"
    git clone --depth=1 $plugin_repo $plugin_dir
  fi
}

install_plugins() {
  if [[ ! -d ~/.vim/autoload ]]; then
    echo "installing pathogen"
    mkdir -p ~/.vim/autoload ~/.vim/bundle 
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
  fi

  install_plugin https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
  install_plugin https://github.com/rust-lang/rust.vim.git ~/.vim/bundle/rust.vim
  install_plugin https://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive.vim
  install_plugin git://github.com/airblade/vim-gitgutter.git ~/.vim/bundle/vim-gitgutter.vim
  install_plugin https://tpope.io/vim/surround.git ~/.vim/bundle/surround

  # todo: syntastic https://github.com/vim-syntastic/syntastic
  # todo: nerdtree   https://github.com/vim-syntastic/syntastic
}

install_ycm() {
  echo "installing ycm"
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "installing vim-gtk3 for vim+python3"
    sudo apt-get install vim-gtk3
  fi
  if [[ "$OSTYPE" == darwin* ]]; then
    echo "installing cmake"
    brew install cmake 
  fi
  git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/ycm.vim
  pushd ~/.vim/bundle/ycm.vim/
  git submodule update --init --recursive
  python3 install.py --go-completer --rust-completer --clang-completer
  popd
}

colors() {
  echo "installing hybrid colors"
  mkdir -p ~/.vim/colors
  cp $DIR/colors/hybrid.vim ~/.vim/colors/hybrid.vim
}

simlink() {
	echo "symlinking .vimrc"
	vimrc="$HOME/.vimrc"
	if [[ -e "$vimrc" || -L "$vimrc" ]]; then
	    if [ ! -L "$vimrc" ];  then
		echo "backing up ~/.vimrc"
		# not a symlink
		cp $HOME/.vimrc $/HOME.vimrc.bak
	    fi
	echo "deleting the ~/.vimrc"
	rm $HOME/.vimrc
	fi

  if [[ -e "$HOME/.ideavimrc" || -L "$HOME/.ideavimrc" ]]; then
    echo "backing up ~/.ideavimrc"
    cp $HOME/.ideavimrc $HOME/ideavimrc.bak
    rm $HOME/.ideavimrc
  fi

	ln -s $DIR/vimrc $HOME/.vimrc
	ln -s $DIR/ideavimrc $HOME/.ideavimrc
}

usage() {
	echo "link|colors|all|ycm|plugins|help"
}

case $1 in
"link")
  simlink
;;
"colors")
  colors
;;
"ycm")
  install_ycm
;;
"plugins")
  install_plugins
;;
"all")
  install_plugins
  install_ycm
  simlink
  colors
;;
*)
  usage
;;
esac

