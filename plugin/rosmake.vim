let s:save_cpo = &cpo
set cpo&vim
if exists("g:loaded_rosmake_plugin")
  finish
endif
let g:loaded_rosmake_plugin = 1

command! Rosmake call rosmake#make('rosmake',['manifest.xml', 'stack.xml'])
command! RosmakePackage call rosmake#make('rosmake',"manifest.xml")
command! RosmakeWorkspace call rosmake#make('rosmake',"stack.xml")
command! Catkinmake call rosmake#make('catkin_make',".catkin_workspace")

let &cpo = s:save_cpo
unlet s:save_cpo
