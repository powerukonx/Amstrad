; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                         (Part standalone launcher)                        *
; *                                                                           *
; * Code => Power / Deemphasis                                                *
; *                                                                           *
; *****************************************************************************
  org &200
  nolist
  run EntryPoint

; *****************************************************************************
; Include some definition.
; *****************************************************************************
  read "../../define/firmware.asm"
  read "../../define/macro.asm"
  read "../../define/component.asm"
  
; *****************************************************************************
; &8000 screen begin line
; *****************************************************************************
SCR8000
  db  #c5,#a0,#c5,#a8,#c5,#b0,#c5,#b8
  db  #25,#81,#25,#89,#25,#91,#25,#99
  db  #25,#a1,#25,#a9,#25,#b1,#25,#b9
  db  #85,#81,#85,#89,#85,#91,#85,#99
  db  #85,#a1,#85,#a9,#85,#b1,#85,#b9
  db  #e5,#81,#e5,#89,#e5,#91,#e5,#99
  db  #e5,#a1,#e5,#a9,#e5,#b1,#e5,#b9
  db  #45,#82,#45,#8a,#45,#92,#45,#9a
  db  #45,#a2,#45,#aa,#45,#b2,#45,#ba
  db  #a5,#82,#a5,#8a,#a5,#92,#a5,#9a
  db  #a5,#a2,#a5,#aa,#a5,#b2,#a5,#ba
  db  #05,#83,#05,#8b,#05,#93,#05,#9b
  db  #05,#a3,#05,#ab,#05,#b3,#05,#bb
  db  #65,#83,#65,#8b,#65,#93,#65,#9b
  db  #65,#a3,#65,#ab,#65,#b3,#65,#bb
  db  #c5,#83,#c5,#8b,#c5,#93,#c5,#9b
  db  #c5,#a3,#c5,#ab,#c5,#b3,#c5,#bb
  db  #25,#84,#25,#8c,#25,#94,#25,#9c
  db  #25,#a4,#25,#ac,#25,#b4,#25,#bc
  db  #85,#84,#85,#8c,#85,#94,#85,#9c
  db  #85,#a4,#85,#ac,#85,#b4,#85,#bc
  db  #e5,#84,#e5,#8c,#e5,#94,#e5,#9c
  db  #e5,#a4,#e5,#ac,#e5,#b4,#e5,#bc
  db  #45,#85,#45,#8d,#45,#95,#45,#9d
  db  #45,#a5,#45,#ad,#45,#b5,#45,#bd
  db  #a5,#85,#a5,#8d,#a5,#95,#a5,#9d
  db  #a5,#a5,#a5,#ad,#a5,#b5,#a5,#bd
  db  #05,#86,#05,#8e,#05,#96,#05,#9e
  db  #05,#a6,#05,#ae,#05,#b6,#05,#be
  db  #65,#86,#65,#8e,#65,#96,#65,#9e
  db  #65,#a6,#65,#ae,#65,#b6,#65,#be
  db  #c5,#86,#c5,#8e,#c5,#96,#c5,#9e

; *****************************************************************************
; &C000 screen begin line
; *****************************************************************************
  org &400
SCRC000
  db  #c5,#e0,#c5,#e8,#c5,#f0,#c5,#f8
  db  #25,#c1,#25,#c9,#25,#d1,#25,#d9
  db  #25,#e1,#25,#e9,#25,#f1,#25,#f9
  db  #85,#c1,#85,#c9,#85,#d1,#85,#d9
  db  #85,#e1,#85,#e9,#85,#f1,#85,#f9
  db  #e5,#c1,#e5,#c9,#e5,#d1,#e5,#d9
  db  #e5,#e1,#e5,#e9,#e5,#f1,#e5,#f9
  db  #45,#c2,#45,#ca,#45,#d2,#45,#da
  db  #45,#e2,#45,#ea,#45,#f2,#45,#fa
  db  #a5,#c2,#a5,#ca,#a5,#d2,#a5,#da
  db  #a5,#e2,#a5,#ea,#a5,#f2,#a5,#fa
  db  #05,#c3,#05,#cb,#05,#d3,#05,#db
  db  #05,#e3,#05,#eb,#05,#f3,#05,#fb
  db  #65,#c3,#65,#cb,#65,#d3,#65,#db
  db  #65,#e3,#65,#eb,#65,#f3,#65,#fb
  db  #c5,#c3,#c5,#cb,#c5,#d3,#c5,#db
  db  #c5,#e3,#c5,#eb,#c5,#f3,#c5,#fb
  db  #25,#c4,#25,#cc,#25,#d4,#25,#dc
  db  #25,#e4,#25,#ec,#25,#f4,#25,#fc
  db  #85,#c4,#85,#cc,#85,#d4,#85,#dc
  db  #85,#e4,#85,#ec,#85,#f4,#85,#fc
  db  #e5,#c4,#e5,#cc,#e5,#d4,#e5,#dc
  db  #e5,#e4,#e5,#ec,#e5,#f4,#e5,#fc
  db  #45,#c5,#45,#cd,#45,#d5,#45,#dd
  db  #45,#e5,#45,#ed,#45,#f5,#45,#fd
  db  #a5,#c5,#a5,#cd,#a5,#d5,#a5,#dd
  db  #a5,#e5,#a5,#ed,#a5,#f5,#a5,#fd
  db  #05,#c6,#05,#ce,#05,#d6,#05,#de
  db  #05,#e6,#05,#ee,#05,#f6,#05,#fe
  db  #65,#c6,#65,#ce,#65,#d6,#65,#de
  db  #65,#e6,#65,#ee,#65,#f6,#65,#fe
  db  #c5,#c6,#c5,#ce,#c5,#d6,#c5,#de
  
  org &2000
EntryPoint  
  
; Set mode 0 (160x200x4bpp)
  MODE_SET_LOW_RES

; Disable interrupt
  di

; Set screen resolution.
  SCREEN_CUSTOM_HATEBEATS

; Unlock plus features.
  ASIC_UNLOCK_NOIT

; Asic page-in.
  ASIC_PAGEIN

; Install FX colors.
  ld ix,LUT_Colors
  ld c,17+15
  ld de,ASIC_ADR_PEN0_COLOR
loop1
  ld a,(ix+1)
  add a,a
  add a,a
  add a,a
  add a,a
  or (ix + 0)
  ld (de),a
  inc de
  ld a,(ix + 2)
  ld (de),a
  inc de
  inc ix
  inc ix
  inc ix
  dec c
  jr nz,loop1

; Asic page-in.
  ASIC_PAGEOUT

; Clear from &8000 to &ffff.
  ld hl,&8000
  ld de,&8001
  ld bc,&7fff
  ld (hl),l
  ldir

; Call FX renderer.
mainloop
  call &3000
  jr mainloop

; Colors LUT
LUT_Colors
  db #01,#00,#00,#03,#01,#01,#06,#02
  db #02,#08,#02,#03,#0b,#03,#04,#0b
  db #04,#05,#09,#05,#06,#07,#07,#07
  db #06,#09,#08,#04,#0a,#09,#03,#0b
  db #0a,#02,#0c,#0c,#03,#0e,#0d,#07
  db #0e,#0e,#0b,#0f,#0f,#0f,#0f,#0f
  db #01,#00,#00,#03,#01,#01,#06,#02
  db #02,#08,#02,#03,#0b,#03,#04,#0b
  db #04,#05,#09,#05,#06,#07,#07,#07
  db #06,#09,#08,#04,#0a,#09,#03,#0b
  db #0a,#02,#0c,#0c,#03,#0e,#0d,#07
  db #0e,#0e,#0b,#0f,#0f,#0f,#0f,#0f
  
read "./source.asm"

  
  
  