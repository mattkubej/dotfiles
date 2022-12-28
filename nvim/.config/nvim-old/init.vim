let mapleader = "\<Space>"

" personal configuration
lua require('mk')

" ========================================
" --> Remove trailing whitespace on save
" ========================================
augroup TRIM_WS
  autocmd!
  autocmd BufWritePre * %s/\s\+$//e
augroup END
