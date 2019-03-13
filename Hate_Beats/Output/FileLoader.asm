; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                                                                           *
; * Code            => Power                                                  *
; * Misc info       => AST/Impact (REFRESH_OFF)                               *
; *****************************************************************************
  org &8000
  nolist
  run _start
  ;write direct "ukonx.bin"

; **************************************
; * Include somes definition.          *
; **************************************
  read "./define/macro.asm"
  read "./define/component.asm"
  read "./define/firmware.asm"
  read "./define/depacker.asm"

; **************************************
; * Constant definition.               *
; **************************************
video_memory_init equ &C000
video_memory_new  equ &4000

; **************************************
; *        Program entry point         *
; **************************************
_start

; Clear screen and set mode 2 (640x200x2)
  MODE_SET_HIGH_RES

; Unlock ASIC
  ASIC_UNLOCK

; Asic test
  TEST_ASIC

; 128Ko test
  TEST_128KO

; Clear screen and set mode 0 (160x200x16)
  MODE_SET_LOW_RES

; Prevents characters from being printed to the current stream
  call TXT_VDU_DISABLE

; Save current drive number
  ld hl,(PTR_CURRENT_DRIVER_NUMBER)
  ld a,(hl)
  push af

; Reinitialize ROM 7
  REINIT_ROM7

; Restore drive number
  pop af
  ld hl,(PTR_CURRENT_DRIVER_NUMBER)
  ld (hl),a

; Disable ink refresh (MUST BE AFTER SCR_SET_MODE !!)
  REFRESH_OFF

; Set black screen
  BLACK_INKS

; pseudo 16/9 screen
  call set_video_mode

; Unpack (bitbuster) loading screen into video memory
  ld hl,Zone_temp
  ld de,video_memory_new
  call Dpack

; Setup palette
  call set_palette_color

; Load UKONX001 into &C000 and unpack into bank C4(&4000) and C7(&4000)
  ld hl,file1
  ld de,&C000
  ld b,file2-file1
  call CAS_IN_OPEN

  ld hl,&C000
  call CAS_IN_DIRECT
  call CAS_IN_CLOSE

  SELECT_BANK_CONF_C4
  ld hl,&C000
  ld de,&4000
  call Dpack

  SELECT_BANK_CONF_C7
  ld hl,&CE6C
  ld de,&4000
  call Dpack

; Load UKONX002 into &C000 and depack into bank C5(&4000) and C6(&4000)
  ld hl,file2
  ld de,&C000
  ld b,file3-file2
  call CAS_IN_OPEN

  ld hl,&c000
  call CAS_IN_DIRECT
  call CAS_IN_CLOSE

  SELECT_BANK_CONF_C5
  ld hl,&C000
  ld de,&4000
  call Dpack

  SELECT_BANK_CONF_C6
  ld hl,&CC6D
  ld de,&4000
  call Dpack

; Load UKONX003 into &0040 and depack into &C000
  ld hl,file3
  ld de,&0040
  ld b,file4-file3
  call CAS_IN_OPEN

  ld hl,&0040
  call CAS_IN_DIRECT
  call CAS_IN_CLOSE

  ld hl,&0D22
  ld de,&C000
  call Dpack

  ld hl,&0040
  ld de,Zone_temp
  ld bc,&CE2
  ldir

; Load UKONX004 into &0040
  ld hl,file4
  ld de,&0040
  ld b,file_definition_end-file4
  call CAS_IN_OPEN

  ld hl,&0040
  call CAS_IN_DIRECT
  call CAS_IN_CLOSE

; Set black screen
  BLACK_INKS

; Depack from &0040 to &4000
  SELECT_BANK_CONF_C0
  ld hl,&0040
  ld de,&4000
  call Dpack

; Disable interrupt
  di

; Depack main prog into &0000
  ld hl,Zone_temp
  ld de,&0000
  call Depack

; Start demo
  jp 0

; **************************************
; * Set palette.                       *
; **************************************
set_palette_color
  ld bc, PORT_GA + GA_PENR_BORDER
  ld hl,palette_logo + 16
  color_logo
  out (c),c
  outd
  inc b
  dec c
  jp p, color_logo
  ret

; **************************************
; * Palette logo old                   *
; **************************************
palette_logo
  db &54,&5C,&4C,&4E,&43,&4B,&54,&54
  db &54,&54,&54,&54,&54,&54,&54,&54
  db &54

; **************************************
; * Set video mode and change screen   *
; * offset into &4000.                 *
; **************************************
set_video_mode
  ld bc,PORT_CRTC_SELECT_REG+CRTC_HORIZONTAL_DISPLAYED:out (c),c
  inc b:ld d,&30:out (c),d
  dec b:inc c:out (c),c
  inc b:ld d,&32:out (c),d
  dec b:ld c,CRTC_VERTICAL_DISPLAYED:out (c),c
  inc b:ld d,&15:out (c),d
  dec b:inc c:out (c),c
  inc b:ld d,&1D:out (c),d
  ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H:out (c),c
  inc b:ld a,&10:out (c),a
  dec b:inc c:out (c),c
  xor a:out (c),a
  ret

; **************************************
; * Demo files                         *
; **************************************
file1
  db "UKONX001.BIN"
file2
  db "UKONX002.BIN"
file3
  db "UKONX003.BIN"
file4
  db "UKONX004.BIN"
file_definition_end

; **************************************
; * Loading screen                     *
; **************************************
Zone_temp
  db #00,#40,#00,#00,#7f,#00,#00,#e1
  db #88,#40,#c0,#80,#f9,#17,#b7,#00
  db #17,#e1,#f5,#13,#77,#c0,#00,#3d
  db #f1,#ba,#80,#09,#f8,#60,#b8,#15
  db #e3,#24,#36,#e1,#f2,#0b,#7c,#80
  db #18,#79,#16,#37,#e7,#60,#ef,#1b
  db #83,#d8,#f0,#80,#0c,#c7,#21,#04
  db #70,#b0,#08,#bb,#77,#2c,#8e,#18
  db #35,#88,#00,#04,#27,#f0,#8c,#e8
  db #44,#00,#44,#c2,#0c,#f0,#e0,#09
  db #1c,#70,#f0,#08,#62,#4e,#34,#80
  db #42,#d1,#c4,#13,#24,#00,#7c,#e3
  db #37,#6f,#27,#00,#49,#84,#1b,#e4
  db #06,#95,#3c,#12,#52,#60,#08,#90
  db #b0,#70,#6b,#a4,#17,#d8,#46,#aa
  db #15,#55,#38,#a0,#00,#11,#47,#b0
  db #b4,#14,#3c,#9c,#5b,#7c,#68,#70
  db #44,#d0,#23,#e4,#c0,#a4,#5e,#84
  db #5e,#51,#13,#f0,#48,#0e,#d0,#d8
  db #a4,#c0,#72,#d0,#6b,#58,#b1,#13
  db #19,#40,#05,#0d,#c0,#70,#e4,#66
  db #99,#02,#50,#0b,#f9,#1c,#4e,#2e
  db #88,#57,#1c,#e0,#5f,#17,#58,#a0
  db #60,#17,#06,#d8,#20,#23,#cf,#af
  db #12,#ae,#e0,#40,#e1,#08,#f0,#a1
  db #1c,#47,#92,#18,#10,#64,#eb,#5f
  db #78,#6a,#18,#10,#b9,#2e,#1c,#67
  db #67,#40,#36,#28,#10,#ca,#d8,#94
  db #dd,#55,#91,#66,#80,#84,#38,#b0
  db #45,#6d,#80,#19,#be,#21,#04,#18
  db #b9,#28,#08,#97,#ee,#1a,#15,#8f
  db #37,#00,#72,#28,#e6,#7a,#05,#90
  db #f0,#4c,#24,#c0,#0e,#28,#87,#64
  db #18,#1e,#22,#44,#f0,#20,#b8,#7a
  db #96,#9f,#64,#c6,#8e,#be,#52,#a4
  db #d3,#92,#d2,#a6,#10,#e0,#73,#b8
  db #08,#14,#94,#71,#e0,#cc,#e5,#dd
  db #3e,#2a,#44,#51,#c8,#3a,#64,#e0
  db #12,#95,#f3,#21,#4f,#90,#11,#d0
  db #91,#be,#cb,#d0,#0d,#88,#94,#c6
  db #c8,#35,#d9,#49,#7c,#ed,#24,#86
  db #51,#be,#b9,#32,#15,#c5,#1b,#a6
  db #2b,#60,#d9,#c0,#40,#a5,#19,#18
  db #94,#ae,#c5,#85,#18,#0a,#88,#e1
  db #1c,#50,#b7,#1c,#d2,#21,#3d,#20
  db #e0,#78,#d8,#00,#e9,#eb,#25,#72
  db #00,#17,#66,#04,#7c,#77,#a3,#d0
  db #a3,#a2,#40,#c4,#ec,#52,#14,#4b
  db #a0,#9a,#2b,#40,#b1,#73,#af,#dc
  db #4b,#9a,#77,#97,#cc,#0a,#e0,#f6
  db #7b,#40,#3e,#57,#8e,#2b,#20,#8a
  db #ee,#fa,#ff,#36,#e1,#fe,#6f,#00
  db #fd,#ed,#ff,#9e,#93,#a7,#3c,#1f
  db #80,#b8,#f1,#7c,#24,#18,#c7,#f0
  db #67,#a5,#5b,#b2,#e3,#75,#f3,#7c
  db #61,#1f,#e6,#eb,#1b,#e7,#62,#eb
  db #1a,#e7,#60,#ef,#0e,#9d,#d7,#77
  db #11,#44,#c7,#8a,#1c,#92,#cd,#0d
  db #0b,#4e,#0f,#18,#b3,#63,#b7,#b7
  db #b3,#78,#73,#a4,#c9,#5d,#0c,#ce
  db #2c,#88,#43,#38,#94,#75,#20,#42
  db #bb,#d7,#df,#78,#73,#93,#1b,#cf
  db #cf,#00,#58,#5b,#e0,#f6,#9d,#3d
  db #ba,#79,#ee,#86,#70,#51,#f1,#c3
  db #71,#11,#84,#80,#99,#c3,#58,#62
  db #a7,#70,#8c,#a7,#69,#29,#08,#c4
  db #60,#70,#e0,#e1,#15,#60,#96,#c9
  db #da,#1e,#3c,#31,#7a,#ea,#7b,#c0
  db #7d,#f7,#38,#d0,#26,#df,#13,#fd
  db #62,#2b,#fb,#97,#ed,#f7,#90,#f9
  db #e1,#37,#50,#a9,#1c,#4f,#57,#e0
  db #c0,#65,#20,#99,#d7,#45,#0c,#70
  db #15,#ec,#fc,#d9,#14,#bb,#70,#e1
  db #69,#40,#90,#1d,#46,#92,#e3,#10
  db #04,#c1,#d9,#95,#b2,#f3,#c6,#21
  db #2e,#3e,#7b,#91,#e4,#97,#d7,#e5
  db #e4,#e8,#71,#55,#c4,#81,#5e,#b5
  db #bc,#45,#71,#19,#23,#9d,#fc,#c7
  db #60,#3c,#68,#3d,#10,#95,#bf,#96
  db #4e,#6f,#32,#15,#ac,#27,#c4,#b7
  db #a2,#60,#c5,#75,#90,#1e,#cc,#df
  db #a4,#b8,#f3,#92,#fc,#4a,#b0,#f0
  db #0d,#58,#8c,#ee,#f9,#c1,#b0,#1f
  db #98,#08,#d0,#a3,#5f,#82,#8a,#74
  db #db,#2a,#cc,#71,#7b,#d8,#db,#51
  db #95,#4e,#c1,#73,#16,#ad,#fb,#95
  db #3d,#53,#21,#ec,#cd,#25,#be,#1c
  db #a7,#70,#ab,#97,#50,#e9,#f1,#24
  db #94,#6c,#b2,#70,#0c,#47,#f0,#a0
  db #29,#e0,#a1,#e2,#0c,#af,#ad,#19
  db #34,#c4,#0f,#13,#24,#08,#eb,#dc
  db #22,#48,#e4,#1c,#10,#a4,#96,#c2
  db #d1,#30,#a8,#c5,#bc,#38,#ec,#6c
  db #00,#8c,#99,#1a,#08,#51,#89,#16
  db #77,#93,#04,#e4,#cf,#e4,#44,#9d
  db #a0,#d7,#58,#40,#c1,#fa,#5b,#d3
  db #cd,#82,#1c,#5b,#80,#97,#0f,#85
  db #d9,#b9,#5b,#b8,#86,#06,#9e,#10
  db #8c,#37,#bf,#00,#90,#40,#ff,#fd
  db #fe,#00,#71,#b5,#e9,#ff,#d6,#8b
  db #e1,#7c,#33,#8d,#e2,#ff,#83,#1f
  db #13,#2f,#ab,#f8,#3d,#45,#b7,#3f
  db #1c,#d3,#10,#cf,#7c,#d6,#8b,#3d
  db #7c,#36,#f9,#93,#8c,#d4,#f5,#eb
  db #d7,#11,#bd,#1c,#7f,#04,#bf,#7f
  db #f3,#99,#39,#1c,#75,#18,#b7,#dc
  db #3f,#f0,#e6,#97,#04,#0b,#2e,#e4
  db #f3,#5b,#10,#35,#5f,#58,#e4,#db
  db #84,#19,#86,#a0,#b2,#b9,#3b,#44
  db #0d,#e7,#37,#be,#b6,#12,#f6,#e9
  db #78,#89,#39,#60,#70,#94,#56,#04
  db #45,#02,#73,#b7,#3d,#8f,#cc,#94
  db #67,#20,#15,#29,#30,#45,#c1,#70
  db #e0,#27,#c7,#c4,#db,#87,#e5,#09
  db #cf,#ea,#a7,#5d,#73,#42,#d0,#26
  db #7f,#ed,#8d,#4b,#fc,#93,#73,#70
  db #da,#54,#11,#92,#b5,#c9,#e9,#57
  db #c2,#60,#80,#39,#4d,#20,#3e,#48
  db #77,#32,#70,#88,#0c,#8b,#2d,#0a
  db #f0,#60,#e1,#08,#40,#b6,#de,#17
  db #4a,#19,#83,#d8,#55,#63,#fa,#87
  db #58,#de,#b5,#25,#75,#5f,#ba,#e7
  db #ef,#73,#cb,#dd,#76,#ed,#b7,#48
  db #45,#19,#57,#08,#2f,#cf,#db,#00
  db #b2,#de,#1c,#15,#77,#5f,#33,#93
  db #d4,#cb,#58,#dd,#e3,#c0,#c4,#82
  db #e9,#c5,#d9,#2f,#20,#b5,#1c,#a7
  db #88,#b8,#94,#44,#9b,#f3,#6e,#9a
  db #0d,#d8,#8c,#ee,#9c,#99,#c4,#45
  db #a0,#e2,#6e,#23,#47,#db,#95,#ad
  db #72,#d8,#e4,#5f,#44,#20,#ce,#34
  db #4b,#a4,#da,#f6,#e5,#b7,#22,#3d
  db #63,#a4,#67,#ab,#a8,#8c,#e5,#50
  db #7c,#4b,#d1,#2d,#88,#44,#fc,#af
  db #a6,#85,#22,#d4,#a4,#a9,#8a,#45
  db #d8,#b0,#91,#f8,#e9,#ae,#69,#ee
  db #e1,#ed,#0c,#50,#ae,#4c,#f3,#00
  db #cc,#13,#cc,#d6,#de,#5a,#81,#69
  db #88,#cd,#fc,#ad,#c0,#9f,#ce,#c1
  db #bd,#2f,#91,#e3,#b7,#db,#8a,#f1
  db #dd,#2d,#a4,#da,#c9,#fe,#8f,#00
  db #fe,#07,#31,#b5,#e7,#c6,#e8,#ff
  db #b9,#e6,#ff,#ea,#83,#16,#c7,#12
  db #df,#44,#e5,#f0,#1b,#7b,#80,#18
  db #f5,#10,#98,#1e,#db,#98,#e7,#90
  db #be,#be,#43,#db,#b5,#be,#a2,#df
  db #36,#07,#80,#50,#9f,#6b,#e0,#0c
  db #8c,#2d,#6f,#c4,#f9,#33,#0b,#d8
  db #f2,#f9,#eb,#0e,#0b,#c2,#2d,#6f
  db #a0,#90,#1c,#fb,#3d,#e0,#99,#ae
  db #19,#1b,#a0,#aa,#e5,#e9,#cd,#7f
  db #84,#2f,#24,#9d,#61,#04,#3a,#91
  db #86,#c7,#e6,#07,#70,#a4,#90,#31
  db #76,#9f,#bc,#6a,#12,#04,#3c,#f6
  db #cf,#7d,#82,#38,#19,#b8,#17,#45
  db #ed,#e9,#ec,#b9,#8c,#94,#47,#40
  db #f4,#9f,#ea,#b3,#0e,#cd,#68,#ff
  db #d1,#d0,#e0,#68,#d3,#48,#19,#51
  db #e0,#b7,#91,#b0,#c7,#90,#f3,#27
  db #c4,#51,#20,#e3,#05,#a3,#d9,#fa
  db #f6,#2a,#6d,#c8,#4f,#08,#03,#96
  db #3c,#0a,#f3,#e0,#87,#31,#08,#04
  db #d9,#ee,#a7,#53,#19,#c2,#b2,#57
  db #9c,#d9,#a3,#57,#8c,#8f,#90,#de
  db #e9,#ed,#80,#86,#2c,#77,#cb,#2d
  db #b0,#79,#63,#48,#1f,#b0,#19,#8a
  db #2f,#6e,#95,#b8,#e7,#46,#4e,#87
  db #d0,#f2,#b5,#33,#a9,#48,#f2,#56
  db #80,#09,#27,#a4,#1a,#90,#0d,#29
  db #c4,#bd,#65,#50,#25,#73,#5f,#b8
  db #17,#98,#f2,#e0,#70,#c0,#66,#a0
  db #cf,#22,#e1,#d6,#d0,#25,#4b,#c2
  db #11,#db,#e5,#94,#4c,#cd,#1d,#20
  db #30,#46,#70,#ac,#3f,#d8,#82,#99
  db #5d,#c0,#ac,#2c,#4f,#d8,#7a,#48
  db #70,#4b,#b0,#e5,#34,#8a,#d4,#bf
  db #b3,#e2,#1d,#46,#e3,#73,#38,#9a
  db #48,#24,#c5,#4f,#58,#0c,#91,#5f
  db #17,#09,#9d,#a3,#7a,#4b,#9f,#2f
  db #70,#f3,#a9,#f7,#c2,#f4,#96,#a2
  db #de,#4e,#2c,#23,#ea,#2d,#d0,#ab
  db #d9,#79,#67,#ff,#c7,#77,#d2,#da
  db #de,#1f,#3c,#1e,#15,#fe,#6b,#0f
  db #00,#fe,#0c,#3f,#9e,#e2,#c7,#fc
  db #3c,#d2,#76,#ff,#95,#4c,#8c,#f3
  db #d7,#ac,#3c,#b7,#f5,#f8,#60,#46
  db #c0,#84,#30,#e2,#79,#7a,#19,#3d
  db #80,#8a,#cf,#7b,#d3,#61,#b3,#90
  db #60,#ea,#3d,#bd,#43,#b7,#1a,#dc
  db #79,#ed,#45,#58,#e5,#fd,#fa,#ea
  db #4f,#1e,#d0,#f0,#eb,#86,#ab,#25
  db #8f,#a6,#cc,#1a,#3f,#88,#e5,#b7
  db #c8,#cd,#5c,#c6,#ae,#e0,#c6,#e3
  db #07,#5f,#00,#d9,#c9,#48,#84,#eb
  db #b3,#a0,#a0,#fc,#bd,#f0,#9e,#e1
  db #e4,#b0,#c4,#fe,#dd,#8f,#f0,#40
  db #ec,#e4,#c0,#70,#72,#a4,#d8,#b6
  db #e4,#25,#a6,#38,#f3,#c8,#21,#a4
  db #e4,#a7,#71,#f2,#c8,#a0,#8e,#b1
  db #3b,#e9,#7c,#ca,#f4,#97,#8f,#ea
  db #2f,#8e,#e7,#ea,#d3,#0e,#9f,#a3
  db #53,#d0,#e0,#bf,#bc,#8e,#d8,#20
  db #de,#c8,#bf,#e3,#85,#f7,#bc,#fa
  db #8e,#8e,#6f,#05,#f5,#e3,#f6,#f2
  db #35,#6b,#60,#09,#70,#f4,#92,#b6
  db #32,#82,#38,#e7,#d2,#2f,#ea,#62
  db #bd,#3a,#8b,#92,#b8,#b9,#c8,#1f
  db #b5,#aa,#16,#00,#32,#93,#97,#be
  db #d9,#8c,#b6,#75,#e0,#35,#7a,#47
  db #e9,#3f,#8a,#cb,#b0,#10,#59,#c8
  db #45,#08,#c3,#80,#ee,#d4,#24,#0c
  db #51,#70,#1c,#bf,#e3,#15,#25,#08
  db #9d,#b9,#d2,#49,#05,#80,#ac,#ea
  db #60,#8d,#cd,#8e,#82,#12,#c4,#cb
  db #cc,#0d,#48,#e5,#5f,#d0,#ac,#3c
  db #46,#94,#70,#42,#70,#cf,#1c,#9e
  db #c5,#88,#16,#d4,#18,#10,#8d,#83
  db #71,#00,#70,#cc,#4e,#52,#55,#b0
  db #60,#9c,#92,#4e,#08,#cc,#eb,#6b
  db #44,#1e,#36,#2c,#c8,#78,#8d,#90
  db #da,#7f,#1f,#c5,#79,#9e,#aa,#a4
  db #29,#cc,#a4,#5b,#2a,#0f,#64,#17
  db #84,#e3,#a4,#75,#9d,#00,#12,#a4
  db #d8,#a4,#f9,#d5,#cd,#39,#f7,#11
  db #09,#e7,#cf,#5e,#95,#84,#e5,#ab
  db #5e,#95,#9c,#ea,#80,#9d,#a9,#9e
  db #83,#7c,#62,#bd,#30,#3d,#5f,#7c
  db #3f,#2d,#d9,#e0,#b7,#f2,#6b,#dc
  db #77,#bf,#ac,#83,#00,#ff,#82,#4f
  db #9e,#f8,#71,#fc,#d3,#d2,#1d,#b1
  db #ff,#7d,#23,#7c,#2c,#7d,#39,#b3
  db #ee,#cb,#43,#df,#e0,#bc,#3d,#4e
  db #35,#0e,#80,#71,#e1,#36,#ef,#4f
  db #d3,#04,#db,#f8,#d7,#e2,#5d,#9e
  db #f6,#ed,#d7,#8f,#af,#26,#80,#e3
  db #f1,#82,#bb,#1a,#b8,#7b,#e4,#e3
  db #18,#c5,#91,#80,#39,#8e,#90,#89
  db #6b,#a5,#75,#48,#54,#b7,#60,#8c
  db #33,#a5,#ed,#f6,#cd,#6a,#25,#88
  db #a1,#3c,#39,#e9,#c3,#a4,#d9,#73
  db #c4,#6b,#ee,#c7,#9e,#b2,#e4,#f4
  db #c9,#d7,#35,#e0,#96,#ec,#a6,#73
  db #a9,#db,#2a,#b3,#1a,#c0,#f7,#b8
  db #f6,#d8,#8e,#d8,#a0,#ee,#e2,#94
  db #38,#8e,#ce,#f9,#89,#9f,#ea,#4e
  db #b4,#ee,#a2,#2c,#49,#e5,#0a,#48
  db #43,#a9,#08,#bc,#44,#b0,#af,#77
  db #b7,#cd,#67,#68,#57,#0e,#c8,#45
  db #2f,#22,#b5,#56,#80,#5a,#7e,#cc
  db #51,#19,#b0,#c3,#40,#d2,#9c,#a3
  db #e1,#7f,#80,#8d,#2b,#76,#e4,#1e
  db #c0,#ae,#33,#4f,#00,#df,#08,#90
  db #df,#35,#28,#58,#e1,#e3,#e2,#f2
  db #be,#38,#6b,#e4,#6a,#60,#1f,#32
  db #08,#9f,#32,#8f,#31,#08,#1c,#91
  db #db,#47,#bf,#8f,#ee,#71,#a2,#1d
  db #39,#60,#0a,#98,#4c,#88,#0d,#b0
  db #8e,#82,#12,#c4,#d8,#cc,#d0,#64
  db #be,#72,#d8,#e1,#0e,#44,#6e,#9c
  db #66,#46,#cb,#7e,#d6,#24,#a0,#2d
  db #88,#d9,#6b,#a4,#23,#89,#9a,#ca
  db #cc,#72,#8e,#a8,#f8,#4b,#9c,#c5
  db #46,#04,#9a,#62,#66,#50,#b7,#39
  db #8a,#82,#1f,#4f,#20,#90,#42,#c0
  db #40,#70,#1e,#d5,#13,#88,#65,#d8
  db #1c,#d4,#66,#1b,#a4,#65,#06,#dd
  db #3d,#35,#70,#16,#88,#b2,#39,#a2
  db #2d,#ca,#8b,#cb,#ab,#97,#9f,#fc
  db #5e,#17,#15,#84,#e3,#20,#ef,#eb
  db #4d,#77,#0b,#7b,#7f,#b9,#7f,#c3
  db #e2,#80,#af,#f6,#5a,#e9,#f5,#bf
  db #82,#a7,#3b,#8e,#12,#5e,#40,#79
  db #f7,#0b,#b9,#ff,#ef,#7f,#16,#c8
  db #40,#ff,#c9,#87,#c4,#fd,#bf,#d1
  db #dd,#80,#15,#f2,#7f,#c3,#9f,#ec
  db #bc,#99,#d1,#e3,#aa,#9c,#fc,#3a
  db #1b,#b2,#e3,#43,#ed,#9b,#b9,#2b
  db #e3,#75,#e9,#d4,#ae,#3c,#08,#67
  db #d2,#97,#2a,#4d,#10,#f0,#b5,#fa
  db #d2,#92,#3d,#75,#90,#9e,#f6,#9e
  db #a4,#0e,#4f,#84,#f0,#ce,#b2,#4e
  db #ce,#4d,#97,#e2,#7b,#77,#e4,#91
  db #3c,#8d,#9b,#39,#98,#c9,#ac,#dd
  db #f1,#54,#18,#3a,#e4,#44,#e6,#a1
  db #8f,#a4,#80,#9e,#58,#95,#f3,#e1
  db #e9,#88,#5e,#d3,#10,#f4,#c7,#90
  db #6b,#34,#46,#85,#70,#d0,#eb,#b0
  db #8b,#cd,#07,#94,#21,#10,#25,#a6
  db #73,#1a,#76,#98,#c6,#94,#72,#21
  db #e4,#de,#08,#95,#5f,#85,#c6,#40
  db #23,#c7,#ce,#96,#ce,#f3,#b4,#d1
  db #40,#80,#92,#1d,#5d,#1a,#5f,#7a
  db #ea,#46,#9b,#e3,#21,#d8,#c6,#d8
  db #c6,#3f,#b0,#fc,#f5,#68,#9f,#98
  db #b1,#8a,#4b,#b1,#17,#6c,#dc,#4d
  db #a4,#09,#3d,#70,#08,#f6,#7f,#e0
  db #a7,#84,#9b,#b1,#8b,#3c,#fa,#83
  db #f3,#00,#ea,#17,#ab,#75,#a4,#28
  db #60,#f6,#8a,#38,#00,#e2,#2b,#3b
  db #47,#a0,#96,#49,#58,#b0,#63,#e2
  db #f1,#c0,#66,#ad,#e4,#70,#62,#e0
  db #1f,#a4,#94,#38,#9c,#14,#88,#48
  db #fb,#bd,#72,#07,#58,#ac,#5b,#c7
  db #1f,#e0,#0a,#34,#31,#f0,#6f,#47
  db #18,#6a,#e0,#e6,#1b,#b7,#79,#4b
  db #40,#cc,#28,#44,#80,#a3,#cc,#88
  db #9b,#d8,#f3,#a7,#c0,#0d,#d8,#08
  db #14,#e6,#57,#9a,#24,#48,#8b,#75
  db #cc,#5b,#39,#70,#00,#a4,#f5,#b7
  db #8e,#b4,#53,#60,#95,#e5,#14,#4e
  db #1f,#a4,#33,#04,#64,#c0,#c4,#fa
  db #8e,#60,#13,#23,#d8,#aa,#20,#51
  db #46,#a0,#a4,#e2,#10,#a0,#a1,#3a
  db #a4,#00,#cf,#8c,#91,#8e,#b9,#15
  db #40,#d4,#e4,#40,#ff,#de,#a5,#c0
  db #8b,#4e,#5e,#09,#df,#b7,#e5,#19
  db #e3,#b2,#5c,#5b,#ad,#97,#2f,#b7
  db #b8,#fb,#a9,#40,#8c,#c6,#81,#fe
  db #1f,#fd,#ef,#3a,#e3,#7f,#c0,#e6
  db #fe,#ea,#fc,#17,#ff,#d8,#f2,#e3
  db #cc,#b7,#c5,#fc,#9d,#19,#63,#e5
  db #7f,#45,#27,#c3,#fa,#7b,#ec,#c9
  db #f3,#fe,#f9,#b6,#eb,#91,#fe,#9e
  db #5a,#de,#ac,#9a,#cc,#ef,#bb,#1d
  db #f8,#46,#6f,#8f,#1e,#46,#8f,#c4
  db #c8,#5d,#b9,#cd,#c0,#76,#8f,#a4
  db #5e,#ef,#df,#ea,#4f,#0e,#13,#84
  db #98,#35,#1b,#04,#ef,#be,#8a,#c2
  db #84,#09,#ee,#86,#39,#a4,#8d,#46
  db #77,#10,#ef,#5f,#c1,#de,#2a,#73
  db #77,#a6,#dc,#b8,#44,#fa,#63,#80
  db #60,#98,#b9,#7c,#f9,#e9,#ad,#45
  db #7f,#b0,#9f,#6e,#58,#a2,#cd,#44
  db #eb,#8a,#a8,#cd,#18,#6c,#80,#25
  db #a6,#73,#1a,#6a,#2e,#04,#4f,#e0
  db #5f,#58,#a4,#f6,#f5,#8d,#d8,#20
  db #5d,#c8,#5c,#ce,#f2,#8e,#f0,#78
  db #41,#e6,#54,#1a,#73,#c4,#5f,#ea
  db #e9,#c6,#e8,#b0,#c7,#21,#d8,#cd
  db #2e,#25,#a5,#b0,#9e,#a7,#10,#5f
  db #13,#20,#48,#ea,#f8,#8a,#cd,#69
  db #6e,#e4,#17,#30,#47,#5e,#88,#40
  db #5a,#02,#4c,#70,#88,#ee,#5c,#67
  db #15,#20,#5f,#5d,#98,#71,#79,#15
  db #83,#c4,#f0,#8c,#fd,#fb,#96,#8f
  db #bd,#a9,#23,#96,#a4,#d8,#81,#71
  db #b5,#1b,#66,#b9,#0c,#2c,#31,#a4
  db #1f,#a4,#73,#a8,#08,#82,#e6,#10
  db #e6,#2a,#cc,#98,#8a,#b5,#9c,#7b
  db #4b,#50,#eb,#38,#28,#e4,#c7,#12
  db #70,#47,#13,#90,#4f,#9d,#34,#25
  db #b7,#f3,#82,#29,#c4,#1c,#b5,#60
  db #07,#40,#9b,#1b,#8d,#19,#37,#13
  db #70,#08,#8b,#c4,#d3,#73,#2b,#bc
  db #26,#6c,#07,#b1,#e4,#a5,#73,#db
  db #19,#bf,#fb,#c5,#1d,#23,#d0,#d6
  db #99,#14,#90,#60,#c1,#70,#f0,#1a
  db #c4,#8a,#73,#d8,#1d,#57,#20,#6d
  db #ea,#f1,#ec,#39,#90,#2c,#e5,#61
  db #78,#5f,#52,#9c,#d2,#b8,#db,#b0
  db #75,#99,#eb,#c1,#5e,#b5,#e9,#e1
  db #21,#e1,#1f,#e5,#41,#e1,#af,#1e
  db #15,#8e,#e1,#86,#7f,#37,#00,#d3
  db #c8,#6e,#f5,#df,#e1,#00,#ff,#83
  db #3f,#00,#ff,#f0
