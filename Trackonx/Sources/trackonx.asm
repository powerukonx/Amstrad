; Hard SPRITE 0-1-2 => Channel A
; Hard SPRITE 3-4-5 => Channel B
; Hard SPRITE 6-7-8 => Channel C

      org #0040
      nolist
      run EntryPoint

; High resolution mode 640x200
EntryPoint
      ld a,#02
      call #bc0e

; Set pen 1 color
      ld a,#01
      ld bc,(PEN1_INK)
.l004b
      call #bc32

; Set pen 0 color
      xor a
      ld bc,(PEN0_INK)
      call #bc32

; Set border color
      ld bc,(BORDER_INK)
      call #bc38

; Wait 40ms
      call #bd19
      call #bd19

; Unlock ASIC
      di
      ld e,#11
      ld hl,ASIC_UNLOCK_SEQUENCE
      ld bc,#bc00
.SEND_ASIC_SEQUENCE
      ld a,(hl)
      out (c),a
      inc hl
      dec e
      jr nz,SEND_ASIC_SEQUENCE

; Make screen address LUT
      call MAKE_SCR_LUT

; ASIC page-in
      ld bc,#7fb8
      out (c),c

; Set sprite hard colors
      ld hl,HARDSPRITECOLOR
      ld de,#6422
      ld bc,#001e
      ldir

; Set sprite XY position
      ld hl,HARDSPRITECONFIG
      ld de,#6000
      ld a,#09
.SET_HARDSPR_POS
      ldi:ldi:ldi:ldi:ldi:inc de:inc de:inc de
      dec a
      jp nz,SET_HARDSPR_POS

; ASIC page-out
      ld bc,#7fa0
      out (c),c

; Display/Update current pattern.
      call DISPLAY_PATTERN

; Display items (instrument, octave, ...) 
      call l11fb

      call l11ab

      call l19c8

      jp l1a36


; **********************************************
; Refresh channels visu (done with hard sprite)
; **********************************************      
.REFRESH_CHAN_VISU

; ASIC page-in
      ld bc,#7fb8
      out (c),c

; Save stack pointer
      ld (RESTORE_SP + 1),sp

; Fill hard sprite 0-1-2 (channel A)
; H   = MSB Hard sprite 0
; SP  = END+1 of hard sprite 3
      ld h,#40
      ld sp,#4300

; If counter = 0 => clear channel A hard sprites
      ld a,(REFRESH_VISU_COUNTER)
      or a
      jp z,CLEAR_VISU

; Retrieve DMA0 AY list
      ld de,(l04a6)

; Else if counter = 1 => display channel A hard sprites with new values
      dec a
      jp z,REFRESH_VISU_VALUE

; Fill hard sprite 3-4-5 (channel B)
; H   = MSB Hard sprite 6
; SP  = END+1 of hard sprite 6
      ld h,#43
      ld sp,#4600
 
; Else if counter = 2 => clear channel B hard sprites
      dec a
      jp z,CLEAR_VISU

; Retrieve DMA1 AY list
      ld de,(l04a8)

; Else if counter = 2 => display channel B hard sprites with new values
      dec a
      jp z,REFRESH_VISU_VALUE

; Fill hard sprite 6-7-8 (channel C)
; H   = MSB Hard sprite 6
; SP  = END+1 of hard sprite 8
      ld h,#46
      ld sp,#4900

; Else if counter = 4 => clear channel C hard sprites
      dec a
      jp z,CLEAR_VISU

; Else display channel C hard sprites with new values

; DE = DMA2 AY list
      ld de,(l04aa)
 
; Display AY value on visu
.REFRESH_VISU_VALUE

; 3 hard sprites per channel
      ld c,#03

.REFRESH_HARD_SPRITE
; Get AY value
      ld a,(de)
; Compute Y => AY value x 16      
      add a:add a:add a:add a
; Save value to hard sprite at X = 0
      ld l,a:inc a:ld (hl),a

; Zoom out AY value      
      inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de

      ld a,(de):add a:add a:add a:add a:  inc a:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 1
      ld a,(de):add a:add a:add a:add a:add #02:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 2
      ld a,(de):add a:add a:add a:add a:add #03:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 3
      ld a,(de):add a:add a:add a:add a:add #04:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 4
      ld a,(de):add a:add a:add a:add a:add #05:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 5
      ld a,(de):add a:add a:add a:add a:add #06:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 6
      ld a,(de):add a:add a:add a:add a:add #07:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 7
      ld a,(de):add a:add a:add a:add a:add #08:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 8
      ld a,(de):add a:add a:add a:add a:add #09:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 9
      ld a,(de):add a:add a:add a:add a:add #0a:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 10
      ld a,(de):add a:add a:add a:add a:add #0b:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 11
      ld a,(de):add a:add a:add a:add a:add #0c:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 12
      ld a,(de):add a:add a:add a:add a:add #0d:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 13
      ld a,(de):add a:add a:add a:add a:add #0e:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 14
      ld a,(de):add a:add a:add a:add a:add #0f:ld l,a:ld (hl),a:inc de:inc de:inc de:inc de:inc de:inc de:inc de:inc de  ; X = 15

; Next hard sprite
      inc h

      dec c
      jp nz,REFRESH_HARD_SPRITE

      jp RESTORE_SP

; Fast 3 hards sprites clear 
.CLEAR_VISU

      ld hl,#0000

repeat  384     
      push hl
rend

RESTORE_SP
      ld sp,#bfe2

; Increment counter and check 120ms refresh period.      
      ld a,(REFRESH_VISU_COUNTER)
      inc a
      cp #06
      jr nz,REFRESH_VISU_END

; All 120ms, A = 0 => Refresh hards sprites contents.   
      xor a
.REFRESH_VISU_END
      ld (REFRESH_VISU_COUNTER),a

; ASIC page-out.
      ld bc,#7fa0
      out (c),c

      ret


; **********************************************
; Somes variables...
; **********************************************
PEN0_INK
      db #01,#01

PEN1_INK
      db #1a,#1a

BORDER_INK
      db #00,#00

HARDSPRITECOLOR
      db #ff,#0f
      db #ee,#0e
      db #dd,#0d
      db #cc,#0c
      db #bb,#0b
      db #aa,#0a
      db #99,#09
      db #88,#08
      db #99,#09
      db #aa,#0a
      db #bb,#0b
      db #cc,#0c
      db #dd,#0d
      db #ee,#0e
      db #ff,#0f

HARDSPRITECONFIG
      db #1c,#00,#a4,#00,#0a
      db #3c,#00,#a4,#00,#0a
      db #5c,#00,#a4,#00,#0a
      db #94,#00,#a4,#00,#0a
      db #b4,#00,#a4,#00,#0a
      db #d4,#00,#a4,#00,#0a
      db #0c,#01,#a4,#00,#0a
      db #2c,#01,#a4,#00,#0a
      db #4c,#01,#a4,#00,#0a

.TXT_EDIT_SMP_POSITION
      dw #C2B2  ; Position TXT_EDIT_SMP
.TXT_EDIT_PAT_POSITION
      dw &c302  ; Position TXT_EDIT_PAT
.TXT_PLAY_PAT_POSITION
      dw &c352  ; Position TXT_PLAY_PAT
.TXT_PLAY_SNG_POSITION
      dw &c3a2  ; Position TXT_PLAY_SNG
.TXT_CONV_MOD_POSITION
      dw &c3f2  ; Position TXT_CONV_MOD
.TXT_CONV_SMP_POSITION
      dw &c442  ; Position TXT_CONV_SMP
.TXT_SAVE_UKM_POSITION
      dw #C492  ; Position TXT_SAVE_UKM
.TXT_SAVE_UKX_POSITION
      dw #C4E2  ; Position TXT_SAVE_UKX
.TXT_MISC_OPT_POSITION
      dw #C532  ; Position TXT_MISC_OPT
.TXT_EDIT_SNG_POSITION
      dw &c582  ; Position TXT_EDIT_SNG
.CHANA_TXT_TRACK_POSITION
      dw #c004  ; Position TXT_TRACK A
.CHANB_TXT_TRACK_POSITION
      dw #c013  ; Position TXT_TRACK B
.CHANC_TXT_TRACK_POSITION
      dw #c022  ; Position TXT_TRACK C
.TXT_CHANA_POSITION
      dw #c5f4  ; Position TXT_CHANA
.TXT_CHANB_POSITION
      dw #c603  ; Position TXT_CHANB
.TXT_CHANC_POSITION
      dw #c612  ; Position TXT_CHANC
.TXT_INSTRUMENT_POSITION
      dw #c0d2  ; Position TXT_INSTRUMENT
.TXT_OCTAVE_POSITION
      dw #C122  ; Position TXT_OCTAVE
.TXT_STEP_POSITION
      dw #C172  ; Position TXT_STEP
.TXT_SPEED_POSITION
      dw #C1C2  ; Position TXT_SPEED
.TXT_PATTERN_POSITION
      dw #C212  ; Position TXT_PATTERN
.l0419
      dw #c000
.l041b
      db #01
.l041c
      db #20
.l041d
      db #08
org #041e
db #32,#08,#09,#32,#08,#0a,#32,#08
db #0b,#32,#08,#0c,#32,#08,#0d,#32
db #08,#0e,#32,#08,#0f,#32,#08,#10
db #32,#08,#11,#32,#08

.l043b
      db #0a,#3c,#05
      db #0a,#01,#2f
.l0441
      db #0a,#04,#03,#0a,#08
db #01,#0a,#09,#01,#0a,#0b,#01,#0a
db #0c,#01,#0a,#0d,#01,#0a,#0f,#01
db #0a,#10,#01,#0a,#11,#01,#0a,#13
db #03,#0a,#17,#01,#0a,#18,#01,#0a
db #1a,#01,#0a,#1b,#01,#0a,#1c,#01
db #0a,#1e,#01,#0a,#1f,#01,#0a,#20
db #01,#0a,#22,#03,#0a,#26,#01,#0a
db #27,#01,#0a,#29,#01,#0a,#2a,#01
db #0a,#2b,#01,#0a,#2d,#01,#0a,#2e
db #01,#0a,#2f,#01

.l0492
      db &08
.l0493
      db &47
.CURRENT_CHANA_TRACK_NUMBER
      db #00  ; Channel A current track number
.CURRENT_CHANB_TRACK_NUMBER
      db #02  ; Channel B current track number
.CURRENT_CHANC_TRACK_NUMBER
      db #01  ; Channel C current track number
.l0497
      dw TRACK_0
.l0499
      dw TRACK_0
.l049b
      dw TRACK_2
.l049d
      dw TRACK_2
.l049f
      dw TRACK_1
.l04a1
      dw TRACK_1
.CHANA_STATE
      db #01  ; Chan A state (1 == ON)
.CHANB_STATE
      db #01  ; Chan B state (1 == ON)
.CHANC_STATE
      db #01  ; Chan C state (1 == ON)
.l04a6
      dw #9800 ; AY list address DMA0
.l04a8
      dw #9e00 ; AY list address DMA1
.l04aa
      dw #a400 ; AY list address DMA2
.REFRESH_VISU_COUNTER
      db #01
.DSCR_VALUE
      db #07  ; DSCR value
.l04ae
      db &11
.l04af
      db &2e  ; Current not played

      ds 3,0

.CURRENT_PATTERN_NUMBER
      db #01  ; Current pattern number
.CURRENT_LINE_NUMBER
      db #00  ; Current line number
.l04b5
      db #2b
.CURRENT_INSTRUMENT_NUMBER
      db #06  ; Current instrument
.CURRENT_OCTAVE
      db #03  ; Current octave
.CURRENT_LINE_STEP
      db #00  ; Line step
.CURRENT_SONG_SPEED
      db #04  ; Song speed
.SPEED_COUNTER
      db #03  ; Speed current step ( < Song speed)
.l04bb
      db #02
.l04bc
      db #0d
.l04bd
      dw &8006
.l04bf
      dw &830b
.l04c1
      dw &8309
.CHANA_SAMPLE_START_ADDR
      dw &5395  ; Channel A sample start address (compute with 9xx effect)
.l04c5
      dw &7a89
.l04c7
      dw &797d
.l04c9
      dw &705C  ; Channel A sample end address
.l04cb
      dw &5d76
.l04cd
      dw &7617
.l04cf
      db &c5    ; Channel A sample bank
.l04d0
      db &c4
.l04d1
      db &c5
.l04d2
      dw &03    ; Channel A Current note period (fixed point) played (MSB)
.l04d3
      db &00
      
.l04d4
      dw &0002
.l04d6
      dw &0001
.l04d8
      db &93    ; Channel A Current note period (fixed point) played (LSB)
.l04d9
      db &ad
.l04da
      db &97
.l04db
      db &00
.l04dc
      db &00
.l04dd
      db &00
.l04de
      db &00   

      ds 2,0
.l04e1
      db &00   ; Channel A first FX argument

      ds 2,0
.l04e4
      db &00   ; Channel A first 1xx fx

      ds 2,0
.l04e7
      db &00  ; Channel A Current 1xx fx value

      ds 2,0
.l04ea
      db &00  ; Channel A first 2xx fx

      ds 2,0
.l04ed
      db &00  ; Channel A Current 2xx fx value

      ds 2,0
.CHANA_9XX_VALUE
      db &00 ; Channel A Current 9xx fx value for sample
.CHANB_9XX_VALUE
      db &00 ; Channel B Current 9xx fx value for sample
.CHANC_9XX_VALUE
      db &00 ; Channel C Current 9xx fx value for sample
.l04f3
      db &00

.TXT_CONV_MOD
      db "Conv Mod",0
.TXT_CONV_SMP
      db "Conv Smp",0
.TXT_SAVE_UKM
      db "Save Ukm",0
.TXT_SAVE_UKX
      db "Save Ukx",0
.TXT_PLAY_PAT
      db "Play Pat",0
.TXT_PLAY_SNG
      db "Play Sng",0
.TXT_MISC_OPT
      db "Misc Opt",0
.TXT_EDIT_SMP
      db "Edit Smp",0
.TXT_EDIT_PAT
      db "Edit Pat",0
.TXT_EDIT_SNG
      db "Edit Sng",0
.TXT_INSTRUMENT
      db "Instrument :",0
.TXT_PATTERN
      db "Pattern    :",0
.TXT_STEP
      db "Step       :",0
.TXT_SPEED
      db "Speed      :",0
.TXT_OCTAVE
      db "Octave     :",0
.TXT_TRACK
      db "Track : ",0
.l0598
      db "**",0
.l059b
      db "LstPos/Pat :",0
.l05a8
      db "Lst.Sng.Len:",0
.l05b5
      db '/',0
.TXT_SONGLENGTH
      db "SngLt",0
.TEXT_ON_OFF
      db "Off",0
      db "On ",0
.TXT_CHANA
      db "Chan A : ",0
.TXT_CHANB
      db "Chan B : ",0
.TXT_CHANC
      db "Chan C : ",0
.l05e3
      db #20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20
      db #20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20
      db #20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20
      db #00


; **********************************************
;
; **********************************************
.TEXT_HEXBYTE
      db "00",0,"01",0,"02",0,"03",0,"04",0,"05",0,"06",0,"07",0,"08",0,"09",0,"0A",0,"0B",0,"0C",0,"0D",0,"0E",0,"0F",0
      db "10",0,"11",0,"12",0,"13",0,"14",0,"15",0,"16",0,"17",0,"18",0,"19",0,"1A",0,"1B",0,"1C",0,"1D",0,"1E",0,"1F",0
      db "20",0,"21",0,"22",0,"23",0,"24",0,"25",0,"26",0,"27",0,"28",0,"29",0,"2A",0,"2B",0,"2C",0,"2D",0,"2E",0,"2F",0
      db "30",0,"31",0,"32",0,"33",0,"34",0,"35",0,"36",0,"37",0,"38",0,"39",0,"3A",0,"3B",0,"3C",0,"3D",0,"3E",0,"3F",0
      db "40",0,"41",0,"42",0,"43",0,"44",0,"45",0,"46",0,"47",0,"48",0,"49",0,"4A",0,"4B",0,"4C",0,"4D",0,"4E",0,"4F",0
      db "50",0,"51",0,"52",0,"53",0,"54",0,"55",0,"56",0,"57",0,"58",0,"59",0,"5A",0,"5B",0,"5C",0,"5D",0,"5E",0,"5F",0
      db "60",0,"61",0,"62",0,"63",0,"64",0,"65",0,"66",0,"67",0,"68",0,"69",0,"6A",0,"6B",0,"6C",0,"6D",0,"6E",0,"6F",0
      db "70",0,"71",0,"72",0,"73",0,"74",0,"75",0,"76",0,"77",0,"78",0,"79",0,"7A",0,"7B",0,"7C",0,"7D",0,"7E",0,"7F",0
      db "80",0,"81",0,"82",0,"83",0,"84",0,"85",0,"86",0,"87",0,"88",0,"89",0,"8A",0,"8B",0,"8C",0,"8D",0,"8E",0,"8F",0
      db "90",0,"91",0,"92",0,"93",0,"94",0,"95",0,"96",0,"97",0,"98",0,"99",0,"9A",0,"9B",0,"9C",0,"9D",0,"9E",0,"9F",0
      db "A0",0,"A1",0,"A2",0,"A3",0,"A4",0,"A5",0,"A6",0,"A7",0,"A8",0,"A9",0,"AA",0,"AB",0,"AC",0,"AD",0,"AE",0,"AF",0
      db "B0",0,"B1",0,"B2",0,"B3",0,"B4",0,"B5",0,"B6",0,"B7",0,"B8",0,"B9",0,"BA",0,"BB",0,"BC",0,"BD",0,"BE",0,"BF",0
      db "C0",0,"C1",0,"C2",0,"C3",0,"C4",0,"C5",0,"C6",0,"C7",0,"C8",0,"C9",0,"CA",0,"CB",0,"CC",0,"CD",0,"CE",0,"CF",0
      db "D0",0,"D1",0,"D2",0,"D3",0,"D4",0,"D5",0,"D6",0,"D7",0,"D8",0,"D9",0,"DA",0,"DB",0,"DC",0,"DD",0,"DE",0,"DF",0
      db "E0",0,"E1",0,"E2",0,"E3",0,"E4",0,"E5",0,"E6",0,"E7",0,"E8",0,"E9",0,"EA",0,"EB",0,"EC",0,"ED",0,"EE",0,"EF",0
      db "F0",0,"F1",0,"F2",0,"F3",0,"F4",0,"F5",0,"F6",0,"F7",0,"F8",0,"F9",0,"FA",0,"FB",0,"FC",0,"FD",0,"FE",0,"FF",0


; **********************************************
;
; **********************************************
.TEXT_HEXNIBBLE
      db "0",0,"1",0,"2",0,"3",0,"4",0,"5",0,"6",0,"7",0,"8",0,"9",0,"A",0,"B",0,"C",0,"D",0,"E",0,"F",0


; **********************************************
;
; **********************************************
.TXT_NOTE
      db "---",0
      db "C-1",0,"C#1",0,"D-1",0,"D#1",0,"E-1",0,"F-1",0,"F#1",0,"G-1",0,"G#1",0,"A-1",0,"A#1",0,"B-1",0
      db "C-2",0,"C#2",0,"D-2",0,"D#2",0,"E-2",0,"F-2",0,"F#2",0,"G-2",0,"G#2",0,"A-2",0,"A#2",0,"B-2",0
      db "C-3",0,"C#3",0,"D-3",0,"D#3",0,"E-3",0,"F-3",0,"F#3",0,"G-3",0,"G#3",0,"A-3",0,"A#3",0,"B-3",0
      db "C-4",0,"C#4",0,"D-4",0,"D#4",0,"E-4",0,"F-4",0,"F#4",0,"G-4",0,"G#4",0,"A-4",0,"A#4",0,"B-4",0
      db "C-5",0,"C#5",0,"D-5",0,"D#5",0,"E-5",0,"F-5",0,"F#5",0,"G-5",0,"G#5",0,"A-5",0,"A#5",0,"B-5",0
      db "Res",0


; **********************************************
;
; **********************************************
.l0a2c     
      call l0aff
      ret


; **********************************************
; Update player
; **********************************************
.l0a30

; Wait 20ms.
      ld e,#01
      call WAIT_X_VBL

; Update DMA channels (address and states).
      call UPDATE_DMA

; Increment speed counter.
      ld hl,SPEED_COUNTER
      inc (hl)
      
; Time to update note ?       
      ld a,(CURRENT_SONG_SPEED)
      cp (hl)
      jp z,UPDATE_NOTE_TO_PLAY

      call l0a66

      jp UPDATE_SAMPLE_TO_PLAY

; Update note
.UPDATE_NOTE_TO_PLAY

      call l0b31
      
; Increment line number      
      ld a,(CURRENT_LINE_NUMBER)
      inc a
      and #3f
      ld (CURRENT_LINE_NUMBER),a

; Reset speed counter.      
      xor a
      ld (SPEED_COUNTER),a

; Update sample
.UPDATE_SAMPLE_TO_PLAY

      call SWAP_DMA_BUFFER
      call UPDATE_AY_LISTS
      call REFRESH_CHAN_VISU

      ret


; **********************************************
; Padding
; **********************************************
      ds 3,0
      
; **********************************************
;
; **********************************************
.l0a66
      ld a,(l04de)
      or a
      jp z,l0ab3

      ld a,(l04f3)
.l0a70
      sub #03
      jp z,l0a7b

      jp m,l0a80

      jp l0a70

.l0a7b
      ld b,#00
      jp l0a99

.l0a80
      add #02
      or a
      jp nz,l0a93

      ld a,(l04e1)
      rra
      rra
      rra
      rra
      and #0f
      ld b,a
      jp l0a99

.l0a93
      ld a,(l04e1)
      and #0f
      ld b,a
.l0a99
      ld a,(l04af)
      add b
      ld l,a
      ld h,#00
      dec hl
      add hl,hl
      ld bc,SAMPLE_PERIOD
      add hl,bc

; Save current period (fixed point).      
      ld a,(hl)
      ld (l04d8),a
      inc hl
      ld a,(hl)
      ld (l04d2),a

      xor a
      ld (l04db),a
.l0ab3
      ld a,(l04e4)
      or a
      jp z,l0ad8

      ld a,(l04f3)
      or a
      jp z,l0ad8

      
; HL = fixed point period interpolation.
      ld a,(l04d2)
      ld h,a
      ld a,(l04d8)
      ld l,a

      ld a,(l04e7)
      ld e,a
      ld d,#00
      add hl,de

      ld a,h
      ld (l04d2),a
      ld a,l
      ld (l04d8),a
.l0ad8
      ld a,(l04ea)
      or a
      jp z,l0afe

      ld a,(l04f3)
      or a
      jp z,l0afe

      ld a,(l04d2)
      ld h,a
      ld a,(l04d8)
      ld l,a
      ld a,(l04ed)
      ld c,a
      ld b,#00
      sbc hl,bc
      ld a,h
      ld (l04d2),a
      ld a,l
      ld (l04d8),a
.l0afe
      ret


; **********************************************
;
; **********************************************
.l0aff

; Initialize speed counter.  
      xor a
      ld (SPEED_COUNTER),a

      call l108d

      call l1100

      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      call l107a

      ld (l0497),hl
      ld (l0499),hl
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      call l107a

      ld (l049b),hl
      ld (l049d),hl
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      call l107a

      ld (l049f),hl
      ld (l04a1),hl
      call UPDATE_DSCR

      ret


; **********************************************
;
; **********************************************
.l0b31
      ld a,#00
      ld (l04de),a
      ld (l04e4),a
      ld (l04ea),a

; Get current line number 
      ld a,(CURRENT_LINE_NUMBER)
      ld c,a
      ld b,#00
      ld l,c
      ld h,b
      
; Get pointer to current track info on channel A      
      ld de,(l0497)
      
; Compute current line position (1 line = 5 bytes)  
      add hl,hl
      add hl,hl
      add hl,bc
      add hl,de
      push hl

; IX point to current line.
      pop ix

; Reset 9xx fx value.
      xor a
      ld (CHANA_9XX_VALUE),a

; Is no music note ?
      ld a,(ix+#00)
      or a
      jp z,l0cb1

; Is NOT 'Res' ?
      and #3f
      cp #3d
      jp nz,l0b6a

; Set no sound volume table (&07).
      ld hl,#8300
      ld (l04bd),hl

; Next channel
      jp l0ce1

.l0b6a

; Reset volume table (normal value &00-&0d).
      ld hl,#8700
      ld de,#8000
repeat 16
      ldi
rend

; Get note.
      ld a,(ix+#00)
      and #3f
      ld (l04af),a
      
; Get corresponding period increment (fixed point).
      ld l,a
      ld h,#00
      dec hl
      add hl,hl
      ld bc,SAMPLE_PERIOD
      add hl,bc
      ld a,(hl)
      ld (l04d8),a
      inc hl
      ld a,(hl)
      ld (l04d2),a
      xor a
      ld (l04db),a
.l0bb7

; 
      ld a,(ix+#00)
      bit 6,a
      jp z,l0c53


; If 1st FX (1xx-Fxx)
      ld a,(ix+#02)
      and #f0
      or a
      jp nz,l0bdc

; if no 1st FX 0xx
      or (ix+#03)
      jp z,l0bdc

      ld a,#01
      ld (l04de),a

      ld a,(ix+#03)
      ld (l04e1),a

      jp l0c53

; 1st FX 1xx
.l0bdc
      cp #10
      jp nz,l0bef

      ld a,#01
      ld (l04e4),a
      ld a,(ix+#03)
      ld (l04e7),a
      jp l0c53

; 1st FX 2xx
.l0bef
      cp #20
      jp nz,l0c02

      ld a,#01
      ld (l04ea),a
      ld a,(ix+#03)
      ld (l04ed),a
.l0bff
      jp l0c53

; 1st FX Fxx
.l0c02
      cp #f0
      jp nz,l0c10

; Get and save argument
      ld a,(ix+#03)
      ld (CURRENT_LINE_STEP),a

      jp l0c53

; 1st FX Cxx
.l0c10
      cp #c0
      jp nz,l0c48

; Get argument, compute and set volume LUT. 
      ld l,(ix+#03)
      ld h,#00
      ld bc,#8300
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld de,#8000
      
repeat 16
      ldi
rend
      jp l0c53

; 1st FX 9xx
.l0c48
      cp #90
      jp nz,l0c53

; Get and save argument
      ld a,(ix+#03)
      ld (CHANA_9XX_VALUE),a
      
; ?
.l0c53
      ld a,(ix+#00)
      bit 7,a
      jp z,l0cb1

; 2nd FX Fxx
      ld a,(ix+#02)
      and #0f
      cp #0f
      jp nz,l0c6e

; Get and save argument
      ld a,(ix+#04)
      ld (CURRENT_SONG_SPEED),a

      jp l0cb1

; 2nd FX Cxx
.l0c6e
      cp #0c
      jp nz,l0ca6

; Get argument, compute and set volume LUT. 
      ld l,(ix+#04)
      ld h,#00
      ld bc,#8300
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld de,#8000     
repeat 16
      ldi
rend
      jp l0cb1

; 2nd FX 9xx
.l0ca6
      cp #09
      jp nz,l0cb1

; Get and save argument.
      ld a,(ix+#04)
      ld (CHANA_9XX_VALUE),a

.l0cb1

; If NO instrument
      ld a,(ix+#01)
      or a
      jp z,l0ce1

; Get sample info (9 bytes) for this instrument.
      dec a
      ld l,a
      ld h,#00
      ld b,h
      ld c,l
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld bc,SAMPLE_INFO
      add hl,bc

; BC = start of sample.
      ld c,(hl)
      inc hl
      ld b,(hl)
      inc hl

; A = sample bank.
      ld a,(hl)
      inc hl
      ld (l04cf),a

; HL = sample length.
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
      
; Compute end sample address.      
      add hl,bc
      ld (l04c9),hl

; Add offset from effect 9xx      
      ld a,(CHANA_9XX_VALUE)
      ld h,a
      ld l,#00
      add hl,bc
      ld (CHANA_SAMPLE_START_ADDR),hl

.l0ce1

; Compute current line number info address.
      ld a,(CURRENT_LINE_NUMBER)
      ld c,a
      ld b,#00
      ld l,c
      ld h,b

; Get pointer to current track info on channel B
      ld de,(l049b)

      add hl,hl
      add hl,hl
      add hl,bc
      add hl,de
      push hl
      pop ix

; Reset 9xx fx value.      
      xor a
      ld (CHANB_9XX_VALUE),a

; If NO note
      ld a,(ix+#00)
      or a
      jp z,l0e05
      
      ld hl,#8700
      ld de,#8100

repeat 16
      ldi
rend

      ld a,(ix+#00)
      and #3f
      or a
      jp z,l0d49

      ld a,(ix+#00)
      and #3f
      ld l,a
      ld h,#00
      dec hl
      add hl,hl
      ld bc,SAMPLE_PERIOD
      add hl,bc
      ld a,(hl)
      ld (l04d9),a
      inc hl
      ld a,(hl)
      ld (l04d4),a
      xor a
      ld (l04dc),a
.l0d49
      ld a,(ix+#00)
      bit 6,a
      jp z,l0da7

      ld a,(ix+#02)
      and #f0
      cp #f0
      jp nz,l0d64

      ld a,(ix+#03)
      ld (CURRENT_SONG_SPEED),a
      jp l0da7

.l0d64
      cp #c0
      jp nz,l0d9c

      ld l,(ix+#03)
      ld h,#00
      ld bc,#8300
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld de,#8100

repeat 16
      ldi
rend
      
      jp l0da7

.l0d9c
      cp #90
      jp nz,l0da7
      ld a,(ix+#03)
      ld (CHANB_9XX_VALUE),a
.l0da7
      ld a,(ix+#00)
      bit 7,a
      jp z,l0e05

      ld a,(ix+#02)
      and #0f
      cp #0f
      jp nz,l0dc2

      ld a,(ix+#04)
      ld (CURRENT_SONG_SPEED),a
      jp l0e05

.l0dc2
      cp #0c
      jp nz,l0dfa
      ld l,(ix+#04)
      ld h,#00
      ld bc,#8300
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld de,#8100
      
repeat 16
      ldi
rend
      
      jp l0e05

.l0dfa
      cp #09
      jp nz,l0e05

      ld a,(ix+#04)
      ld (CHANB_9XX_VALUE),a
.l0e05
      ld a,(ix+#01)
.l0e08
      or a
      jp z,l0e35

      dec a
      ld l,a
      ld h,#00
      ld b,h
      ld c,l
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld bc,SAMPLE_INFO
      add hl,bc
      ld c,(hl)
      inc hl
      ld b,(hl)
      inc hl
      ld a,(hl)
      inc hl
      ld (l04d0),a
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
      add hl,bc
      ld (l04cb),hl
      ld a,(CHANB_9XX_VALUE)
      ld h,a
      ld l,#00
      add hl,bc
      ld (l04c5),hl
.l0e35
      ld a,(CURRENT_LINE_NUMBER)
      ld c,a
      ld b,#00
      ld l,c
      ld h,b
      ld de,(l049f)
      add hl,hl
      add hl,hl
      add hl,bc
      add hl,de
      push hl
      pop ix

; Reset 9xx value.
      xor a
      ld (CHANC_9XX_VALUE),a

      ld a,(ix+#00)
      or a
      jp z,l0f59

      ld hl,#8700
      ld de,#8200
repeat 16
      ldi
rend
      ld a,(ix+#00)
      and #3f
      or a
      jp z,l0e9d

      ld a,(ix+#00)
      and #3f
      ld l,a
      ld h,#00
      dec hl
      add hl,hl
      ld bc,SAMPLE_PERIOD
      add hl,bc
      ld a,(hl)
      ld (l04da),a
      inc hl
      ld a,(hl)
      ld (l04d6),a
      xor a
      ld (l04dd),a
.l0e9d
      ld a,(ix+#00)
      bit 6,a
      jp z,l0efb

      ld a,(ix+#02)
      and #f0
      cp #f0
      jp nz,l0eb8

      ld a,(ix+#03)
      ld (CURRENT_SONG_SPEED),a
      jp l0efb

.l0eb8
      cp #c0
      jp nz,l0ef0

      ld l,(ix+#03)
      ld h,#00
      ld bc,#8300
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld de,#8200
repeat 16
      ldi
rend
      jp l0efb

.l0ef0
      cp #90
      jp nz,l0efb

      ld a,(ix+#03)
      ld (CHANC_9XX_VALUE),a
.l0efb
      ld a,(ix+#00)
      bit 7,a
      jp z,l0f59

      ld a,(ix+#02)
      and #0f
.l0f08
      cp #0f
.l0f0a
      jp nz,l0f16
      ld a,(ix+#04)
      ld (CURRENT_SONG_SPEED),a
      jp l0f59

.l0f16
      cp #0c
      jp nz,l0f4e

      ld l,(ix+#04)
      ld h,#00
      ld bc,#8300
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld de,#8200
repeat 16
      ldi
rend
      jp l0f59

.l0f4e
      cp #09
      jp nz,l0f59

      ld a,(ix+#04)
      ld (CHANC_9XX_VALUE),a
.l0f59
      ld a,(ix+#01)
      or a
      jp z,l0f89

      dec a
      ld l,a
      ld h,#00
      ld b,h
      ld c,l
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      ld bc,SAMPLE_INFO
      add hl,bc
      ld c,(hl)
      inc hl
      ld b,(hl)
      inc hl
      ld a,(hl)
      inc hl
      ld (l04d1),a
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
      add hl,bc
      ld (l04cd),hl
      ld a,(CHANC_9XX_VALUE)
      ld h,a
      ld l,#00
      add hl,bc
      ld (l04c7),hl
.l0f89
      ret


; **********************************************
;
; **********************************************
.UPDATE_DSCR

; Initialize DSCR value
      ld b,#00

; If channel A OFF
      ld a,(CHANA_STATE)
      or a
      jp z,l0f95

      set 0,b

; If channel B OFF
.l0f95
      ld a,(CHANB_STATE)
      or a
      jp z,l0f9e

      set 1,b

; If channel C OFF
.l0f9e
      ld a,(CHANC_STATE)
      or a
      jp z,l0fa7

      set 2,b

; Save DCSR
.l0fa7
      ld a,b
      ld (DSCR_VALUE),a

      ret


; **********************************************
;
; **********************************************
.l0fac

; Wait 20ms.
      ld e,#01
      call WAIT_X_VBL

; Update DMA configuration.
      call UPDATE_DMA

; Update DMA buffer.
      call SWAP_DMA_BUFFER

; Update AY list.
      call UPDATE_AY_LISTS

      ret


; **********************************************
; Upate/compute AY list
; **********************************************
.UPDATE_AY_LISTS

; Select memory bank which contain sample played on Channel A
      ld a,(l04cf)
      ld c,a
      ld b,#7f
      out (c),c

      exx
      ld de,(l04a6)
      ld bc,#8000
      ld hl,(l04c9)
      exx
      ld hl,(CHANA_SAMPLE_START_ADDR)
      ld bc,(l04d2)
      ex af,af'
      ld a,(l04db)
      ex af,af'
      ld a,(l04d8)
      ld e,a
      call #8800
      ld (CHANA_SAMPLE_START_ADDR),hl
      exx
      ld (l04bd),bc
      exx

; Select memory bank which contain sample played on Channel B
      ld a,(l04d0)
      ld c,a
      ld b,#7f
      out (c),c

      exx
      ld de,(l04a8) ; DMA1 AY list 
      ld bc,#8100
      ld hl,(l04cb) ; Sample address
      exx
      ld hl,(l04c5)
      ld bc,(l04d4)
      ex af,af'
      ld a,(l04dc)
      ex af,af'
      ld a,(l04d9)
      ld e,a
      call #8800
      ld (l04c5),hl
      exx
      ld (l04bf),bc
      exx

; Select memory bank which contain sample played on Channel C
      ld a,(l04d1)
      ld c,a
      ld b,#7f
      out (c),c

      exx
      ld de,(l04aa) ; DMA2 AY list 
      ld bc,#8200
      ld hl,(l04cd) ; Sample address
      exx
      ld hl,(l04c7)
      ld bc,(l04d6)
      ex af,af'
      ld a,(l04dd)
      ex af,af'
      ld a,(l04da)
      ld e,a
      call #8800
      ld (l04c7),hl
      exx
      ld (l04c1),bc
      exx

; Select main RAM
      ld bc,#7fc0
      out (c),c

      ret


; **********************************************
; Swap DMAs buffer
; **********************************************
.SWAP_DMA_BUFFER

; Swapping
      ld a,#00
      xor #01
      ld (SWAP_DMA_BUFFER + 1),a
      jr z,l1065

      ld bc,#a100
      ld hl,#9b00
      ld de,#9500
      jr l106e

.l1065
      ld de,#9800
      ld hl,#9e00
      ld bc,#a400

.l106e
      ld (l04a6),de
      ld (l04a8),hl
      ld (l04aa),bc
      ret


; **********************************************
;
; **********************************************
.l107a
      ld l,a
      ld h,#00
      ld e,l
      ld d,h
      add hl,hl
      add hl,hl
      add hl,de
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ld de,TRACK_0
      add hl,de
      ret


; **********************************************
;
; **********************************************
.l108d
      ld hl,#8300
      ld de,#8000

repeat 16
      ldi
rend

      ld hl,#8300
      ld de,#8100

repeat 16
      ldi
rend

      ld hl,#8300
      ld de,#8200

repeat 16
      ldi
rend
      ret


; **********************************************
;  Initialize DMA buffer with default value
; **********************************************
.l1100
      ld hl,(l04a6) ; HL = AY list address DMA0
      ld de,(l04a8) ; DE = AY list address DMA1
      ld bc,(l04aa) ; BC = AY list address DMA2
      ld a,#07      ; default value 07
      ex af,af'
      ld a,156
.l1110
      ex af,af'
      ld (hl),a
      ld (bc),a
      ld (de),a
      inc hl:inc hl:inc hl:inc hl
      inc bc:inc bc:inc bc:inc bc
      inc de:inc de:inc de:inc de
      ex af,af'
      dec a
      jr nz,l1110
      ex af,af'
      ret


; **********************************************
;
; **********************************************
.l1126

; Wait 60ms
      ld e,#03
      call WAIT_X_VBL

; Test function keys
      call l1adf

; Select keys line &40
      ld d,#40
      call TEST_KEYS

; Cursor UP
      bit 0,a
      jp z,l114f

; Cursor RIGHT
      bit 1,a
      jp z,l1177

; Cursor DOWN
      bit 2,a
      jp z,l1163

; Select keys line
      ld d,#41
      call TEST_KEYS

;  Cursor LEFT
      bit 0,a
      jp z,l1191

      jp l1126

.l114f
      ld a,(l4def)
      dec a
      ld (l4def),a

      xor a
      ld de,l043b
      call l1e1a

      call l11ab

      jp l1126

.l1163
      ld a,(l4def)
      inc a
      ld (l4def),a

      xor a
      ld de,l043b
      call l1e1a

      call l11ab

      jp l1126

.l1177
      ld a,(l4def)
      ld c,a
      ld b,#00
      ld hl,#22df
      add hl,bc
      ld a,(hl)
      inc a
      ld (hl),a

      xor a
      ld de,l043b
      call l1e1a

      call l11ab

      jp l1126

.l1191
      ld a,(l4def)
      ld c,a
      ld b,#00
      ld hl,#22df
      add hl,bc
      ld a,(hl)
      dec a
      ld (hl),a

      xor a
      ld de,l043b

      call l1e1a

      call l11ab

      jp l1126


; **********************************************
;
; **********************************************
.l11ab
      ld a,(l4def)
      ld (l0492),a
      ld de,#c35c
      ex af,af'
      ld a,#08
.l11b7
      ex af,af'
      ld c,a
      ld b,#00
      ld l,a
      ld h,b
      add hl,hl
      add hl,bc
      ld bc,TEXT_HEXBYTE
      add hl,bc
      call DISPLAY_STRING

      inc de
      ld a,(l0492)
      ld c,a
      ld b,#00
      ld hl,#22df
      add hl,bc
      ld a,(hl)
      ld c,a
      ld b,#00
      ld l,a
      ld h,b
      add hl,hl
      add hl,bc
      ld bc,TEXT_HEXBYTE
      add hl,bc
      call DISPLAY_STRING

      ld a,(l0492)
      inc a
      ld (l0492),a
      ex de,hl
      ld de,75
      add hl,de
      ex de,hl
      ex af,af'
      dec a
      jp nz,l11b7

      ex af,af'
      xor a
      ld de,l043b
      call l1e1a

      ret


; **********************************************
; 
; **********************************************
.l11fb

; Display current instrument
      ld hl,TXT_INSTRUMENT                        ; Text to display
      ld de,(TXT_INSTRUMENT_POSITION)             ; Screen position
      ld a,(CURRENT_INSTRUMENT_NUMBER)            ; Value to display
      call DISPLAY_WITH_NUMBER

; Display current octave
      ld hl,TXT_OCTAVE
      ld de,(TXT_OCTAVE_POSITION)
      ld a,(CURRENT_OCTAVE)
      call DISPLAY_WITH_NUMBER

; Display current line step
      ld hl,TXT_STEP
      ld de,(TXT_STEP_POSITION)
      ld a,(CURRENT_LINE_STEP)
      call DISPLAY_WITH_NUMBER

; Display current song speed
      ld hl,TXT_SPEED
      ld de,(TXT_SPEED_POSITION)
      ld a,(CURRENT_SONG_SPEED)
      call DISPLAY_WITH_NUMBER

; Display current pattern number
      ld hl,TXT_PATTERN
      ld de,(TXT_PATTERN_POSITION)
      ld a,(CURRENT_PATTERN_NUMBER)
      call DISPLAY_WITH_NUMBER

; Display current Channel A track number
      ld hl,TXT_TRACK
      ld de,(CHANA_TXT_TRACK_POSITION)
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      call DISPLAY_WITH_NUMBER

; Display current Channel B track number
      ld hl,TXT_TRACK
      ld de,(CHANB_TXT_TRACK_POSITION)
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      call DISPLAY_WITH_NUMBER

; Display current Channel C track number
      ld hl,TXT_TRACK
      ld de,(CHANC_TXT_TRACK_POSITION)
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      call DISPLAY_WITH_NUMBER

; Display Channel A state (on/off)
      ld hl,TXT_CHANA
      ld de,(TXT_CHANA_POSITION)
      ld a,(CHANA_STATE)
      call DISPLAY_WITH_ONOFF

; Display Channel A state (on/off)
      ld hl,TXT_CHANB
      ld de,(TXT_CHANB_POSITION)
      ld a,(CHANB_STATE)
      call DISPLAY_WITH_ONOFF

; Display Channel A state (on/off)
      ld hl,TXT_CHANC
      ld de,(TXT_CHANC_POSITION)
      ld a,(CHANC_STATE)
      call DISPLAY_WITH_ONOFF
      ret

; **********************************************
;
; **********************************************
.DISPLAY_WITH_NUMBER

      
      push af
      call DISPLAY_STRING
 
      inc de
      pop af

      ; HL = A*3
      ld l,a
      ld h,#00
      ld c,a
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,TEXT_HEXBYTE  ; +A*3
      add hl,bc
      call DISPLAY_STRING

      ret

; **********************************************
;
; **********************************************
.DISPLAY_WITH_ONOFF

      push af
      call DISPLAY_STRING

      pop af
      ld l,a
      ld h,#00
      add hl,hl
      add hl,hl
      ld bc,TEXT_ON_OFF
      add hl,bc
      call DISPLAY_STRING

      ret


; **********************************************
;
; **********************************************
.l12b2
; Display/Update current pattern.
      call DISPLAY_PATTERN
      
      ld a,(l04bc)
      ld de,l0441
      call l1e1a

.l12be

      ld e,#02
      call WAIT_X_VBL

      call l1adf

; Select keys line &49
      ld d,#49
      call TEST_KEYS

; DEL ?      
      ld hl,#0100
      rla
      jp nc,l1541

; Select keys line &48
      dec d
      call TEST_KEYS

; Z ?      
      ld hl,#02ff
      rla
      jp nc,l14b5

; CAPSLOCK ?
      ld h,#3e
      rla
      jp nc,l14b5

; A ?
      ld hl,#020a
      rla
      jp nc,l14b5

; Q ?
      ld hl,#0eff
      rla
      rla
      jp nc,l14b5

; ESC ?
      rla
      jp nc,l1416

; 2 ?
      ld hl,#0f02
      rla
      jp nc,l14b5

; 1 ?
      ld hl,#0001
      rla
      jp nc,l14b5

; Select keys line &47
      dec d
      call TEST_KEYS

; X ?
      ld hl,#04ff
      rla
      jp nc,l14b5

; C ?
      ld hl,#060c
      rla
      jp nc,l14b5

; D ?
      ld hl,#050d
      rla
      jp nc,l14b5

; S ?
      ld hl,#03ff
      rla
      jp nc,l14b5

; W ?
      ld h,#10
      rla
      jp nc,l14b5

; E ?
      ld hl,#120e
      rla
      jp nc,l14b5

; 3 ?
      ld hl,#1103
      rla
      jp nc,l14b5

; 4 ?
      ld hl,#0004
      rla
      jp nc,l14b5

; Select keys line &46
      dec d
      call TEST_KEYS

; V ?
      ld hl,#07ff
      rla
      jp nc,l14b5

; B ?
      ld hl,#090b
      rla
      jp nc,l14b5

; F ?
      ld hl,#000f
      rla
      jp nc,l14b5

; G ?
      ld hl,#08ff
      rla
      jp nc,l14b5

; T ?
      ld h,#15
      rla
      jp nc,l14b5

; R ?
      ld h,#13
      rla
      jp nc,l14b5

; 5 ?
      ld hl,#1405
      rla
      jp nc,l14b5

; 6 ?
      ld hl,#1606
      rla
      jp nc,l14b5

; Select keys line &45
      dec d
      call TEST_KEYS

; N ?
      ld hl,#0bff
      rla
      rla
      jp nc,l14b5

; J ?
      inc h
      rla
      jp nc,l14b5

; H ?
      ld h,#0a
      rla
      jp nc,l14b5

; Y ?
      ld h,#17
      rla
      jp nc,l14b5

; U ?
      ld h,#19
      rla
      jp nc,l14b5

; 7 ?
      ld hl,#1807
      rla
      jp nc,l14b5

; 8 ?
      ld hl,#0008
      rla
      jp nc,l14b5

; Select keys line &44
      dec d
      call TEST_KEYS

; , ?
      ld hl,#0eff
      rla
      jp nc,l14b5

; M ?
      ld h,#0d
      rla
      jp nc,l14b5

; L ?
      ld h,#0f
      rla
      rla
      jp nc,l14b5

; I ?
      ld h,#1a
      rla
      jp nc,l14b5

; O ?
      ld h,#1c
      rla
      jp nc,l14b5

; 9 ?
      ld hl,#1b09
      rla
      jp nc,l14b5

; 0 ?
      ld hl,#1d00
      rla
      jp nc,l14b5

; Select keys line &43
      dec d
      call TEST_KEYS

; . ?
      ld hl,#10ff
      rla
      jp nc,l14b5

; / ?
      ld h,#12
      rla
      jp nc,l14b5

; twopoint ?
      ld h,#11
      rla
      jp nc,l14b5

; P ?
      ld h,#1e
      rla
      rla
      jp nc,l14b5

; Select keys line &41
      dec d
      dec d
      call TEST_KEYS

; CURLEFT ?
      rra
      jp nc,l1468

; Select keys line &40
      dec d
      call TEST_KEYS

; CURUP ?
      rra
      jp nc,l1422

; CURRIGHT ?
      rra
      jp nc,l148d

; CURDOWN ?
      rra
      jp nc,l1445

      jp l12be


; **********************************************
;
; **********************************************
.l1416
      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      jp l1a42


; **********************************************
;
; **********************************************
.l1422
      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      ld e,#01

; Select keys line
      ld d,#42
      call TEST_KEYS

      bit 7,a
      jp nz,l1439

      ld e,#08
.l1439
      ld a,(CURRENT_LINE_NUMBER)
      sub e
      and #3f
      ld (CURRENT_LINE_NUMBER),a
      jp l12b2


; **********************************************
;
; **********************************************
.l1445
      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      ld e,#01

; Select keys line
      ld d,#42
      call TEST_KEYS

      bit 7,a
      jp nz,l145c

      ld e,#08
.l145c
      ld a,(CURRENT_LINE_NUMBER)
      add e
      and #3f
      ld (CURRENT_LINE_NUMBER),a
      jp l12b2


; **********************************************
;
; **********************************************
.l1468
      ld a,(l04bc)
      ld de,l0441
      call l1e1a
      
      ld e,#01

; Select keys line
      ld d,#42
      call TEST_KEYS

      bit 7,a
      jp nz,l147f

      ld e,#09

.l147f
      ld a,(l04bc)
      sub e
      jp p,l1487

      xor a
.l1487
      ld (l04bc),a
      jp l12b2


; **********************************************
;
; **********************************************
.l148d
      ld a,(l04bc)
      ld de,l0441
      call l1e1a
      
      ld e,#01

; Select keys line
      ld d,#42
      call TEST_KEYS

      bit 7,a
      jp nz,l14a4
 
      ld e,#09
.l14a4
      ld a,(l04bc)
      add e
      cp #1b
      jp m,l14af

      ld a,#1a
.l14af
      ld (l04bc),a
      jp l12b2


; **********************************************
;
; **********************************************
.l14b5
      ld a,d
      ld (l0493),a

      ld a,(l04bc)
      or a
      call z,l163e

      dec a
      call z,l169d

      dec a
      call z,l16d5

      dec a
      call z,l1706

      dec a
      call z,l1746

      dec a
      call z,l1788

      dec a
      call z,l17c2

      dec a
      call z,l17fa

      dec a
      call z,l183e

      dec a
      call z,l163e

      dec a
      call z,l169d

      dec a
      call z,l16d5

      dec a
      call z,l1706

      dec a
      call z,l1746

      dec a
      call z,l1788

      dec a
      call z,l17c2

      dec a
      call z,l17fa

      dec a
      call z,l183e

      dec a
      call z,l163e

      dec a
      call z,l169d

      dec a
      call z,l16d5

      dec a
      call z,l1706

      dec a
      call z,l1746

      dec a
      call z,l1788

      dec a
      call z,l17c2

      dec a
      call z,l17fa

      dec a
      call z,l183e

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      ld a,(CURRENT_LINE_NUMBER)
      ld c,a
      ld a,(CURRENT_LINE_STEP)
      add c
      and #3f
      ld (CURRENT_LINE_NUMBER),a
      jp l12b2


; **********************************************
;
; **********************************************
.l1541
      ex af,af'
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ex af,af'
      ld a,(l04bc)
      or a
      call z,l15d8

      dec a
      call z,l15d8

      dec a
      call z,l15d8

      dec a
      call z,l15e8

      dec a
      call z,l15e8

      dec a
      call z,l15e8

      dec a
      call z,l15fc

      dec a
      call z,l15fc

      dec a
      call z,l15fc

      ex af,af'
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ex af,af'
      dec a
      call z,l15d8

      dec a
      call z,l15d8

      dec a
      call z,l15d8

      dec a
      call z,l15e8

      dec a
      call z,l15e8

      dec a
      call z,l15e8

      dec a
      call z,l15fc

      dec a
      call z,l15fc

      dec a
      call z,l15fc

      ex af,af'
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ex af,af'
      dec a
      call z,l15d8

      dec a
      call z,l15d8

      dec a
      call z,l15d8

      dec a
      call z,l15e8

      dec a
      call z,l15e8

      dec a
      call z,l15e8

      dec a
      call z,l15fc

      dec a
      call z,l15fc

      dec a
      call z,l15fc

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      ld a,(CURRENT_LINE_NUMBER)
      ld c,a
      ld a,(CURRENT_LINE_STEP)
      add c
      and #3f
      ld (CURRENT_LINE_NUMBER),a
      jp l12b2


; **********************************************
;
; **********************************************
.l15d8
      ex af,af'
      ld c,a
      ex af,af'
      call l1d4a

      ld a,(hl)
      and #c0
      ld (hl),a
      inc hl

      ld (hl),#00
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l15e8
      ex af,af'
      ld c,a
      ex af,af'
      call l1d4a

      res 6,(hl)
      inc hl
      inc hl
      ld a,(hl)
      and #0f
      ld (hl),a
      inc hl
      ld (hl),#00
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l15fc
      ex af,af'
      ld c,a
      ex af,af'
      call l1d4a

      res 7,(hl)
      inc hl
      inc hl
.l1606
      ld a,(hl)
      and #f0
      ld (hl),a
      inc hl
      inc hl
      ld (hl),#00
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l1611
      dec a
      ex af,af'
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      or a
      jr z,l162c

      ld c,l
      cp #09
      jr z,l162c

      ld c,b
.l162c
      call l1d4a

      ex af,af'
      ld (hl),a
      inc hl
      xor a
      ld (hl),a
      inc hl
      ld (hl),a
      inc hl
      ld (hl),a
      inc hl
      ld (hl),a
      inc hl
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l163e
      ld a,h
      or a
      ret z

      cp #3e
      jp z,l1611

      ld a,h
      dec a
      ld (l04ae),a
      ld c,a
      ld a,(CURRENT_OCTAVE)
      dec a
      add a
      add a
      ld b,a
      add a
      add b
      add c
      cp #3d
      ret p

      ex af,af'
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      or a
      jr z,l1673

      ld c,l
      cp #09
      jr z,l1673

      ld c,b
.l1673
      call l1d4a

      ld a,(hl)
      and #c0
      ld c,a
      ex af,af'
      or c
      ld (hl),a
      inc hl
      ld a,(CURRENT_INSTRUMENT_NUMBER)
      ld (hl),a
      call l0aff

      call l0b31

.l1688
      ld a,(l0493)
      ld d,a
      call TEST_KEYS

      cp #ff
      jp z,l169a

      call l0fac

      jp l1688

.l169a
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l169d
      ld a,#ff
      cp l
      ret z

      ex de,hl
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      dec a
      jr z,l16bb

      ld c,l
      cp #09
      jr z,l16bb

      ld c,b
.l16bb
      ex af,af'
      ld a,e
      ex af,af'
      call l1d4a

      ex af,af'
      ld e,a
      ex af,af'
      inc hl
      ld a,(hl)
      and #0f
      sla e
      sla e
      sla e
      sla e
      or e
      ld (hl),a
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l16d5
      ld a,#ff
      cp l
      ret z

      ex de,hl
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      cp #02
      jr z,l16f4

      ld c,l
      cp #0b
      jr z,l16f4

      ld c,b
.l16f4
      ex af,af'
      ld a,e
      ex af,af'
      call l1d4a
 
      ex af,af'
      ld e,a
      ex af,af'
      inc hl
      ld a,(hl)
      and #f0
      or e
      ld (hl),a
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l1706
      ld a,#ff
      cp l
      ret z

      ex de,hl
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      cp #03
      jr z,l1725

      ld c,l
      cp #0c
      jr z,l1725

      ld c,b
.l1725
      ex af,af'
      ld a,e
      ex af,af'
      call l1d4a

      ex af,af'
      ld e,a
      ex af,af'
      inc hl
      inc hl
      ld a,(hl)
      and #0f
      sla e
      sla e
      sla e
      sla e
      or e
      ld (hl),a
      dec hl
      dec hl
      ld a,(hl)
      set 6,a
      ld (hl),a
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l1746
      ld a,#ff
      cp l
      ret z

      ex de,hl
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      cp #04
      jr z,l1765

      ld c,l
      cp #0d
      jr z,l1765

      ld c,b
.l1765
      ex af,af'
      ld a,e
      ex af,af'
      call l1d4a

      inc hl
      inc hl
      inc hl
      ex af,af'
      ld e,a
      ex af,af'
      ld a,(hl)
      and #0f
      sla e
      sla e
      sla e
      sla e
      or e
      ld (hl),a
      dec hl
      dec hl
      dec hl
      ld a,(hl)
      set 6,a
      ld (hl),a
      ld a,#ff
      ret


; **********************************************
;
; **********************************************
.l1788
      ld a,#ff
      cp l
      ret z

      ex de,hl
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      cp #05
      jr z,l17a7

      ld c,l
      cp #0e
      jr z,l17a7

      ld c,b
.l17a7
      ex af,af'
      ld a,e
      ex af,af'
      call l1d4a

      ex af,af'
      ld e,a
      ex af,af'
      inc hl
      inc hl
      inc hl
      ld a,(hl)
      and #f0
      or e
      ld (hl),a
      dec hl
      dec hl
      dec hl
      ld a,(hl)
      set 6,a
      ld (hl),a
      ld a,#ff

      ret


; **********************************************
;
; **********************************************
.l17c2
      ld a,#ff
      cp l
      ret z

      ex de,hl
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      cp #06
      jr z,l17e1

      ld c,l
      cp #0f
      jr z,l17e1
 
      ld c,b
.l17e1
      ex af,af'
      ld a,e
      ex af,af'
      call l1d4a

      ex af,af'
      ld e,a
      ex af,af'
      inc hl
      inc hl
      ld a,(hl)
      and #f0
      or e
      ld (hl),a
      dec hl
      dec hl
      ld a,(hl)
      set 7,a
      ld (hl),a
      ld a,#ff
      ret


; **********************************************
;
; **********************************************
.l17fa
      ld a,#ff
      cp l
      ret z
      ex de,hl
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
.l1807
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
.l180a
      ld b,a
      ld c,h
      ld a,(l04bc)
      cp #07
      jr z,l1819
      ld c,l
      cp #10
      jr z,l1819
      ld c,b
.l1819
      ex af,af'
      ld a,e
      ex af,af'
      call l1d4a

      inc hl
      inc hl
      inc hl
      inc hl
      ex af,af'
      ld e,a
      ex af,af'
      ld a,(hl)
      and #0f
      sla e
      sla e
      sla e
      sla e
      or e
      ld (hl),a
      dec hl
      dec hl
      dec hl
      dec hl
      ld a,(hl)
      set 7,a
      ld (hl),a
      ld a,#ff
      ret


; **********************************************
;
; **********************************************
.l183e
      ld a,#ff
      cp l
      ret z
      ex de,hl
      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      ld h,a
      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      ld l,a
      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      ld b,a
      ld c,h
      ld a,(l04bc)
      cp #08
      jr z,l185d
      ld c,l
      cp #11
      jr z,l185d

      ld c,b
.l185d
      ex af,af'
      ld a,e
      ex af,af'
      call l1d4a

      inc hl
      inc hl
      inc hl
      inc hl
      ex af,af'
      ld e,a
      ex af,af'
      ld a,(hl)
      and #f0
      or e
      ld (hl),a
      dec hl
      dec hl
      dec hl
      dec hl
      ld a,(hl)
      set 7,a
      ld (hl),a
      ld a,#ff
      ret


; **********************************************
; Display current pattern
; **********************************************
.DISPLAY_PATTERN

; Get Current pattern number
      ld a,(CURRENT_PATTERN_NUMBER)
      ld l,a
      ld h,#00
      ld e,a
      ld d,h
      add hl,hl 
      add hl,de  ; HL = A*3
      ld de,PATTERN_LIST
      add hl,de  ; HL = PATTERN_LIST + A*3

      ; Save current track number for channel A
      ld a,(hl)
      ld (CURRENT_CHANA_TRACK_NUMBER),a

      ; Save current track number for channel B
      inc hl
      ld a,(hl)
      ld (CURRENT_CHANB_TRACK_NUMBER),a
      
      ; Save current track number for channel C
      inc hl
      ld a,(hl)
      ld (CURRENT_CHANC_TRACK_NUMBER),a
      
      ld a,(l041c)
      ld l,a
      ld h,#00
      ld de,SCR_C000
      add hl,de
      push hl
      pop ix
      ld a,(CURRENT_LINE_NUMBER)
      ld e,a
      ld d,#00
      ld hl,#4d9f
      add hl,de
      push hl
      pop iy
      sub #08
      jp p,l18b6

      xor a
.l18b6
      ld (l04b5),a
      ex af,af'
      ld a,#10
.l18bc
      ex af,af'
      ld e,(ix+#00)
      inc ix
      ld d,(ix+#00)
      inc ix
      ld a,(l041b)
      ld l,a
      ld h,#00
      add hl,de
      ex de,hl
      ld a,(iy+#00)
      cp #ff
      jp nz,l18e2

; Print ???
      ld hl,#05e3
      call DISPLAY_STRING

      inc iy
      jp l1910

.l18e2
      ld l,a
      ld h,#00
      ld c,l
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,TEXT_HEXBYTE
      add hl,bc
      call DISPLAY_STRING

      inc iy
      push iy
      inc de

      ld a,(CURRENT_CHANA_TRACK_NUMBER)
      call l1933

      ld a,(CURRENT_CHANB_TRACK_NUMBER)
      call l1933

      ld a,(CURRENT_CHANC_TRACK_NUMBER)
      call l1933

      ld a,(l04b5)
      inc a
      ld (l04b5),a
      pop iy
.l1910
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      inc ix
      ex af,af'
      dec a
      jp nz,l18bc
      ex af,af'
      ret


; **********************************************
;
; **********************************************
.l1933
      ld c,a
      ld b,#00
      ld h,b
      ld l,c
      add hl,hl
      add hl,hl
      add hl,bc
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ld bc,TRACK_0
      add hl,bc
      push hl
      ld a,(l04b5)
      ld c,a
      ld b,#00
      ld h,b
      ld l,c
      add hl,hl
      add hl,hl
      add hl,bc
      pop bc
      add hl,bc
      push hl
      pop iy
      ld a,(hl)
      and #3f
      ld l,a
      ld h,#00
      add hl,hl
      add hl,hl
      ld bc,TXT_NOTE
      add hl,bc
      call DISPLAY_STRING

      inc iy
      inc de
      ld l,(iy+#00)
      ld h,#00
      ld c,l
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,TEXT_HEXBYTE
      add hl,bc
      call DISPLAY_STRING

      inc iy
      inc de
      ld bc,TEXT_HEXNIBBLE
      ld a,(iy+#00)
      and #f0
      rra
      rra
      rra
      rra
      ld l,a
      ld h,#00
      add hl,hl
      add hl,bc
      call DISPLAY_STRING

      ld l,(iy+#01)
      ld h,#00
      ld c,l
      ld b,#00
      add hl,hl
      add hl,bc
      ld bc,TEXT_HEXBYTE
      add hl,bc
      call DISPLAY_STRING

      inc de
      ld bc,TEXT_HEXNIBBLE
      ld a,(iy+#00)
      and #0f
      ld l,a
      ld h,#00
      add hl,hl
      add hl,bc
      call DISPLAY_STRING

      inc iy
      inc iy
      ld l,(iy+#00)
      ld h,#00
      ld c,l
      ld b,#00
      add hl,hl
      add hl,bc
      ld bc,TEXT_HEXBYTE
      add hl,bc
      call DISPLAY_STRING

      inc de

      ret


; **********************************************
;
; **********************************************
.l19c8
      ld hl,TXT_CONV_MOD
      ld de,(TXT_CONV_MOD_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_CONV_SMP
      ld de,(TXT_CONV_SMP_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_PLAY_PAT
      ld de,(TXT_PLAY_PAT_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_MISC_OPT
      ld de,(TXT_MISC_OPT_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_EDIT_SMP
      ld de,(TXT_EDIT_SMP_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_SAVE_UKM
      ld de,(TXT_SAVE_UKM_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_SAVE_UKX
      ld de,(TXT_SAVE_UKX_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_PLAY_SNG
      ld de,(TXT_PLAY_SNG_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_EDIT_SNG
      ld de,(TXT_EDIT_SNG_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_EDIT_PAT
      ld de,(TXT_EDIT_PAT_POSITION)
      call DISPLAY_STRING

      ld hl,TXT_SONGLENGTH
      ld de,#c2bc
      call DISPLAY_STRING

      ret


; **********************************************
;
; **********************************************
.l1a36
      call l11fb

      ld a,(l04bb)
      ld de,l041d
      call l1e1a

.l1a42

; Wait 60ms.
      ld e,#03
      call WAIT_X_VBL

      call l1adf

; Select keys line &40.
      ld d,#40
      call TEST_KEYS

; Cursor Up ?
      bit 0,a
      jp z,l1a66

; Cursor Down ?
      bit 2,a
      jp z,l1a7b

; Select keys line
      ld d,#45
      call TEST_KEYS

; Space ?
      bit 7,a
      jp z,l1a92

      jp l1a42

.l1a66
      ld a,(l04bb)
      ld l,a
      dec a
      jp m,l1a42

      ld (l04bb),a
      ld a,l
      ld de,l041d
      call l1e1a

      jp l1a36

.l1a7b
      ld a,(l04bb)
      ld l,a
      inc a
      cp #0a
      jp p,l1a42

      ld (l04bb),a
      ld a,l
      ld de,l041d
      call l1e1a

      jp l1a36

.l1a92
      ld a,(l04bb)
      or a
      dec a
      jp z,l12b2

      dec a
      jp z,l1aab

      dec a
      dec a
      dec a
      dec a
      dec a
      dec a
      dec a
      jp z,l1126

      jp l1a42

.l1aab
      call l0aff

      xor a
      ld (CURRENT_LINE_NUMBER),a

; Synchronization VBL      
.l1ab2
      ld b,#f5
.l1ab4
      in a,(c)
      rra
      jr nc,l1ab4

; Begin white raster      
      ld bc,#7f10
      out (c),c
      ld c,#4b
      out (c),c

; Update player      
      call l0a30

; End white raster
      ld bc,#7f10
      out (c),c
      ld c,#54
      out (c),c

; Select keys line
      ld d,#48
      call TEST_KEYS

; ESC ?
      bit 2,a
      jp nz,l1ab2

      xor a
      ld (CURRENT_LINE_NUMBER),a

      jp l1a42


; **********************************************
;
; **********************************************
.l1adf

; Select keys line
      ld d,#40
      call TEST_KEYS
; F.
      bit 7,a
      jp z,l1cf4
; F3
      bit 5,a
      jp z,l1cdf
; F6
      bit 4,a
      jp z,l1c71
; F9
      bit 3,a
      jp z,l1c2c

; Select keys line
      inc d
      call TEST_KEYS
; F0
      bit 7,a
      jp z,l1d1f
; F2
      bit 6,a
      jp z,l1cca
; F1
      bit 5,a
      jp z,l1cb5
; F5
      bit 4,a
      jp z,l1beb
; F8
      bit 3,a
      jp z,l1baa
; F7
      bit 2,a
      jp z,l1b24

; Select keys line
      inc d
      call TEST_KEYS

; F4
      bit 4,a
      jp z,l1b68

      ret

; **********************************************
;
; **********************************************
.l1b24
; Select keys line
      ld d,#42
      call TEST_KEYS

; CONTROL ?
      bit 7,a
      jp nz,l1b4e

      ld a,(CURRENT_PATTERN_NUMBER)
      ld l,a
      ld h,#00
      ld c,a
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,PATTERN_LIST
      add hl,bc
      ld a,(hl)
      inc a
      ld (hl),a

; Display/Update current pattern.
      call DISPLAY_PATTERN

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      jp l1b5b

.l1b4e
      ld a,(CURRENT_INSTRUMENT_NUMBER)
      inc a
      and #1f
      jr nz,l1b58

      ld a,#1f
.l1b58
      ld (CURRENT_INSTRUMENT_NUMBER),a
.l1b5b
      call l11fb
      
; Select keys line
      ld d,#41
.l1b60
      call TEST_KEYS

; F7 ?
      bit 2,a
      jr z,l1b60
      ret


; **********************************************
;
; **********************************************
.l1b68
; Select keys line
      ld d,#42
      call TEST_KEYS

; CONTROL ?
      bit 7,a
      jp nz,l1b92

      ld a,(CURRENT_PATTERN_NUMBER)
      ld l,a
      ld h,#00
      ld c,a
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,PATTERN_LIST
      add hl,bc
      ld a,(hl)
      dec a
      ld (hl),a

; Display/Update current pattern.
      call DISPLAY_PATTERN

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      jp l1b9d
      
.l1b92
      ld a,(CURRENT_INSTRUMENT_NUMBER)
      dec a
      or a
      jr nz,l1b9a
      
      inc a
.l1b9a
      ld (CURRENT_INSTRUMENT_NUMBER),a
.l1b9d
      call l11fb
      
; Select keys line
      ld d,#42
.l1ba2
      call TEST_KEYS
      
; F4 ?
      bit 4,a
      jr z,l1ba2
      ret


; **********************************************
;
; **********************************************
.l1baa
; Select keys line
      ld d,#42
      call TEST_KEYS

; CONTROL ?
      bit 7,a
      jp nz,l1bd5

      ld a,(CURRENT_PATTERN_NUMBER)
      ld l,a
      ld h,#00
      ld c,a
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,PATTERN_LIST
      add hl,bc
      inc hl
      ld a,(hl)
      inc a
      ld (hl),a
      
; Display/Update current pattern.
      call DISPLAY_PATTERN

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      jp l1bde
      
.l1bd5
      ld a,(CURRENT_LINE_STEP)
      inc a
      and #0f
      ld (CURRENT_LINE_STEP),a
.l1bde
      call l11fb

; Select keys line
      ld d,#41
.l1be3
      call TEST_KEYS

; F8 ?
      bit 3,a
      jr z,l1be3
      ret


; **********************************************
;
; **********************************************
.l1beb
; Select keys line
      ld d,#42
      call TEST_KEYS

; CONTROL ?      
      bit 7,a
      jp nz,l1c16

      ld a,(CURRENT_PATTERN_NUMBER)
      ld l,a
      ld h,#00
      ld c,a
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,PATTERN_LIST
      add hl,bc
      inc hl
      ld a,(hl)
      dec a
      ld (hl),a

; Display/Update current pattern.
      call DISPLAY_PATTERN
      
.l1c0a
      ld a,(l04bc)
      ld de,l0441
      call l1e1a
      
      jp l1c1f
      
.l1c16
      ld a,(CURRENT_LINE_STEP)
      dec a
      and #0f
      ld (CURRENT_LINE_STEP),a
.l1c1f
      call l11fb

; Select keys line
      ld d,#41
.l1c24
      call TEST_KEYS
      
; F5 ?      
      bit 4,a
      jr z,l1c24
      ret


; **********************************************
;
; **********************************************
.l1c2c

; Select keys line
      ld d,#42
      call TEST_KEYS

; CONTROL ?
      bit 7,a
      jp nz,l1c58

      ld a,(CURRENT_PATTERN_NUMBER)
      ld l,a
      ld h,#00
      ld c,a
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,PATTERN_LIST
      add hl,bc
      inc hl
      inc hl
      ld a,(hl)
      inc a
      ld (hl),a

; Display/Update current pattern.
      call DISPLAY_PATTERN

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      jp l1c64

.l1c58
      ld a,(CURRENT_OCTAVE)
      inc a
      cp #06
      jr nz,l1c61

      dec a
.l1c61
      ld (CURRENT_OCTAVE),a
.l1c64
      call l11fb

; Select keys line
      ld d,#40
.l1c69
      call TEST_KEYS

; F9 ?
      bit 3,a

      jr z,l1c69

      ret

; **********************************************
;
; **********************************************
.l1c71

; Select keys line
      ld d,#42
      call TEST_KEYS

; CONTROL ?
      bit 7,a
      jp nz,l1c9d

      ld a,(CURRENT_PATTERN_NUMBER)
      ld l,a
      ld h,#00
      ld c,a
      ld b,h
      add hl,hl
      add hl,bc
      ld bc,PATTERN_LIST
      add hl,bc
      inc hl
      inc hl
      ld a,(hl)
      dec a
      ld (hl),a

; Display/Update current pattern.
      call DISPLAY_PATTERN

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      jp l1ca8

.l1c9d
      ld a,(CURRENT_OCTAVE)
      dec a
      or a
      jr nz,l1ca5
      inc a
.l1ca5
      ld (CURRENT_OCTAVE),a
.l1ca8
      call l11fb

; Select keys line
      ld d,#40
.l1cad
      call TEST_KEYS

; F6 ?
      bit 4,a
      jr z,l1cad

      ret


; **********************************************
;
; **********************************************
.l1cb5
      ld a,(CHANA_STATE)
      xor #01
      ld (CHANA_STATE),a
      call l11fb
      
; Select keys line
      ld d,#41
.l1cc2
      call TEST_KEYS

; F1 ?
      bit 5,a
      jr z,l1cc2

      ret


; **********************************************
;
; **********************************************
.l1cca
      ld a,(CHANB_STATE)
      xor #01
      ld (CHANB_STATE),a
      call l11fb
      
; Select keys line
      ld d,#41
.l1cd7
      call TEST_KEYS

; F2 ?
      bit 6,a
      jr z,l1cd7

      ret


; **********************************************
;
; **********************************************
.l1cdf
      ld a,(CHANC_STATE)
      xor #01
      ld (CHANC_STATE),a
      call l11fb

; Select keys line
      ld d,#40
.l1cec
      call TEST_KEYS

; F3 ?
      bit 5,a
      jr z,l1cec

      ret


; **********************************************
;
; **********************************************
.l1cf4

; Select keys line
      ld d,#42
      call TEST_KEYS      

; CONTROL ?
      bit 7,a
      jp nz,l1d14

      ld a,(CURRENT_PATTERN_NUMBER)
      inc a
      ld (CURRENT_PATTERN_NUMBER),a

; Display/Update current pattern.
      call DISPLAY_PATTERN

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      jp l1d1b

.l1d14
      ld a,(CURRENT_SONG_SPEED)
      inc a
      ld (CURRENT_SONG_SPEED),a
.l1d1b
      call l11fb

      ret


; **********************************************
;
; **********************************************
.l1d1f

; Select keys line
      ld d,#42
      call TEST_KEYS

; CONTROL ?
      bit 7,a
      jp nz,l1d3f

      ld a,(CURRENT_PATTERN_NUMBER)
      dec a
      ld (CURRENT_PATTERN_NUMBER),a

; Display/Update current pattern.
      call DISPLAY_PATTERN

      ld a,(l04bc)
      ld de,l0441
      call l1e1a

      jp l1d46

.l1d3f
      ld a,(CURRENT_SONG_SPEED)
      dec a
      ld (CURRENT_SONG_SPEED),a

.l1d46
      call l11fb

      ret


; **********************************************
;
; **********************************************
.l1d4a
      ld b,#00
      ld h,b
      ld l,c
      add hl,hl
      add hl,hl
      add hl,bc
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ld bc,TRACK_0
      add hl,bc
      ex de,hl
      ld a,(CURRENT_LINE_NUMBER)
      ld c,a
      ld b,#00
      ld h,b
      ld l,c
      add hl,hl
      add hl,hl
      add hl,bc
      add hl,de
      ret


; **********************************************
; E = number of VBL to wait
; **********************************************
.WAIT_X_VBL

      ld b,#f5
.WAIT_SYNC
      in a,(c)
      rra
      jr nc,WAIT_SYNC

.WAIT_NOSYNC
      in a,(c)
      rra
      jr c,WAIT_NOSYNC

      dec e
      jr nz,WAIT_SYNC
      ret


; **********************************************
;
; **********************************************
.UPDATE_DMA

; ASIC page-in
      ld bc,#7fb8
      out (c),c

; Set AY list address for DMA0
      ld de,(l04a6)
      ld hl,#6c00
      ld (hl),e
      inc hl
      ld (hl),d

; Set AY list address for DMA1
      ld de,(l04a8)
      ld hl,#6c04
      ld (hl),e
      inc hl
      ld (hl),d

; Set AY list address for DMA2
      ld de,(l04aa)
      ld hl,#6c08
      ld (hl),e
      inc hl
      ld (hl),d

; Set DSCR (DMAx on/off
      ld a,(DSCR_VALUE)
      ld (#6c0f),a

; ASIC page-out
      ld bc,#7fa0
      out (c),c

      ret


; **********************************************
; Generate 200 high screen (&C000) line address
; **********************************************
MAKE_SCR_LUT

      ld b,200
      ld ix,SCR_C000
      ld hl,#c000
.l1db1
      ld (ix+#00),l
      inc ix
      ld (ix+#00),h
      inc ix
      ld a,h
      add #08
      ld h,a
      jr nc,l1dc5

      ld de,#c050
      add hl,de
.l1dc5
      djnz l1db1

      ret


; **********************************************
; Print text routine
; **********************************************
.DISPLAY_STRING
      ld a,(hl)
      or a
      ret z
      sub #20
      push de
      exx
      ld l,a
      ld h,#00
      ld bc,TEXT_FONT
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,bc
      pop de
      ld b,#08
.DISPLAY_STRING_LOOP
      ld a,(hl)
      ld (de),a
      ex de,hl
      ld a,h
      add #08
      ld h,a
      jp nc,DISPLAY_STRING_NEXT
      push bc
      ld bc,#c050
      add hl,bc
      pop bc
.DISPLAY_STRING_NEXT
      ex de,hl
      inc hl
      djnz DISPLAY_STRING_LOOP

      exx
      inc de
      inc hl

      jr DISPLAY_STRING


; **********************************************
; Test keys
; Input
;  D = Keys line to test
; Output
;  A = Keys line state
; **********************************************
.TEST_KEYS
      ld bc,#f40e
      out (c),c
      ld bc,#f6c0
      out (c),c
      xor a
      out (c),a
      ld bc,#f792
      out (c),c
      ld b,#f6
      out (c),d
      ld b,#f4
      in a,(c)
      ld bc,#f782
      out (c),c
      ld bc,#f600
      out (c),c

      ret

; **********************************************
;
; **********************************************
.l1e1a
      ld l,a
      ld h,#00
      ld b,h
      ld c,l
      add hl,hl
      add hl,bc
      add hl,de
      push hl
      pop iy
      ld l,(iy+#00)
      ld h,#00
      add hl,hl
      add hl,hl
      add hl,hl
      add hl,hl
      ld de,SCR_C000
      add hl,de
      push hl
      pop ix
      ld b,#08
.l1e37
      ld e,(ix+#00)
      inc ix
      ld d,(ix+#00)
      inc ix
      ld l,(iy+#01)
      ld h,#00
      add hl,de
      ld d,(iy+#02)
.l1e4a
      ld a,(hl)
      xor #ff
      ld (hl),a
      inc hl
      dec d
      jp nz,l1e4a

      djnz l1e37

      ret

; **********************************************
;
; **********************************************
      org #1e56

ASIC_UNLOCK_SEQUENCE
      db #ff,#00,#ff,#77,#b3,#51,#a8,#d4
      db #62,#39,#9c,#46,#2b,#15,#8a,#cd
      db #ee

; Screen address LUT (200 lines x 2bytes)
SCR_C000
      ds 400,0
 
.TEXT_FONT
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #18,#18,#18,#18,#18,#00,#18,#00
      db #6c,#6c,#6c,#00,#00,#00,#00,#00
      db #6c,#6c,#fe,#6c,#fe,#6c,#6c,#00
      db #18,#3e,#58,#3c,#1a,#7c,#18,#00
      db #00,#c6,#cc,#18,#30,#66,#c6,#00
      db #38,#6c,#38,#76,#dc,#cc,#76,#00
      db #18,#18,#30,#00,#00,#00,#00,#00
      db #0c,#18,#30,#30,#30,#18,#0c,#00
      db #30,#18,#0c,#0c,#0c,#18,#30,#00
      db #00,#66,#3c,#ff,#3c,#66,#00,#00
      db #00,#18,#18,#7e,#18,#18,#00,#00
      db #00,#00,#00,#00,#00,#18,#18,#30
      db #00,#00,#00,#7e,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#18,#18,#00
      db #06,#0c,#18,#30,#60,#c0,#80,#00
      db #7c,#c6,#ce,#d6,#e6,#c6,#7c,#00
      db #18,#38,#18,#18,#18,#18,#7e,#00
      db #3c,#66,#06,#3c,#60,#66,#7e,#00
      db #3c,#66,#06,#1c,#06,#66,#3c,#00
      db #1c,#3c,#6c,#cc,#fe,#0c,#1e,#00
      db #7e,#62,#60,#7c,#06,#66,#3c,#00
      db #3c,#66,#60,#7c,#66,#66,#3c,#00
      db #7e,#66,#06,#0c,#18,#18,#18,#00
      db #3c,#66,#66,#3c,#66,#66,#3c,#00
      db #3c,#66,#66,#3e,#06,#66,#3c,#00
      db #00,#00,#18,#18,#00,#18,#18,#00
      db #00,#00,#18,#18,#00,#18,#18,#30
      db #0c,#18,#30,#60,#30,#18,#0c,#00
      db #00,#00,#7e,#00,#00,#7e,#00,#00
      db #60,#30,#18,#0c,#18,#30,#60,#00
      db #3c,#66,#66,#0c,#18,#00,#18,#00
      db #7c,#c6,#de,#de,#de,#c0,#7c,#00
      db #18,#3c,#66,#66,#7e,#66,#66,#00
      db #fc,#66,#66,#7c,#66,#66,#fc,#00
      db #3c,#66,#c0,#c0,#c0,#66,#3c,#00
      db #f8,#6c,#66,#66,#66,#6c,#f8,#00
      db #fe,#62,#68,#78,#68,#62,#fe,#00
      db #fe,#62,#68,#78,#68,#60,#f0,#00
      db #3c,#66,#c0,#c0,#ce,#66,#3e,#00
      db #66,#66,#66,#7e,#66,#66,#66,#00
      db #7e,#18,#18,#18,#18,#18,#7e,#00
      db #1e,#0c,#0c,#0c,#cc,#cc,#78,#00
      db #e6,#66,#6c,#78,#6c,#66,#e6,#00
      db #f0,#60,#60,#60,#62,#66,#fe,#00
      db #c6,#ee,#fe,#fe,#d6,#c6,#c6,#00
      db #c6,#e6,#f6,#de,#ce,#c6,#c6,#00
      db #38,#6c,#c6,#c6,#c6,#6c,#38,#00
      db #fc,#66,#66,#7c,#60,#60,#f0,#00
      db #38,#6c,#c6,#c6,#da,#cc,#76,#00
      db #fc,#66,#66,#7c,#6c,#66,#e6,#00
      db #3c,#66,#60,#3c,#06,#66,#3c,#00
      db #7e,#5a,#18,#18,#18,#18,#3c,#00
      db #66,#66,#66,#66,#66,#66,#3c,#00
      db #66,#66,#66,#66,#66,#3c,#18,#00
      db #c6,#c6,#c6,#d6,#fe,#ee,#c6,#00
      db #c6,#6c,#38,#38,#6c,#c6,#c6,#00
      db #66,#66,#66,#3c,#18,#18,#3c,#00
      db #fe,#c6,#8c,#18,#32,#66,#fe,#00
      db #3c,#30,#30,#30,#30,#30,#3c,#00
      db #c0,#60,#30,#18,#0c,#06,#02,#00
      db #3c,#0c,#0c,#0c,#0c,#0c,#3c,#00
      db #18,#3c,#7e,#18,#18,#18,#18,#00
      db #00,#00,#00,#00,#00,#00,#00,#ff
      db #30,#18,#0c,#00,#00,#00,#00,#00
      db #00,#00,#78,#0c,#7c,#cc,#76,#00
      db #e0,#60,#7c,#66,#66,#66,#dc,#00
      db #00,#00,#3c,#66,#60,#66,#3c,#00
      db #1c,#0c,#7c,#cc,#cc,#cc,#76,#00
      db #00,#00,#3c,#66,#7e,#60,#3c,#00
      db #1c,#36,#30,#78,#30,#30,#78,#00
      db #00,#00,#3e,#66,#66,#3e,#06,#7c
      db #e0,#60,#6c,#76,#66,#66,#e6,#00
      db #18,#00,#38,#18,#18,#18,#3c,#00
      db #06,#00,#0e,#06,#06,#66,#66,#3c
      db #e0,#60,#66,#6c,#78,#6c,#e6,#00
      db #38,#18,#18,#18,#18,#18,#3c,#00
      db #00,#00,#6c,#fe,#d6,#d6,#c6,#00
      db #00,#00,#dc,#66,#66,#66,#66,#00
      db #00,#00,#3c,#66,#66,#66,#3c,#00
      db #00,#00,#dc,#66,#66,#7c,#60,#f0
      db #00,#00,#76,#cc,#cc,#7c,#0c,#1e
      db #00,#00,#dc,#76,#60,#60,#f0,#00
      db #00,#00,#3c,#60,#3c,#06,#7c,#00
      db #30,#30,#7c,#30,#30,#36,#1c,#00
      db #00,#00,#66,#66,#66,#66,#3e,#00
      db #00,#00,#66,#66,#66,#3c,#18,#00
      db #00,#00,#c6,#d6,#d6,#fe,#6c,#00
      db #00,#00,#c6,#6c,#38,#6c,#c6,#00
      db #00,#00,#66,#66,#66,#3e,#06,#7c
      db #00,#00,#7e,#4c,#18,#32,#7e,#00
      db #0e,#18,#18,#70,#18,#18,#0e,#00
      db #18,#18,#18,#18,#18,#18,#18,#00

; **********************************************
; 
; **********************************************
      org #22df
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00


; **********************************************
; Pattern list, 256 max
; **********************************************
PATTERN_LIST 
      db #00,#02,#01,#00,#02,#01,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00


; **********************************************
; Track 0 (320 bytes)
; **********************************************
TRACK_0
      db #e9,#01,#c9,#47,#20
      db #00,#00,#00,#00,#00
      db #ec,#01,#c9,#47,#1e
      db #40,#00,#c0,#00,#00
      db #ee,#01,#c9,#47,#1a
      db #40,#00,#c0,#00,#00
      db #f0,#01,#c9,#47,#1c
      db #40,#00,#c0,#00,#00
      db #ee,#01,#c9,#48,#18
      db #40,#00,#c0,#00,#00
      db #ec,#01,#c9,#48,#16
      db #40,#00,#c0,#00,#00
      db #e7,#01,#c9,#48,#14
      db #40,#00,#c0,#00,#00
      db #e9,#01,#c9,#48,#12
      db #40,#00,#c0,#00,#00
      db #e9,#01,#c9,#49,#10
      db #00,#00,#00,#00,#00
      db #ec,#01,#c9,#49,#0e
      db #40,#00,#c0,#00,#00
      db #ee,#01,#c9,#49,#0c
      db #40,#00,#c0,#00,#00
      db #f0,#01,#c9,#49,#0a
      db #40,#00,#c0,#00,#00
      db #ee,#01,#c9,#4a,#08
      db #40,#00,#c0,#00,#00
      db #ec,#01,#c9,#4a,#06
      db #40,#00,#c0,#00,#00
      db #e7,#01,#c9,#4a,#04
      db #40,#00,#c0,#00,#00
      db #e9,#01,#c9,#4a,#02
      db #40,#00,#c0,#00,#00
      db #e9,#01,#c9,#4b,#00
      db #00,#00,#00,#00,#00
      db #ec,#01,#c9,#4b,#00
      db #40,#00,#c0,#00,#00
      db #ee,#01,#c9,#4b,#00
      db #40,#00,#c0,#00,#00
      db #f0,#01,#c9,#4b,#00
      db #40,#00,#c0,#00,#00
      db #ee,#01,#c9,#4c,#00
      db #40,#00,#c0,#00,#00
      db #ec,#01,#c9,#4c,#00
      db #40,#00,#c0,#00,#00
      db #e7,#01,#c9,#4c,#00
      db #40,#00,#c0,#00,#00
      db #e9,#01,#c9,#4c,#00
      db #40,#00,#c0,#00,#00
      db #e9,#01,#c9,#4d,#00
      db #00,#00,#00,#00,#00
      db #ec,#01,#c9,#4d,#04
      db #40,#00,#c0,#00,#00
      db #ee,#01,#c9,#4d,#08
      db #40,#00,#c0,#00,#00
      db #f0,#01,#c9,#4d,#0b
      db #40,#00,#c0,#00,#00
      db #ee,#01,#c9,#4e,#10
      db #40,#00,#c0,#00,#00
      db #ec,#01,#c9,#4e,#14
      db #40,#00,#c0,#00,#00
      db #e7,#01,#c9,#4e,#18
      db #40,#00,#c0,#00,#00
      db #e9,#01,#c9,#4e,#1b
      db #40,#00,#c0,#00,#00


; **********************************************
; Track 1 (320 bytes)
; **********************************************
TRACK_1
      db #60,#02,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #60,#02,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #60,#02,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #60,#02,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #60,#02,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #60,#02,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #60,#02,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #19,#04,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #60,#02,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #59,#03,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #59,#03,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #59,#03,#c0,#43,#00
      db #00,#00,#00,#00,#00

      
; **********************************************
; Track 2 (320 bytes)
; **********************************************      
TRACK_2
      db #80,#00,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #e9,#06,#cf,#30,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #80,#00,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #e9,#06,#cf,#30,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #80,#00,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #e9,#06,#cf,#30,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #80,#00,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #e9,#06,#cf,#30,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #80,#00,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #e9,#06,#cf,#30,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #80,#00,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #a9,#06,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #80,#00,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #e9,#06,#cf,#30,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #80,#00,#0f,#00,#05
      db #80,#00,#0f,#00,#04
      db #80,#00,#0f,#00,#02
      db #80,#00,#0f,#00,#03
      db #e7,#06,#cf,#30,#05
      db #80,#00,#0f,#00,#04
      db #e9,#06,#cf,#30,#02
      db #80,#00,#0f,#00,#03

; **********************************************
; Track 3 (320 bytes)
; **********************************************  
      db #69,#06,#c0,#40,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#40,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#41,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#41,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#42,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#42,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#43,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#44,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#44,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#45,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#45,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#46,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#46,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#47,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#47,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#48,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#48,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#49,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#49,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4a,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4a,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4b,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4b,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4c,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4c,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4d,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4d,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4e,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4e,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4f,#00
      db #00,#00,#00,#00,#00
      db #69,#06,#c0,#4f,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00

      ds 8320,0 ; 26 others tracks possible
      
; **********************************************
; Padding
; **********************************************
      ds 290,0


; **********************************************
;
; **********************************************
      db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
      db #00,#01,#02,#03,#04,#05,#06,#07
      db #08,#09,#0a,#0b,#0c,#0d,#0e,#0f
      db #10,#11,#12,#13,#14,#15,#16,#17
      db #18,#19,#1a,#1b,#1c,#1d,#1e,#1f
      db #20,#21,#22,#23,#24,#25,#26,#27
      db #28,#29,#2a,#2b,#2c,#2d,#2e,#2f
      db #30,#31,#32,#33,#34,#35,#36,#37
      db #38,#39,#3a,#3b,#3c,#3d,#3e,#3f
      db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff

.l4def
      db #00 ; Current line number

; **********************************************
; Sample information
; byte 1-2 = start address of sample
; byte 3   = bank number
; byte 4-5 = sample length
; **********************************************      
SAMPLE_INFO
      dw #4000:db #c5:dw #305c:db #00,#00,#00,#00
      dw #70c5:db #c5:dw #0552:db #00,#00,#00,#00
      dw #75ae:db #c5:dw #02be:db #00,#00,#00,#00
      dw #786c:db #c5:dw #017c:db #00,#00,#00,#00
      dw #50c6:db #c4:dw #044c:db #00,#00,#00,#00
      dw #5512:db #c4:dw #0864:db #00,#00,#00,#00
      dw #5d76:db #c4:dw #2220:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00 
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00
      dw #0000:db #00:dw #0000:db #00,#00,#00,#00


; **********************************************
; Sample period (fixed point) for each music note
; **********************************************
SAMPLE_PERIOD
;          C     C#    D     D#    E     F     F#    G     G#    A     A#    B
      dw #0044,#0048,#004c,#0051,#0056,#005b,#0060,#0066,#006c,#0072,#0079,#0080 ; Octave 1
      dw #0088,#0090,#0099,#00a2,#00ab,#00b6,#00c0,#00cc,#00d8,#00e5,#00f2,#0101 ; Octave 2
      dw #0110,#0120,#0131,#0143,#0157,#016b,#0181,#0197,#01b0,#01c9,#01e5,#0201 ; Octave 3
      dw #0220,#0240,#0263,#0287,#02ad,#02d6,#0301,#032f,#035f,#0393,#03c9,#0403 ; Octave 4
      dw #0440,#0481,#04c5,#050e,#055b,#05ac,#0603,#065e,#06bf,#0726,#0793,#0806 ; Octave 5
      dw #0880,#0902,#098a,#0a1c,#0ab6,#0b58,#0c06,#0cbc,#0d7e,#0e4c,#0f26,#100c ; Octave 6
      dw #1100,#1270,#1314,#1438,#156c,#16b0,#1808,#1978,#1afc,#1c98,#1e4c,#2018 ; Octave 7


; **********************************************
; Padding
; **********************************************
      ds 2,0
      ds 10*16,0
      ds 4096*3,0


; **********************************************
; Volume LUT
; **********************************************
      org #8000
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07

      org #8100
      db #00,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0d,#0d,#0d
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      
      org &8200
      db #00,#00,#00,#00,#01,#02,#03,#07,#0b,#0c,#0d,#0d,#0d,#0d,#0d,#0d
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07

      org &8300
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
      db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07

      org &8400
      db #04,#05,#06,#07,#07,#07,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0b
      db #04,#04,#05,#06,#07,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0b,#0b
      db #04,#04,#04,#05,#06,#07,#07,#07,#07,#08,#09,#0a,#0b,#0b,#0b,#0b
      db #04,#04,#04,#04,#05,#06,#07,#07,#08,#09,#0a,#0b,#0b,#0b,#0b,#0b
      db #04,#04,#04,#04,#04,#05,#06,#07,#09,#0a,#0b,#0b,#0b,#0b,#0b,#0b
      db #04,#04,#04,#04,#04,#04,#05,#07,#0a,#0b,#0b,#0b,#0b,#0b,#0b,#0b
      db #04,#04,#04,#04,#04,#04,#04,#07,#0b,#0b,#0b,#0b,#0b,#0b,#0b,#0b
      db #04,#05,#06,#07,#07,#07,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0b
      db #04,#05,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#09,#0a,#0b,#0b
      db #04,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0a,#0b,#0b
      db #04,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0b,#0b
      db #04,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0b
      db #04,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0b
      db #04,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0b
      db #04,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0b
      db #04,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0b

      org &8500
      db #03,#03,#04,#05,#06,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0c,#0c
      db #03,#03,#03,#04,#05,#06,#07,#07,#07,#08,#09,#0a,#0b,#0c,#0c,#0c
      db #03,#03,#03,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0c,#0c,#0c
      db #03,#03,#03,#03,#03,#04,#05,#07,#09,#0a,#0b,#0c,#0c,#0c,#0c,#0c
      db #03,#03,#03,#03,#03,#03,#04,#07,#0a,#0b,#0c,#0c,#0c,#0c,#0c,#0c
      db #03,#03,#03,#03,#03,#03,#03,#07,#0b,#0c,#0c,#0c,#0c,#0c,#0c,#0c
      db #03,#03,#03,#03,#03,#03,#03,#07,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c
      db #03,#03,#04,#05,#06,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0c,#0c
      db #03,#03,#04,#05,#07,#07,#07,#07,#07,#07,#07,#09,#0a,#0b,#0c,#0c
      db #03,#03,#04,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0a,#0b,#0c,#0c
      db #03,#03,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0b,#0c,#0c
      db #03,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c
      db #03,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c
      db #03,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c
      db #03,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c
      db #03,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c

      org &8600
      db #01,#02,#03,#04,#05,#06,#07,#07,#07,#08,#09,#0a,#0b,#0c,#0c,#0c
      db #01,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0c,#0c,#0c
      db #01,#01,#01,#02,#03,#04,#05,#07,#09,#0a,#0b,#0c,#0c,#0c,#0c,#0c
      db #01,#01,#01,#01,#02,#03,#04,#07,#0a,#0b,#0c,#0c,#0c,#0c,#0c,#0c
      db #01,#01,#01,#01,#01,#02,#03,#07,#0b,#0c,#0c,#0c,#0c,#0c,#0c,#0c
      db #01,#01,#01,#01,#01,#01,#02,#07,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c
      db #01,#01,#01,#01,#01,#01,#01,#07,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c
      db #01,#02,#03,#04,#05,#06,#07,#07,#07,#08,#09,#0a,#0b,#0c,#0c,#0c
      db #01,#02,#03,#04,#05,#07,#07,#07,#07,#07,#09,#0a,#0b,#0c,#0c,#0c
      db #01,#02,#03,#04,#07,#07,#07,#07,#07,#07,#07,#0a,#0b,#0c,#0c,#0c
      db #01,#02,#03,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0b,#0c,#0c,#0c
      db #01,#02,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c,#0c
      db #01,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c,#0c
      db #01,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c,#0c
      db #01,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c,#0c
      db #01,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0c,#0c

      org &8700
      db #00,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0d,#0d,#0d
      db #00,#00,#01,#02,#03,#04,#05,#07,#09,#0a,#0b,#0c,#0d,#0d,#0d,#0d
      db #00,#00,#00,#01,#02,#03,#04,#07,#0a,#0b,#0c,#0d,#0d,#0d,#0d,#0d
      db #00,#00,#00,#00,#01,#02,#03,#07,#0b,#0c,#0d,#0d,#0d,#0d,#0d,#0d
      db #00,#00,#00,#00,#00,#01,#02,#07,#0c,#0d,#0d,#0d,#0d,#0d,#0d,#0d
      db #00,#00,#00,#00,#00,#00,#01,#07,#0d,#0d,#0d,#0d,#0d,#0d,#0d,#0d
      db #00,#00,#00,#00,#00,#00,#00,#07,#0d,#0d,#0d,#0d,#0d,#0d,#0d,#0d
      db #00,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0d,#0d,#0d
      db #00,#01,#02,#03,#04,#05,#07,#07,#07,#09,#0a,#0b,#0c,#0d,#0d,#0d
      db #00,#01,#02,#03,#04,#07,#07,#07,#07,#07,#0a,#0b,#0c,#0d,#0d,#0d
      db #00,#01,#02,#03,#07,#07,#07,#07,#07,#07,#0a,#0b,#0c,#0d,#0d,#0d
      db #00,#01,#02,#03,#07,#07,#07,#07,#07,#07,#07,#0b,#0c,#0d,#0d,#0d
      db #00,#01,#02,#07,#07,#07,#07,#07,#07,#07,#07,#0b,#0c,#0d,#0d,#0d
      db #00,#01,#02,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0d,#0d,#0d
      db #00,#01,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0c,#0d,#0d,#0d
      db #00,#01,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#0d,#0d,#0d

; **********************************************
; 
; **********************************************
      org #8800
      
      push hl
      exx
      ld (l8814 + 1),bc
      ld (l8811 + 1),hl
      ld bc,200
      sbc hl,bc
      pop bc
      sbc hl,bc
.l8811
      ld hl,#7617
.l8814
      ld bc,#8200
      jp p,l881d
      
      ld bc,#8300
.l881d
      exx
 
repeat 70
      ex af,af'
      add e
      adc hl,bc
      ex af,af'
      ld a,(hl)
      exx
      ld c,a
      ld a,(bc)
      ld (de),a
      inc de
      inc de
      inc de
      inc de
      exx
rend

      push hl
      exx
      ld (l8c4c + 1),bc
      ld (l8c49 + 1),hl
      ld bc,#00c8
      sbc hl,bc
      pop bc
      sbc hl,bc
.l8c49
      ld hl,#7617
.l8c4c
      ld bc,#8304
      jp p,l8c55

      ld bc,#8300
.l8c55
      exx

repeat 86
      ex af,af'
      add e
      adc hl,bc
      ex af,af'
      ld a,(hl)
      exx
      ld c,a
      ld a,(bc)
      ld (de),a
      inc de
      inc de
      inc de
      inc de
      exx
rend      
      ret

; **********************************************
; Padding
; **********************************************
org #9161
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00

; **********************************************
; DMA0 buffer 1
; **********************************************
org #9500
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #20,#40,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00


; **********************************************
; DMA0 buffer 2
; **********************************************
org #9800
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #07,#08,#00,#40,#07,#08,#00,#40
      db #20,#40,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00


; **********************************************
; DMA1 buffer 1
; **********************************************
org #9b00
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #20,#40,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
 

; **********************************************
; DMA1 buffer 2
; **********************************************
org #9e00
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #07,#09,#00,#40,#07,#09,#00,#40
      db #20,#40,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00

; **********************************************
; DMA2 buffer 1
; **********************************************
org #a100
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #20,#40,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00


; **********************************************
; DMA2 buffer 2
; **********************************************
org #a400
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #07,#0a,#00,#40,#07,#0a,#00,#40
      db #20,#40,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
      db #00,#00,#00,#00,#00,#00,#00,#00
