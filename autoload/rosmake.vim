scriptencoding utf-8

let s:rosmake_errorformat = ','
      \ . '%+G[ rosmake ] Built %.%#,'
      \ . '%I[ rosmake ] %m output to directory %.%#,'
      \ . '%Z[ rosmake ] %f %.%#,'

fun! rosmake#make(type,filename) abort
  if !executable(a:type)
    echohl WarningMsg
    echomsg "Command '".a:type."' is not executable. Please source setup.bash/sh/zsh first."
    echohl none
    return
  endif

  try
    let l:package_dir = rosmake#find_project_dir(a:filename)
  catch
    echoerr v:exception
    return
  endtry

  try
    let l:command = rosmake#get_make_command(a:type)
  catch
    echoerr v:exception
    return
  endtry

  call rosmake#run_command_in_the_dir(l:package_dir,[l:command])
endf

fun! rosmake#builtin_make(type) abort
  let l:saved_makeprg = &makeprg
  let l:saved_errorformat = &errorformat

  if a:type ==# 'rosmake'
    let l:command = 'rosmake --threads=4'
    let &errorformat .= s:rosmake_errorformat
  elseif a:type ==# 'catkin_make'
    let l:command = 'catkin_make'
  else
    echohl WarningMsg
    echom 'This plugin has no config for ' . a:type
    echohl none
    return
  endif

  let &makeprg = l:command
  make

  let &makeprg = l:saved_makeprg
  let &errorformat = l:saved_errorformat
endf

fun! rosmake#get_make_command(type) abort
  if !(a:type ==# 'rosmake' || a:type ==# 'catkin_make')
    echohl WarningMsg
    echom "This plugin has no config for " . a:type
    echohl none
    throw "No config error"
  endif

  if a:type ==# 'rosmake'

    let l:config = 
          \ { a:type :
          \   { 'outputter/quickfix/errorformat' : &errorformat . s:rosmake_errorformat,
          \     'outputter/quickfix/open_cmd' : 'copen 8 | cbottom',
          \     'command' : 'rosmake',
          \     'args' : '--threads=4',
          \     'exec' : '%c %a',
          \   }
          \ }
  elseif a:type ==# 'catkin_make'
    let l:config = 
          \ { a:type :
          \   { 'outputter/quickfix/errorformat' : &errorformat,
          \     'outputter/quickfix/open_cmd' : 'copen 8 | cbottom',
          \     'command' : 'catkin_make',
          \     'args' : '-j4',
          \     'exec' : '%c %a',
          \   }
          \ }
  endif

  if exists(':QuickRun') == 2
    call extend(g:quickrun_config, l:config)
    let l:command = ':QuickRun ' . a:type
  else
    let l:command = ':call rosmake#builtin_make(''' . a:type . ''')'
  endif

  return l:command
endf

fun! rosmake#find_project_dir(searchname_arg) abort
  if type(a:searchname_arg) == 1 " stringのとき
    let l:arg_is_string = 1
    let l:searchname = a:searchname_arg
  elseif type(a:searchname_arg) == 3 " listのとき
    let l:arg_is_string = 0
    let l:index = 0
    let l:searchname = a:searchname_arg[l:index]
  else
    throw 'Argument is not appropriate to rosmake#find_project_dir()'
    return
  endif

  let l:destdir = ''

  while l:destdir == '' && l:searchname !=# ''
    let l:target = findfile(l:searchname, expand('%:p').';')

    if l:target ==# ''
      let l:target = finddir(l:searchname, expand('%:p').';')
    endif

    if l:target ==# ''
      let l:destdir = ''
    else
      let l:target = fnamemodify(l:target, ':p')
      if isdirectory(l:target)
        let l:destdir = fnamemodify(l:target, ':h:h')
      else
        let l:destdir = fnamemodify(l:target, ':h')
      endif
    endif

    if l:arg_is_string == 1 " stringのとき
      let l:searchname = ''
    else " listのとき
      let l:index = l:index + 1
      if l:index < len(a:searchname_arg)
        let l:searchname = a:searchname_arg[l:index]
      else
        let l:searchname = ''
      endif
    endif
  endwhile

  if l:destdir ==# ''
    throw "Appropriate directory was not found for " . string(a:searchname_arg)
  endif

  return l:destdir
endf

fun! rosmake#run_command_in_the_dir(destination,commandlist) abort
  let l:previous_cwd = getcwd()
  exe 'cd ' . a:destination
  for command in a:commandlist
    exe command
  endfor
  exe 'cd ' . l:previous_cwd
endf
