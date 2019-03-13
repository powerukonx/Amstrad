; *****************************************************************************
; *                          DMA MOD Player by UKONX                          *
; *                                                                           *
; * Code => Power                                                             *
; *                                                                           *
; * Converted MOD must be load on C4/C5/C6/C7                                 *
; *                                                                           *
; *****************************************************************************
  nolist
  org &8000

SAMPLING_8K  equ 0
SAMPLING_16K equ 1

; Select wish sampling 
SAMPLING equ SAMPLING_16K

  run Entry_Point  

read "./player.asm"

if SAMPLING=SAMPLING_8K
  read "./Vx.x_8KHz.asm"
else
  read "./Vx.x_16KHz.asm"
end