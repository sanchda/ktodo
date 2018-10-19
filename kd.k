/srv/1010data/bin/e "$(readlink -f $0)" $@ 2>/dev/null; exit
/   /-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\
/   |                               Globals                                   |
/   \-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-/
sq:"□";ck:"✓";bl:"⚫";ht:"♡";st:"★"                        / fun glyphs
Q:.()                                                     / work queue
`8:"mkdir ",LDIR:_getenv["HOME"],"/kd/";                  / persist to disk
.i:_i                                                     / safety

/   /-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\
/   |                          Utility Functions                              |
/   \-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-/
A:{Q[x],:,y;(LDIR,$x)1:Q[x]}                               / append
W:{Q[x]:y;  (LDIR,$x)1:Q[x]}                               / write
SQ:{[l;i;j;p] Q[l;i;j]:p}
RGB:1_,/";",'$16 _sv'3 2#"0123456789ABCDEF"?/:             / Thanks JE
rgb:1_,/";",'$:                                            / RGB to vt100 format
open:{[l] *@[{Q[l]::1:x};LDIR,$l;:]}                       / open saved list
IN:{[l] :[open l;W[l]()]}                                  / INitialize label
iniN:{[n](`note;$n;0#`;_T;();0)}                           / note initializer
iniT:{[t](`task;$t;0#`;_T;();0)}                           / task initializer
addTask:{[l;t]   IN l;A[l]iniT[t]}                         / add a task
addNote:{[l;n]   IN l;A[l]iniN[n]}                         / add a note
delItem:{[l;i]   IN l;W[l]Q[l] _di i-1}                    / remove by id
addTag:{[l;i;t]  IN l;Q[l;i-1;2]:?Q[l;i-1;2],t;W[l]Q[l]}   / add tag
remTag:{[l;i;t]  IN l;Q[l;i-1;2]:Q[l;i-1;2]_dv t;W[l]Q[l]} / drop tag
subNote:{[l;i;n] IN l;Q[l;i-1;4],:,iniN[n];W[l]Q[l]}       / add subnote
rsbNote:{[l;i;j] IN l;Q[l;i-1;4]:Q[l;i-1;4]_di j-1;W[l]Q[l]}  / rem subnote
flpItem:{[l;i]   IN l;Q[l;i-1;5]~:; W[l]Q[l]}              / flip/complete
putItem:{[l;i;t] IN l;Q[l;i-1;1]: $t; W[l]Q[l]}            / edit item
restore:{[l] Q[`$$-2_ l]::1:LDIR,$l}                       / restore a list
dropLst:{[l] @[_del;LDIR,($l),".l";:]}                     / drop from DB
opt:|/.i[0]~/:                                             / did opt match?
.g:{[i] .i[i],,1_,/" ",'(1+|/i)_.i}                        / arg globber

/   /-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\
/   |                          Drawing Primitives                             |
/   \-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-/
E:"\033["
fg:  {[f]  E,"38;2;",(:[-3~4:f;RGB;rgb]f),"m",}           / change fg color
bg:  {[b]  E,"48;2;",(:[-3~4:f;RGB;rgb]b),"m",}           / change bg color
box:  fg[220 150 220]sq                                   / draw leading box
bull: fg[40  40  255]bl                                   / draw note
check:fg[10  200 10]ck                                    / draw check
{.[`$"S",x;();:;"\033[",x,"m",]}'$!9;  /bld,dim,stand,under,blink,rev,hidden
{.[`$"F",x;();:;"\033[3",x,"m",]}'$!8;                    / fg; KRGYBMCW; VT100
{.[`$"B",x;();:;"\033[4",x,"m",]}'$!8;                    / bg; KRGYBMCW
N:E,"0m",E,"49m",E,"39m",                                 / clear all mods
STYLAB:`bold`hipri`blink`red`green`blue                   / style names
STYSTY:(S1"";F3"";S5"";F1"";F2"";F4"";"")                 / styles
ICOLAB:`hipri`cool`love`star                              / icon names
ICOICO:("!";"COOL";ht;st;"")                              / icons
typLU:{:[`note~*x;0;*|x;1;2]}                             / type lookup
typBL:(check;box;bull;"")                                 / type bullet
typSTY:(N S2@;N@;N@;"",@)                                 / type styles
sav:{[]`0:"\0337"}; res:{[]`0:"\0338"}                    / save/restore pos

/   /-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\
/   |                        List Rendering Funcions                          |
/   \-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-/
shape:{(i@(*&~:)'(y*!1+_|/i%y)>\:i:&" "=" ",x)_ x}        / reshape long msg
doneD:{check," ",(N S2 x),N""}                            / draw finished
todoD:{box," ",N x}                                       / draw unfinished
noteD:{bull," ",N x}                                      / draw a note
date:{S2($_ _T-x)," d",N""};     DL:{date  x 3}           / format date
style:{,/STYSTY@STYLAB?/:`,x};   SL:{style x 2}           / style from label
icons:{,/ICOICO@ICOLAB?/:`,x};   IL:{icons x 2}           / icons from label
PL:{(noteD;doneD;todoD)[typLU[x]]SL[x],x[1],N""}          / payload display
listD0:{[x;n]
  pl:(,/" ",'(PL;DL;SL;IL;{[x]N""})@\:)x                  / make payloads
  `0:(n#" "),pl; `0:"\n"                                  / display list
}
listD:{[l;n] IN l                                         / display a list
  ntask: #i:&`task~/:*:'Q l                               / how many tasks?
  ndone:  +/~~(*|:)'Q l                                   / how many done?
  `0:," ",(S4@$l),N"    [",($ndone),"/",($ntask),"]"      / display header
  num: ("  "@&2*n),/:3!'".  ",/:$1+!#Q l                  / generate ids
  msg:(,/" ",'(PL;DL;SL;IL;{[x]N""})@\:)'Q l              / generate msg
  msg:num,'msg                                            / prepend numbers
  {[i]`0:,msg i;listD0[;8*n]'Q[l;i;4]}'!#Q l              / display
}
allD:{[]                                                  / display all lists
  if[~#(listD[;1]`$-2_)'p@&".l"~/:-2#'p:!LDIR
    `0:,"No lists defined."]}

/   /-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\
/   |                             Dispatch/API                                |
/   \-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-/
help:{`0:"
 kd [mode] <list name> <arguments>
  --showall, --sa   show all lists              kd --sa,        kd (no args)
  --show,    --s    show a list;                kd --s  mylist, kd mylist
  --drop,    --x    delete a list               kd --x  mylist
  --note,    --n    add note to list            kd --n  mylist mynote is this
  --todo,    --t    add a todo to list          kd --t  mylist mytodo is this
  --done,    --d    complete a todo             kd --d  mylist 5
  --hipri,   --h    set task to high priority   kd --h  mylist 5
  --lopri,   --l    set task to low priority    kd --l  mylist 5
  --remove,  --r    delete an entry from list   kd --r  mylist 5
  --label,   --L    add a tag to an entry       kd --L  mylist 5 hipri
  --unlabel, --U    remove a label              kd --U  mylist 5 hipri
  --edit,    --e    replace text of entry       kd --e  mylist 5 mynewnote
  --asnote,  --as   add a subnote to an entry   kd --as mylist 2 mysubnote
  --rsnote,  --rs   remove a subnote            kd --rs mylist 2 1

  Labels can also add styles to entries
  hipri   makes the message yellow + adds a !
  bold    makes message bold
  blink   makes message blink (if enabled by TTY)
  love    adds a ♡
  star    adds a ★
"}
show:   {[l]                             listD[`$l;1]}
showall:{[]                              allD[]  }
drop:   {[l]     dropLst[`$l];           `0:,"OK"}
note:   {[l;n]   addNote[`$l;n];         listD[`$l;1]}
todo:   {[l;t]   addTask[`$l;t];         listD[`$l;1]}
done:   {[l;i]   flpItem[`$l;0$i];       listD[`$l;1]}
hipri:  {[l;i]   addTag[`$l;0$i;`hipri]; listD[`$l;1]}
lopri:  {[l;i]   remTag[`$l;0$i;`hipri]; listD[`$l;1]}
remove: {[l;i]   delItem[`$l;0$i];       listD[`$l;1]}
label:  {[l;i;t] addTag[`$l;0$i;`$t];    listD[`$l;1]}
unlabel:{[l;i;t] remTag[`$l;0$i;`$t];    listD[`$l;1]}
edit:   {[l;i;t] putItem[`$l;0$i;t];     listD[`$l;1]}
asnote: {[l;i;n] subNote[`$l;0$i;n];     listD[`$l;1]}
rsnote: {[l;i;j] rsbNote[`$l;0$i;0$j];   listD[`$l;1]}

/   /-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\
/   |                          Argument Routing                               |
/   \-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-/
:[~#.i                   ; @[showall;  _n     ;:]
  (~"--"~2#*.i)&1~#.i    ; @[show;     .i 0   ;:]
  (~"--"~2#*.i)&1<#.i    ; .[note;     .g@,0  ;:]
  opt("--sa";"--showall"); @[showall;  _n     ;:]
  2>#.i                  ; @[help;     _n     ;:]
  opt("--s";"--show")    ; @[show;     .i 1   ;:]
  opt("--x";"--drop")    ; @[drop;     .i 1   ;:]
  3>#.i                  ; @[help;     _n     ;:]
  opt("--d";"--done")    ; .[done;     .i 1 2 ;:]
  opt("--h";"--hipri")   ; .[hipri;    .i 1 2 ;:]
  opt("--l";"--lopri")   ; .[lopri;    .i 1 2 ;:]
  opt("--r";"--remove")  ; .[remove;   .i 1 2 ;:]
  opt("--n";"--note")    ; .[note;     .g@,1  ;:]
  opt("--t";"--todo")    ; .[todo;     .g@,1  ;:]
  4>#.i                  ; @[help;     _n     ;:]
  opt("--L";"--label")   ; .[label;    .g 1 2 ;:]
  opt("--U";"--unlabel") ; .[unlabel;  .g 1 2 ;:]
  opt("--e";"--edit")    ; .[edit;     .g 1 2 ;:]
  opt("--as";"--asnote") ; .[asnote;   .g 1 2 ;:]
  opt("--rs";"--rsnote") ; .[rsnote;   .g 1 2 ;:]
                           @[help;     _n     ;:] ];
_exit 0
