let s:save_cpo = &cpo
set cpo&vim
if exists("g:loaded_myrosmake_plugin")
  finish
endif
let g:loaded_myrosmake_plugin = 1

command! Rosmake call myrosmake#make('rosmake',['manifest.xml', 'stack.xml'])
command! RosmakePackage call myrosmake#make('rosmake',"manifest.xml")
command! RosmakeWorkspace call myrosmake#make('rosmake',"stack.xml")
command! Catkinmake call myrosmake#make('catkin_make',".catkin_workspace")

let &cpo = s:save_cpo
unlet s:save_cpo
