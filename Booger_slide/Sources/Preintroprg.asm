; *****************************************************************************
; *                BOOGER SLIDE, A slide show by Delirium Gang.               *
; *                                 (PREINTRO.PRG)                            *
; *                                                                           *
; * Code            => Power                                                  *
; * Zik             => Power                                                  *
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
macro mFADEIN
    call FadeSeq1
    call FadeSeq2
    call FadeSeq3
mend

; *****************************************************************************
;
; *****************************************************************************
macro mFADEOUT
    call FadeSeq3
    call FadeSeq2
    call FadeSeq1
mend

EntryPoint

; Set pen inks.
    mPEN_SET_INK 0,0,0
    mPEN_SET_INK 1,0,0
    mPEN_SET_INK 2,0,0
    mPEN_SET_INK 3,0,0

; Set border ink.
    mBORDER_SET_INK 0,0

; Middle screen resolution (320x200x2bpp).
    mMODE_SET 1

; Set RET as interrupt subroutine (save older).
    di
    mISR_REMAP &c9fb, RestoreIsr + 1
    ei

; Initialize song (on bank C5).
    mST128_INITSONG SONG_INIT_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Copy GREG logo.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4
    mCOPYSPRITE &4000,&c330,&1f,&28

; Fade IN.
    mFADEIN

; Stay IN for 2840ms.
    call WaitIn

; Fade OUT.
    mFADEOUT

; Stay OUT for 400ms.
    call WaitOut

; Display AND logo.
    mCOPYSPRITE &4505,&c330,&1f,&28

; Fade IN.
    mFADEIN

; Stay IN for 2840ms.
    call WaitIn

; Fade OUT.
    mFADEOUT

; Stay OUT for 400ms.
    call WaitOut

; Display POWER logo.
    mCOPYSPRITE &49e2,&c330,&1f,&28

; Fade IN and wait 2840ms.
    mFADEIN

; Stay IN for 2840ms.
    call WaitIn

; Fade OUT.
    mFADEOUT

; Stay OUT for 400ms.
    call WaitOut

; Display PRESENT logo.
    mCOPYSPRITE &4f0f,&c32a,&1f,&39

; Fade IN.
    mFADEIN

; Stay IN for 2840ms.
    call WaitIn

; Fade OUT.
    mFADEOUT

; Stay OUT for 400ms.
    call WaitOut

; Clear screen
    ld hl,#c32a
    ld de,#c32b
    ld b,#1f
.l310c
    push bc
    push de
    push hl
    ld (hl),#00
    ld bc,#0039
    ldir
    pop hl
    call ComputeNextLine
    pop de
    ex de,hl
    call ComputeNextLine
    ex de,hl
    pop bc
    djnz l310c

; Wait fly-back.
    mSCREEN_SYNCHRONISE

; Play song.
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Switch to C6 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG6
    mCOPYSPRITE &4000,&c000,&43,&50

; Wait fly-back.
    mSCREEN_SYNCHRONISE

; Play song.
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Switch to C6 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG6
    mCOPYSPRITE &5590,&c3c2,&4f,&42

; Wait fly-back.
.l3182
    mSCREEN_SYNCHRONISE

; Set low resolution mode (160x200x4bpp).
    ld bc,GA_PORT + GA_SCR_MODE_ROM_CONF + GA_UPPER_ROM_ENABLE + GA_LOWER_ROM_ENABLE + GA_LOW_RESOLUTION
    out (c),c

; Set BOOGER SLIDE logo palette.
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

; Play song.
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Check for SPACE key to break loop.
    ld bc,PPI_PORTA + PSG_R14
    out (c),c
    ld bc,PPI_PORTC + PSG_SELECT_REG
    out (c),c
    xor a
    out (c),a
    ld bc,PPI_PORT_CTRL + #92
    out (c),c
    ld bc,PPI_PORTC + #45
    out (c),c
    ld b,PPI_PORTA/256
    in a,(c)
    ld bc,PPI_PORT_CTRL + #82
    out (c),c
    ld bc,PPI_PORTC + PSG_VALIDATE
    out (c),c
    rla
    jp c,l3182

; Restore interrupt subroutine.
    di
.RestoreIsr
    ld hl,&0000
    ld (IM1_ISR_ADDR),hl
    ei

; Stop song.
    ST128_STOP SONG_STOP_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Switch to C0 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Set high screen resolution (640x400x1bpp).
    mMODE_SET 2

; Set pen ink.
    mPEN_SET_INK 0,1,1
    mPEN_SET_INK 1,24,24

; Set border ink
    mBORDER_SET_INK 1,1

    ret

; *****************************************************************************
;
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

; *****************************************************************************
;
; *****************************************************************************
.FLYBACK_TO_WAIT
    dw &0000

; *****************************************************************************
;
; *****************************************************************************
.FadeSeq1

; 100ms loop.
    ld hl,5
    ld (FLYBACK_TO_WAIT),hl

; Do ...
.l3267
    mSCREEN_SYNCHRONISE

; Set palette.
    di

; Ink 1,1
    ld bc,PORT_GA + GA_PENR + GA_PENR_1
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLUE
    out (c),c:out (c),a

; Ink 2,0
    inc c
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLACK
    out (c),c:out (c),a

; Ink 3,0
    inc c
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLACK
    out (c),c:out (c),a
    ei

; Play song
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Switch to C4 bank
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4

; ...until 100ms elapsed.
    ld hl,(FLYBACK_TO_WAIT)
    dec hl
    ld (FLYBACK_TO_WAIT),hl
    ld a,h
    or l
    jp nz,l3267

    ret

; *****************************************************************************
;
; *****************************************************************************
.FadeSeq2

; 100ms loop.
    ld hl,5
    ld (FLYBACK_TO_WAIT),hl

; Do ...
.l32a8
    mSCREEN_SYNCHRONISE

; Set palette.
    di

; Ink 1,2
    ld bc,PORT_GA + GA_PENR + GA_PENR_1
    ld a,GA_COLOR_SELECTION + GA_COLOR_BRIGHT_BLUE
    out (c),c:out (c),a

; Ink 2,1
    inc c
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLUE
    out (c),c:out (c),a

; Ink 3,0
    inc c
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLACK
    out (c),c:out (c),a
    ei

; Play song
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Switch to C4 bank
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4

; ...until 100ms elapsed.
    ld hl,(FLYBACK_TO_WAIT)
    dec hl
    ld (FLYBACK_TO_WAIT),hl
    ld a,h
    or l
    jp nz,l32a8
    ret

; *****************************************************************************
;
; *****************************************************************************
.FadeSeq3

; 100ms loop.
    ld hl,5
    ld (FLYBACK_TO_WAIT),hl

; Do ...
.l32e9
    mSCREEN_SYNCHRONISE

    di

; Ink 1,5
    ld bc,PORT_GA + GA_PENR + GA_PENR_1
    ld a,GA_COLOR_SELECTION + GA_COLOR_MAUVE
    out (c),c:out (c),a
    inc c

; Ink 1,2
    ld a,GA_COLOR_SELECTION + GA_COLOR_BRIGHT_BLUE
    out (c),c:out (c),a
    inc c

; Ink 1,1
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLUE
    out (c),c:out (c),a
    ei

; Play song
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Switch to C4 bank
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4

; ...until 100ms elapsed.
    ld hl,(FLYBACK_TO_WAIT)
    dec hl
    ld (FLYBACK_TO_WAIT),hl
    ld a,h
    or l
    jp nz,l32e9
    ret

; *****************************************************************************
;
; *****************************************************************************
.WaitIn

; 2840ms loop.
    ld hl,142
    ld (FLYBACK_TO_WAIT),hl

; Do ...
.l332a
    mSCREEN_SYNCHRONISE

    di

; Ink 1,26
    ld bc,PORT_GA + GA_PENR + GA_PENR_1
    ld a,GA_COLOR_SELECTION + GA_COLOR_BRIGHT_WHITE
    out (c),c:out (c),a

; Ink 2,14
    inc c
    ld a,GA_COLOR_SELECTION + GA_COLOR_PASTEL_BLUE
    out (c),c:out (c),a

; Ink 3,5
    inc c
    ld a,GA_COLOR_SELECTION + GA_COLOR_MAUVE
    out (c),c:out (c),a
    ei

; Play song
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Switch to C4 bank
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4

; ...until 2840ms elapsed.
    ld hl,(FLYBACK_TO_WAIT)
    dec hl
    ld (FLYBACK_TO_WAIT),hl
    ld a,h
    or l
    jp nz,l332a
    ret

; *****************************************************************************
;
; *****************************************************************************
.WaitOut

; 400ms loop.
    ld hl,20
    ld (FLYBACK_TO_WAIT),hl

; Do ...
.l336b
    mSCREEN_SYNCHRONISE

; Ink 1,0
    ld bc,PORT_GA + GA_PENR + GA_PENR_1
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLACK
    out (c),c:out (c),a

; Ink 2,0
    inc c
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLACK
    out (c),c:out (c),a

; Ink 3,0
    inc c
    ld a,GA_COLOR_SELECTION + GA_COLOR_BLACK
    out (c),c:out (c),a

; Play song
    ST128_PLAY SONG_PLAY_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG5

; Switch to C4 bank
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4

; ...until 400ms elapsed.
    ld hl,(FLYBACK_TO_WAIT)
    dec hl
    ld (FLYBACK_TO_WAIT),hl
    ld a,h
    or l
    jp nz,l336b
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
    ld bc,#c050
    add hl,bc
    ret
