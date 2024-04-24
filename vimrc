set nocompatible

set number tabstop=2 shiftwidth=2 expandtab ignorecase ruler autoindent
set wildmenu showcmd laststatus=2 smartcase encoding=utf-8 textwidth=120 smartindent
" mouse=a

" turn on 256 color support
set t_Co=256

filetype indent plugin on
syntax on

" ensure dockerfiles are recognized
au BufReadPost Dockerfile* set syntax=dockerfile
au BufReadPost *Dockerfile set syntax=dockerfile

" macros to keep
let @q='/\$[^{(0-9*#]a{ea}'
"q   /\$[^({0-9#]^Ma{^[ea}^[

"folding settings  
" zc folds at the current place
" zM folds everything
" zR unfolds everything
" za toggle folding
set foldmethod=indent foldnestmax=10 foldlevel=2 nofoldenable


highlight MatchParen cterm=bold ctermbg=white ctermfg=red

