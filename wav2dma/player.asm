; *****************************************************************************
; *                          DMA MOD Player by UKONX                          *
; *                                                                           *
; * Code => Power                                                             *
; *                                                                           *
; *****************************************************************************
 nolist

; *****************************************************************************
; Include some libs.
; *****************************************************************************
  read "../lib/lib_ga.asm"
  read "../lib/lib_psg.asm"
  read "../lib/lib_asic.asm"
  read "../lib/lib_crtc.asm"
  read "../lib/lib_pal.asm"
  read "../lib/lib_ppi.asm"
  read "../lib/lib_misc.asm"

; *****************************************************************************
; Constant definition.
; *****************************************************************************

; *****************************************************************************
; Entrypoint
; *****************************************************************************
.Entry_Point

; Disable interrupt.
  di

  mASIC_UNLOCK 0
  
; ASIC page-in.
  mASIC_PAGE ASIC_PAGE_IN
  
  ld de,sample
  ld hl,ASIC_REG_SAR0
  ld (hl),e
  inc hl
  ld (hl),d

  ld hl,ASIC_REG_DCSR
  ld (hl),1
  
; ASIC page-out.
  mASIC_PAGE ASIC_PAGE_OUT

; Effect to execute.
.Player_loop

  ; Loop back
  jp Player_loop
