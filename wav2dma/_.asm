; *****************************************************************************
; *                          DMA MOD Player by UKONX                          *
; *                                                                           *
; * Code => Power                                                             *
; *                                                                           *
; * Converted MOD must be load on C4/C5/C6/C7                                 *
; *                                                                           *
; *****************************************************************************
  

  org &0
  nolist
  run Entry_Point  

  read "./player.asm"

.sample
  incbin"./dma.bin"
  
LIST
 DB 0
