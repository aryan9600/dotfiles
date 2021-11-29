call plug#begin('~/.config/nvim')

" Plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'morhetz/gruvbox'
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vim-syntastic/syntastic'
Plug 'frazrepo/vim-rainbow'
Plug 'jiangmiao/auto-pairs'
Plug 'vim-python/python-syntax'
Plug 'APZelos/blamer.nvim'
Plug 'cespare/vim-toml'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'psf/black', { 'branch': 'stable' }
call plug#end()

" Gruvbox settings here
let g:gruvbox_contrast_dark = "soft"
autocmd vimenter * colorscheme gruvbox
let g:rainbow_active = 1

au TermOpen * setlocal nonumber norelativenumber
" -------------------------------------------------------------------------------------------------
" coc.nvim settings
" -------------------------------------------------------------------------------------------------
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

"disable vim-go gopls
let g:go_gopls_enabled = 0
" disable vim-go :GoDef
let g:go_def_mapping_enabled = 0
" disable annoying af warning
let g:go_version_warning = 0
" Syntax highlighting for go
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_variable_assignments = 1

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

command! -nargs=0 Prettier :CocCommand prettier.formatFile
let g:python_highlight_all = 1
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gt :call CocActionAsync('doQuickfix')<cr>

" Use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>

" Remap for rename current word
nmap <leader>gn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>fo  <Plug>(coc-format-selected)
nmap <leader>fo  <Plug>(coc-format-selected)
" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
nnoremap <silent> gf :GoDeclsDir<cr>

" nvim settings
let mapleader = " "
syntax on

" if hidden is not set, TextEdit might fail
set hidden
" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" copy stuff that I yank and cut to system clipboard
noremap y "*y
noremap yy "*yy
noremap Y "*y$
noremap x "*x
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set wrap
set smartcase
set noswapfile
set nobackup
set incsearch
set autoindent
set autoread
set nobackup
set nowritebackup
set background=dark

" Some optimization stuff, use only if required
" set lazyredraw
"set synmaxcol=128
"syntax sync minlines=64
"set timeoutlen=1000
"set ttimeoutlen=0

tnoremap <Esc> <C-\><C-n>
" tab mappings
nmap <silent> ti :tabr<cr>
nmap <silent> tl :tabl<cr>
nmap <silent> tp :tabp<cr>
nmap <silent> tn :tabn<cr>
" Switch to last-active tab
if !exists('g:lasttab')
  let g:lasttab = 1
endif
nmap <silent>to :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
" keybinding to unhighlight
nmap <silent> cc :noh<cr>
"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Lets me bulk comment using '<Leader>[space]'
let s:comment_map = {
    \   "yml": '#',
    \   "yaml": '#',
    \   "c": '\/\/',
    \   "cpp": '\/\/',
    \   "go": '\/\/',
    \   "java": '\/\/',
    \   "javascript": '\/\/',
    \   "lua": '--',
    \   "scala": '\/\/',
    \   "php": '\/\/',
    \   "proto": '\/\/',
    \   "python": '#',
    \   "ruby": '#',
    \   "rust": '\/\/',
    \   "sh": '#',
    \   "desktop": '#',
    \   "fstab": '#',
    \   "conf": '#',
    \   "profile": '#',
    \   "bashrc": '#',
    \   "bash_profile": '#',
    \   "mail": '>',
    \   "eml": '>',
    \   "bat": 'REM',
    \   "ahk": ';',
    \   "vim": '"',
    \   "tex": '%',
    \   "trickle": '#',
    \   "toml": '#',
    \ }

function! ToggleComment()
    if has_key(s:comment_map, &filetype)
        let comment_leader = s:comment_map[&filetype]
        if getline('.') =~ "^\\s*" . comment_leader . " "
            " Uncomment the line
            execute "silent s/^\\(\\s*\\)" . comment_leader . " /\\1/"
        else
            if getline('.') =~ "^\\s*" . comment_leader
                " Uncomment the line
                execute "silent s/^\\(\\s*\\)" . comment_leader . "/\\1/"
            else
                " Comment the line
                execute "silent s/^\\(\\s*\\)/\\1" . comment_leader . " /"
            end
        end
    else
        echo "No comment leader found for filetype"
    end
endfunction

nnoremap <Leader><Space> :call ToggleComment()<cr>
vnoremap <Leader><Space> :call ToggleComment()<cr>

nnoremap <silent> q :<C-u>NERDTreeToggle<CR>

autocmd BufNewFile,BufRead Dockerfile* set syntax=dockerfile
autocmd StdinReadPre * let s:std_in=1

nnoremap <silent> <Leader>c  :Commits<CR>
nnoremap <silent> <Leader>bc :BCommits<CR>
let g:blamer_enabled = 1
let g:blamer_delay = 500
let g:blamer_show_in_visual_modes = 0

" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --glob "!*.pyc" --glob "!vendor/*" --glob "!target/*" --glob "!.idea/*" --glob "!*.log" --color "always" '.shellescape(<q-args>), 1, <bang>0)

" fzf mappings
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <C-a> :Rg<CR>
set rtp+=/usr/local/opt/fzf
let g:fzf_action = {
  \ 'enter': 'tab drop',
  \ 'ctrl-t': 'tabedit',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
let g:airline#extensions#tabline#enabled = 1
let g:airline_section_x = 0
let g:airline_section_y = 0
let g:airline#extensions#virtualenv#enabled = 1
" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
set t_Co=256
