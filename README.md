# ktodo
A personal todo list written in K3

I wrote this after seeing on article on HackerNews about a minimalistic, CLI-driven todo-list manager.  It called down multiple rather heavy dependencies and weighed in at several hundred lines of code, so I thought I'd see how much effort it took in K without any real dependencies (aside from a VT-100 compatible terminal).

## Features
* Notes and tasks (can be complete or incomplete)
* Styles such as blink, high-priority, heart, star
* Subnotes
* Bash list-autocompletion
* Self-executing k-script

## Future
Compatibility with Kona?

## Usage

```
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
  ```
