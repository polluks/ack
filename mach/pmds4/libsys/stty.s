.define _stty
.extern _stty
.sect .text
.sect .rom
.sect .data
.sect .bss
.sect .text
_stty:
tst.b -40(sp)
link	a6,#-0
move.l 12(a6),-(sp)
move.l #0x7409,-(sp)
move.l 8(a6),-(sp)
jsr _ioctl
add.l #12,sp
unlk a6
rts
