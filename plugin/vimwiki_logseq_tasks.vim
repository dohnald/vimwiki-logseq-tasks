function! ToggleLogseqTasks()
  let line = getline('.')

  " Regex to find a list marker, e.g. '  - ', '1. ', 'a. '
  let list_marker_pattern = '^\v(\s*([-*#]+|(\d+|[a-zA-Z])\.)\s+)'
  let list_marker = matchstr(line, list_marker_pattern)

  " If it's not a list item, just prepend TODO.
  " This could be useful for titles or paragraphs that are tasks.
  if empty(list_marker)
    if line =~# '^TODO'
      call setline('.', substitute(line, '^TODO', 'DOING', ''))
    elseif line =~# '^DOING'
      call setline('.', substitute(line, '^DOING', 'DONE', ''))
    elseif line =~# '^DONE'
      call setline('.', substitute(line, '^DONE\s*', '', ''))
    else
      call setline('.', 'TODO ' . line)
    endif
    return
  endif

  " It is a list item. We operate on the content part.
  let content = substitute(line, list_marker_pattern, '', '')

  if content =~# '^TODO'
    let new_content = substitute(content, '^TODO', 'DOING', '')
  elseif content =~# '^DOING'
    let new_content = substitute(content, '^DOING', 'DONE', '')
  elseif content =~# '^DONE'
    let new_content = substitute(content, '^DONE\s*', '', '')
  else
    let new_content = 'TODO ' . content
  endif

  " Reconstruct the line and set it.
  call setline('.', list_marker . new_content)
endfunction

function! s:Hook() abort
  if exists('b:did_my_ftplugin')
    return
  endif
  let b:did_my_ftplugin = 1

  inoremap <buffer> <C-Space> <Esc>:call ToggleLogseqTasks()<CR>a
  nnoremap <buffer> <C-Space> :call ToggleLogseqTasks()<CR>
endfunction

augroup MyFtpluginHook
  autocmd!
  autocmd FileType vimwiki call s:Hook()
augroup END