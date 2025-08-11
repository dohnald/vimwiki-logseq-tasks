function! ToggleLogseqTasks() range
  " Get task states from user configuration or use default
  let task_states = get(g:, 'vimwiki_logseq_task_states', ['TODO', 'DOING', 'DONE'])
  
  " Validate task_states (must be 2-5 items)
  if len(task_states) < 2 || len(task_states) > 5
    echom "vimwiki_logseq_task_states must contain 2-5 items. Using default."
    let task_states = ['TODO', 'DOING', 'DONE']
  endif

  " Process each line in the range
  for line_num in range(a:firstline, a:lastline)
    let line = getline(line_num)
    
    " Regex to find a list marker, e.g. '  - ', '1. ', 'a. '
    let list_marker_pattern = '^\v(\s*([-*#]+|(\d+|[a-zA-Z])\.)\s+)'
    let list_marker = matchstr(line, list_marker_pattern)

    " If it's not a list item, just prepend task states.
    " This could be useful for titles or paragraphs that are tasks.
    if empty(list_marker)
      let new_content = s:GetNextTaskState(line, task_states)
      call setline(line_num, new_content)
      continue
    endif

    " It is a list item. We operate on the content part.
    let content = substitute(line, list_marker_pattern, '', '')
    let new_content = s:GetNextTaskState(content, task_states)

    " Reconstruct the line and set it.
    call setline(line_num, list_marker . new_content)
  endfor
endfunction

function! s:GetNextTaskState(content, task_states)
  " Find current state index
  let current_state_index = -1
  for i in range(len(a:task_states))
    if a:content =~# '^' . a:task_states[i] . '\>'
      let current_state_index = i
      break
    endif
  endfor

  if current_state_index == -1
    " No current state found, add first state
    return a:task_states[0] . ' ' . a:content
  elseif current_state_index == len(a:task_states) - 1
    " Last state, remove it (cycle back to no state)
    return substitute(a:content, '^' . a:task_states[current_state_index] . '\s*', '', '')
  else
    " Move to next state
    let next_state = a:task_states[current_state_index + 1]
    return substitute(a:content, '^' . a:task_states[current_state_index], next_state, '')
  endif
endfunction

function! s:Hook() abort
  if exists('b:did_my_ftplugin')
    return
  endif
  let b:did_my_ftplugin = 1

  inoremap <buffer> <C-Space> <Esc>:call ToggleLogseqTasks()<CR>a
  nnoremap <buffer> <C-Space> :call ToggleLogseqTasks()<CR>
  vnoremap <buffer> <C-Space> :call ToggleLogseqTasks()<CR>
endfunction

augroup MyFtpluginHook
  autocmd!
  autocmd FileType vimwiki call s:Hook()
augroup END