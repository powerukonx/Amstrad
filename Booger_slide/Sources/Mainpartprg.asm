; *****************************************************************************
; *                BOOGER SLIDE, A slide show by Delirium Gang.               *
; *                                 (MAINPART.PRG)                            *
; *                                                                           *
; * Code            => Power                                                  *
; * Zik             => Greg                                                   *
; * Gfxs            => Greg                                                   *
; *                                                                           *
; *****************************************************************************
    org #3000
    run EntryPoint
    nolist
    
; *****************************************************************************
;
; *****************************************************************************
    read "./define/def_hardware.asm"
    read "./define/def_macro.asm"

; *****************************************************************************
;
; *****************************************************************************
SCREEN_INIT_MEMORYADDR    equ &c000    
UPPERSYS_BEGINADDR        equ &a67b  
SONG_INIT_ADDR            equ &4000
SONG_PLAY_ADDR            equ SONG_INIT_ADDR+3
SONG_STOP_ADDR            equ SONG_PLAY_ADDR+3

; *****************************************************************************
;
; *****************************************************************************
EntryPoint

; Initialize song (RAM #C7).
    mST128_INITSONG SONG_INIT_ADDR,GA_RAM_BANK0,GA_RAM_CONFIG7

; Disable interrupt.
    di    

; Save &8000 - &FFFF area in RAM #C4.
    SAVEUPPERSYS #4000,GA_RAM_BANK0,GA_RAM_CONFIG4

; Switch to RAM #C0.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Modify horizontal screen width.
    ld bc,PORT_CRTC_SELECT_REG + CRTC_HORIZONTAL_DISPLAYED
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #30
    out (c),c
    ld bc,PORT_CRTC_SELECT_REG + CRTC_HORIZONTAL_SYNC_POSITION
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #32
    out (c),c
    ld bc,PORT_CRTC_SELECT_REG + CRTC_SYNC_WIDTH
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #08
    out (c),c

; Set interrupt subroutine as RET-EI (save older), set SP at &4000 (save older).
    mISR_REMAP &c9fb, RestoreISR+1
    SP_REMAP &4000, RestoreSP+1

    ei

; Clear screen.
    mMEMCLR &8000,&8000

; Copy Upper-left part (from RAM #C5).
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5
    mCOPYSPRITE &4000,&c180,&88,&2f

; Copy Upper-right part
    mCOPYSPRITE &6000,&c1af,&88,&2f
    mMEMCPY &c000,&8000,&4000    

; Clear screen    
    mMEMCLR &c000,&4000

; Copy Lower-left part (from RAM #C6).
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG6
    mCOPYSPRITE &4000,&c000,&88,&2f

; Copy Lower-right part
    mCOPYSPRITE &6000,&c02f,&88,&2f

; Switch to RAM #C0.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Set start address of video memory for first screen (&8000).
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #20
    out (c),c
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_L
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #00
    out (c),c

.MainPart_Loop

; Wait fly-back.
    ld b,PPI_PORTB/256
.NoSync
    in a,(c)
    rra
    jp nc,NoSync

; Set VBL position to overflow value.
    ld bc,PORT_CRTC_SELECT_REG + CRTC_VERTICAL_SYNC_POSITION
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #ff
    out (c),c

; Set screen palette
    ld hl,(SCREEN_PALETTE)
    ld bc,GA_PORT + GA_PEN_SELECTION
    ld d,#10
.SetPalette
    out (c),c
    outi
    inc b
    inc c
    dec d
    jp nz,SetPalette

; Set low screen resolution (160x200x4bpp). 
    ld bc,GA_PORT + GA_SCR_MODE_ROM_CONF + GA_UPPER_ROM_ENABLE + GA_LOWER_ROM_ENABLE + GA_LOW_RESOLUTION
    out (c),c

; Set first screen vertical size.
    ld bc,PORT_CRTC_SELECT_REG + CRTC_VERTICAL_TOTAL
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #14
    out (c),c

    halt

; Play song (RAM #C7).
    ST128_PLAY &4003,GA_RAM_BANK0,GA_RAM_CONFIG7

; Switch to RAM #C0.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

    halt
    halt

    ld b,#09
.l3140
    ds 59,0
    djnz l3140

; Set second screen vertical size.   
    ld bc,PORT_CRTC_SELECT_REG + CRTC_VERTICAL_TOTAL
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #11
    out (c),c

; Set start address of video memory for second screen (&c000).
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #30
    out (c),c
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_L
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #00
    out (c),c

    halt
    halt

; Set start address of video memory for first screen (&8000).
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #20
    out (c),c
    ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_L
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #00
    out (c),c

; Set VBL now
    ld bc,PORT_CRTC_SELECT_REG + CRTC_VERTICAL_SYNC_POSITION
    out (c),c
    ld bc,PORT_CRTC_WRITE_DATA + #00
    out (c),c

; Test keys (SPACE).
    ld a,#45
    call Test_Keys
    cp #7f
    jp nz,MainPart_Loop

; Disable interrupt
    di    
    
; Restore area &8000-&FFFF from C4 bank.
    RESTOREEUPPERSYS &4000,GA_RAM_BANK0,GA_RAM_CONFIG4
    
; Switch to C0 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Restore stack and ISR.
.RestoreISR
    ld hl,#41c3
    ld (IM1_ISR_ADDR),hl
.RestoreSP
    ld sp,#bff6
    ei

; Stop song.
    ST128_STOP &4006,GA_RAM_BANK0,GA_RAM_CONFIG7

; Switch to C0 bank.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Restore CRTC registers values.
    ld bc,#bc0c
    out (c),c
    ld bc,#bd30
    out (c),c
    ld bc,#bc0d
    out (c),c
    ld bc,#bd00
    out (c),c
    ld bc,#bc04
    out (c),c
    ld bc,#bd26
    out (c),c
    ld bc,#bc07
    out (c),c
    ld bc,#bd1e
    out (c),c
    ld bc,#bc03
    out (c),c
    ld bc,#bd8e
    out (c),c
    ld bc,#bc01
    out (c),c
    ld bc,#bd28
    out (c),c
    ld bc,#bc02
    out (c),c
    ld bc,#bd2e
    out (c),c

; Set high screen resolution (640x200x1bpp).
    ld a,#02
    call #bc0e
    ret
    
    dw 0

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

; *****************************************************************************
; 
; ***************************************************************************** 
.Test_Keys
    ld (Test_Line + 1),a
    ld bc,PPI_PORTA + PSG_R14
    out (c),c
    ld bc,PPI_PORTC + PSG_SELECT_REG
    out (c),c
    xor a           ; PSG_VALIDATE
    out (c),a
    ld bc,PPI_PORT_CTRL + #92
    out (c),c
.Test_Line
    ld bc,PPI_PORTC
    out (c),c
    ld b,PPI_PORTA/256
    in a,(c)
    ld bc,PPI_PORT_CTRL + #82
    out (c),c
    ld bc,PPI_PORTC + PSG_VALIDATE
    out (c),c
    ret

SCREEN_PALETTE
    dw &3300

    org #3300
    db #54,#5c,#4c,#4e,#47,#43,#4b,#4b
    db #5b,#5f,#5d,#55,#44,#56,#52,#59    
    
    