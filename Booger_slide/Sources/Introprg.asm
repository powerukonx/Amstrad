; *****************************************************************************
; *                BOOGER SLIDE, A slide show by Delirium Gang.               *
; *                                 (PREINTRO.PRG)                            *
; *                                                                           *
; * Code            => Power                                                  *
; * Zik             => Greg                                                   *
; * Gfxs            => Greg                                                   *
; *                                                                           *
; *****************************************************************************
    org &3000
    run EntryPoint
    nolist

; *****************************************************************************
;
; *****************************************************************************
    read "./define/def_hardware.asm"
    read "./define/def_firmware.asm"
    read "./define/def_macro.asm"

; *****************************************************************************
;
; *****************************************************************************
SONG_INIT_ADDR equ &4000
SONG_PLAY_ADDR equ SONG_INIT_ADDR + 3
SONG_STOP_ADDR equ SONG_PLAY_ADDR + 3

; *****************************************************************************
;
; *****************************************************************************
EntryPoint

; Set disk motor OFF
    ld bc,FLOPPY_MOTOR_PORT
    out (c),c
    xor a
    out (c),a

; Initialize song RAM #C7 bank (INTRO.MUS).
    mST128_INITSONG SONG_INIT_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG7

; Switch to RAM #C0.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0
;
    ld hl,#d800
    ld (l3585),hl

;
    ld de,#d801
    ld (l3587),de

;
    ld a,#04
    ld (l3584),a

; Set beginning address of text.
    ld hl,#3700
    ld (TextAddress),hl

    ld hl,#d800
    ld (CurrentLetterPosition),hl

; Set video memory screen beginning at &8000.
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #20
    out (c),c
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_L
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #00
    out (c),c

; Set interrupt subroutine as RET-EI (save older), set SP at &100 (save older).
    di
    mISR_REMAP &c9fb, RestoreISR+1
    SP_REMAP &0100, RestoreSP+1
    ei

; Save &8000 - &FFFF area in C4 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4
    mMEMCPY &8000,&4000,&4000

; Switch to C0 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Clear video memory.
    mMEMCLR &8000,&8000

; Display SLIDE logo.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG6
    mCOPYSPRITE &5590,&e43b,&4f,&42

; Display BOOGER logo.
    mCOPYSPRITE &4000,&c180,&3e,&50

; Switch to C0 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Copy &c000->&8000
    mMEMCPY &c000,&8000,&4000

; Clear &c000->&ffff
    mMEMCLR &c000,&4000

; Modify horizontal screen width.
    ld bc,PORT_CRTC_SELECT_REG + CRTC_HORIZONTAL_DISPLAYED
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #30
    out (c),c
    ld bc,PORT_CRTC_SELECT_REG + CRTC_HORIZONTAL_SYNC_POSITION
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #32
    out (c),c

.IntroLoop

; Wait fly-back.
    ld b,PPI_PORTB/256
.nosync
    in a,(c)
    rra
    jp nc,nosync

; Set low screen resolution (160x200x4bpp).
    ld bc,GA_PORT + GA_SCR_MODE_ROM_CONF + GA_UPPER_ROM_ENABLE + GA_LOWER_ROM_ENABLE + GA_LOW_RESOLUTION
    out (c),c

; Set palette
    ld a,GA_PENR + GA_PENR_BORDER
    ld hl,Palette
.PalLoop
    dec a
    ld c,(hl)
    out (c),a
    out (c),c
    inc hl
    or a
    jr nz,PalLoop
    
; Set VBL position to overflow value.
    ld bc,PORT_CRTC_SELECT_REG + CRTC_VERTICAL_SYNC_POSITION
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #ff
    out (c),c

; Set first screen vertical size.
    ld bc,PORT_CRTC_SELECT_REG + CRTC_VERTICAL_TOTAL
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #15
    out (c),c

; Set start address of video memory for first screen (&C000).
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #30
    out (c),c
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_L
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #00
    out (c),c

;
    ld a,(l3584)
    or a
    jp nz,l31cf

;
.l3190
    ld b,#8c

    ld hl,(l3585)
    ld de,(l3587)

    xor a
    ld (hl),a

    push bc
    push de
    push hl
    ld bc,#005f
    ldir
    pop hl
    call ComputeNextLine
    ld (l3585),hl
    pop de
    ex de,hl
    call ComputeNextLine
    ex de,hl
    ld (l3587),de
    pop bc
    djnz l31cb

    ld a,#01
    ld (l3584),a

    ld hl,#d800
    ld (l3585),hl

    ld de,#d801
    ld (l3587),de

    ld b,#8c
.l31cb
    ld a,b
    ld (l3190 + 1),a

.l31cf

    halt

; Play song
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG7

; Switch to C0 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Wait 2 interrupts.
    halt
    halt

; Wait 36us
    ds 36,0

; Wait 16*64us
    ld b,#10
.l3204
    ds 59,0
    djnz l3204

; Set middle screen resolution (320x200x2bpp).
    mHW_MODE_SET GA_MID_RESOLUTION

; Make raster as screen separation
    ld bc,GA_PORT + GA_PEN_SELECTION + GA_PENR_0
    ld a,GA_COLOR_SELECTION + GA_COLOR_WHITE
    out (c),c:out (c),a:ds 58,0
    ld a,GA_COLOR_SELECTION + GA_COLOR_BRIGHT_WHITE
    out (c),a:ds 58,0
    ld a,GA_COLOR_SELECTION + GA_COLOR_WHITE
    out (c),a:ds 58,0

; Set background color.
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLUE
    out (c),a

; Set palette
.SetSecondScreenPalette
    ld hl,l3593
    ld a,(hl)
    inc c
    out (c),c
    out (c),a
    inc hl
    ld a,(hl)
    inc c
    out (c),c
    out (c),a
    inc hl
    ld a,(hl)
    inc c
    out (c),c
    out (c),a

; Set second screen vertical size.
    ld bc,#bc04
    out (c),c
    ld bc,#bd11
    out (c),c

    halt
;
    ld a,(l3584)
    cp #01
    jp nz,l3336

;
    call l34a1

;
.l3336
    ld a,(l3584)
    cp #02
    jp nz,l3390

;
.l333e
    ld a,#03
    dec a
    ld (l333e + 1),a
    jp nz,l3390

;
    ld a,#03
    ld (l333e + 1),a

;
.l334c
    ld hl,l3596
    ld (SetSecondScreenPalette + 1),hl

;
.l3352
    call l3358

    jp l3390

; *****************************************************************************
;
; *****************************************************************************
.l3358
; Set FADEIN/OUT palette
    ld hl,l3596
    ld (l334c + 1),hl

;
    ld hl,l3365
    ld (l3352 + 1),hl
    ret

; *****************************************************************************
;
; *****************************************************************************
.l3365
; Set FADE IN/OUT palette
    ld hl,l3599
    ld (l334c + 1),hl

;
    ld hl,l3372
    ld (l3352 + 1),hl
    ret

; *****************************************************************************
;
; *****************************************************************************
.l3372
; Set OUT palette
    ld hl,l359c
    ld (l334c + 1),hl

;
    ld hl,l337f
    ld (l3352 + 1),hl
    ret

; *****************************************************************************
;
; *****************************************************************************
.l337f
;
    ld hl,l3596
    ld (l334c + 1),hl

;
    ld hl,l3358
    ld (l3352 + 1),hl

    xor a
    ld (l3584),a
    ret

; *****************************************************************************
;
; *****************************************************************************
.l3390
    halt

;
.l3391
    ld a,#01
    dec a
    ld (l3391 + 1),a
    jp nz,l33ec

;
    ld a,#02
    ld (l3391 + 1),a

;
    ld a,(l3584)
    cp #03
    jp nz,l33ec

;
.l33a7
    ld hl,l3599
    ld (SetSecondScreenPalette + 1),hl

;
.l33ad
    call l33b3

    jp l33ec

; *****************************************************************************
;
; *****************************************************************************
.l33b3

; Set second screen palette address
    ld hl,l3599
    ld (l33a7 + 1),hl

;
    ld hl,l33c0
    ld (l33ad + 1),hl
    ret

; *****************************************************************************
;
; *****************************************************************************
.l33c0

; Set second screen palette address
    ld hl,l3596
    ld (l33a7 + 1),hl

;
    ld hl,l33cd
    ld (l33ad + 1),hl
    ret

; *****************************************************************************
;
; *****************************************************************************
.l33cd

; Set second screen palette address
    ld hl,l3593
    ld (l33a7 + 1),hl

;
    ld hl,l33da
    ld (l33ad + 1),hl
    ret

; *****************************************************************************
;
; *****************************************************************************
.l33da

; Set second screen palette address
    ld hl,l3599
    ld (l33a7 + 1),hl

;
    ld hl,l33b3
    ld (l33ad + 1),hl

;
    ld a,#04
    ld (l3584),a
    ret

; *****************************************************************************
;
; *****************************************************************************
.l33ec
    halt
    ld a,(l3584)
    cp #04
    jp nz,l3408

.l33f5
    ld a,#4c
    dec a
    ld (l33f5 + 1),a
    jp nz,l3408

;
    ld a,#02
    ld (l3584),a

;
    ld a,#8c
    ld (l33f5 + 1),a

.l3408
; Set start address of video memory to second screen (&8000).
    ld bc,#bc0c
    out (c),c
    ld bc,#bd20
    out (c),c
    ld bc,#bc0d
    out (c),c
    ld bc,#bd00
    out (c),c

; Set VBL now
    ld bc,#bc07
    out (c),c
    ld bc,#bd00
    out (c),c

; Test keys (ESC)
    ld a,#48
    call TestKeys
    cp #fb
    jp nz,IntroLoop

; Restore area &8000-&FFFF from C4 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4
    mMEMCPY &4000,&8000,&4000
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Restore stack and ISR.
    di
.RestoreSP
    ld sp,#bfe8
.RestoreISR
    ld hl,(&0000)
    ld (#0038),hl
    ei

; Restore CRTC registers values.
    ld bc,#bc01
    out (c),c
    ld bc,#bd28
    out (c),c
    ld bc,#bc02
    out (c),c
    ld bc,#bd2e
    out (c),c
    ld bc,#bc07
    out (c),c
    ld bc,#bd1e
    out (c),c
    ld bc,#bc04
    out (c),c
    ld bc,#bd26
    out (c),c
    ld bc,#bc0c
    out (c),c
    ld bc,#bd30
    out (c),c
    ld bc,#bc0d
    out (c),c
    ld bc,#bd00
    out (c),c

; Stop song.
    ld bc,#7fc7
    out (c),c
    call #4006

; Switch to C0 bank
    ld bc,#7fc0
    out (c),c
    ret

; *****************************************************************************
;
; *****************************************************************************
.RESTORE_ISR
    dw &41C3

; *****************************************************************************
;
; *****************************************************************************
.l34a1
    ld hl,(TextAddress)
    ld a,(hl)

; 1 => End of line
    cp #01
    jp z,l3504

; 0 => End of screen.
    or a
    jp z,l3514

; &ff => End of text
    cp #ff
    jp z,l3525

; &20 => space jump to next position
    cp #20
    jp z,l3538

;
    inc hl
    ld (TextAddress),hl
    sub 32      ; Remove before space character
    ld b,a
    ld hl,#4000 ; Font address
    ld de,#0100 ; 8x32 bytes per character

; Search character font
.l34c5
    add hl,de
    djnz l34c5

; Switch to C5 bank
    ld bc,#7fc5
    out (c),c

; Display letter.
    ld de,(CurrentLetterPosition)
    ld b,32       ; 32 line height character
.l34d3
    push bc
    push de

repeat 8
    ldi
rend

    pop de
    ex de,hl
    call ComputeNextLine
    ex de,hl
    pop bc
    djnz l34d3

; Set next position
    ld de,(CurrentLetterPosition)
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    inc de
    ld (CurrentLetterPosition),de

; Switch to C0 bank.
    ld bc,#7fc0
    out (c),c

    ret

; *****************************************************************************
; End of line, set next character position.
; *****************************************************************************
.l3504
    inc hl
    ld (TextAddress),hl

    ld de,(CurrentLetterPosition)
    ld hl,#0120
    add hl,de
    ld (CurrentLetterPosition),hl

    ret

; *****************************************************************************
; End of screen, reset character position to begin of screen.
; *****************************************************************************
.l3514
;
    inc hl
    ld (TextAddress),hl

;
    ld de,#d800
    ld (CurrentLetterPosition),de

;
    ld a,#03
    ld (l3584),a
    ret

; *****************************************************************************
; End of text, reset text pointer to begin, reset screen character position
; *****************************************************************************
.l3525

; Set beginning address of text.
    ld hl,#3700
    ld (TextAddress),hl

;
    ld de,#d800
    ld (CurrentLetterPosition),de

;
    ld a,#03
    ld (l3584),a
    ret

; *****************************************************************************
; Jump to next character position
; *****************************************************************************
.l3538
    ld de,(CurrentLetterPosition)
    inc hl
repeat 8
    inc de
rend
    ld (CurrentLetterPosition),de
    ld (TextAddress),hl
    ret

; *****************************************************************************
; Compute screen line under
; Input
;   HL = Current address line
; Output
;   HL = Address line under
; (AF,BC and HL are modified)
; *****************************************************************************
.ComputeNextLine
    ld a,h
    add #08
    ld h,a
    ret nc
    ld bc,#c060
    add hl,bc
    ret

.CurrentLetterPosition
    dw &D800

.TextAddress
    dw &3700

; *****************************************************************************
;
; *****************************************************************************
.TestKeys
    ld (KeysLine + 1),a
    ld bc,#f40e
    out (c),c
    ld bc,#f6c0
    out (c),c
    xor a
    out (c),a
    ld bc,#f792
    out (c),c
.KeysLine
    ld bc,#f648
    out (c),c
    ld b,#f4
    in a,(c)
    ld bc,#f782
    out (c),c
    ld bc,#f600
    out (c),c
    ret

; *****************************************************************************
; 
; *****************************************************************************
.l3584
  db &04

; *****************************************************************************
; 
; *****************************************************************************
.l3585
  dw &d800

; *****************************************************************************
; 
; *****************************************************************************  
.l3587
    dw &d801
    
.l3589
    ld a,h
    add #08
    ld h,a
    ret nc
    ld bc,#c060
    add hl,bc
    ret

; *****************************************************************************
; Second screen palette (fade in/out).
; *****************************************************************************
.l3593
  db #4b,#57,#5d

.l3596
  db #57,#5d,#44

.l3599
  db #5d,#44,#44

.l359c
  db #44,#44,#44

; *****************************************************************************
; First screen palette.
; *****************************************************************************
.Palette
    db GA_COLOR_SELECTION + GA_COLOR_SEA_GREEN
    db GA_COLOR_SELECTION + GA_COLOR_WHITE
    db GA_COLOR_SELECTION + GA_COLOR_GREEN
    db GA_COLOR_SELECTION + GA_COLOR_RED
    db GA_COLOR_SELECTION + GA_COLOR_BRIGHT_RED
    db GA_COLOR_SELECTION + GA_COLOR_ORANGE
    db GA_COLOR_SELECTION + GA_COLOR_PINK
    db GA_COLOR_SELECTION + GA_COLOR_PASTEL_YELLOW
    db GA_COLOR_SELECTION + GA_COLOR_BRIGHT_WHITE
    db GA_COLOR_SELECTION + GA_COLOR_PASTEL_CYAN
    db GA_COLOR_SELECTION + GA_COLOR_PASTEL_BLUE
    db GA_COLOR_SELECTION + GA_COLOR_SKY_BLUE
    db GA_COLOR_SELECTION + GA_COLOR_MAUVE
    db GA_COLOR_SELECTION + GA_COLOR_MAGENTA
    db GA_COLOR_SELECTION + GA_COLOR_BLUE
    db GA_COLOR_SELECTION + GA_COLOR_BLACK

  org &3700
  list

  db "CREDITS FOR ", &01, "THIS PIECE  ", &01, "OF ARTS !!! ", &01, "*/*/*/*/*/*/", &00
  db "- PREINTRO -", &01, "CODE : POWER", &01, "GFXS : GREG ", &01, "ZIK  : POWER", &00
  db "-  INTRO   -", &01, "CODE : POWER", &01, "GFXS : GREG ", &01, "ZIK  : GREG ", &00
  db "- MAINPART -", &01, "CODE : POWER", &01, "GFXS : GREG ", &01, "ZIKS : GREG ", &00
  db "- END PART -", &01, "CODE : POWER", &01, "GFXS : GREG ", &01, "ZIKS : GREG ", &00
  db "AFTER ONE MO", &01, "NTH OF HARD ", &01, "WORK ,BOOGER", &01, "IS FINISH ! ", &00
  db "I WOULD SAYI", &01, "NG HELLO TO:", &01, "BOUBA,NICKY ", &01, "ONE,RUDIGER,", &00
  db "SIOU,MADRAM,", &01, "GREG,BABAR,Z", &01, "IK,RAINBIRD,", &01, "MICK'RO,ATC.", &00
  db ",... GOOD BY", &01, "E AND GOOD E", &01, "NJOY !!!    ", &01, "      POWER ", &ff
