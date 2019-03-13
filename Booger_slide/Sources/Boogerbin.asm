; *****************************************************************************
; *                BOOGER SLIDE, A slide show by Delirium Gang.               *
; *                                 (-BOOGER.BIN)                             *
; *                                                                           *
; * Code            => Power                                                  *
; * Zik             => Greg                                                   *
; * Gfxs            => Greg                                                   *
; *                                                                           *
; *****************************************************************************
    org &2000
    nolist

; *****************************************************************************
;
; *****************************************************************************
    read "./define/def_hardware.asm"
    read "./define/def_firmware.asm"
    read "./define/def_macro.asm"

; Finds and initializes all background ROMs.
    ld hl,#abff       ; Address of last usable byte of memory.
    ld de,#0040       ; Address of first usable byte of memory.
    call KL_ROM_WALK

; Switch to RAM &C0.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Opens an input buffer and reads the first block of the file. (LOADING.BS)
    ld hl,l2453       ; Contains the filename's address.
    ld de,#94c2       ; Contains the address of the 2K buffer to use for reading the file.
    ld b,#0c          ; Length of the file.
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#94c2       ; Contains the address where the file is to be placed in RAM.
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #94c2
    
; Clear and display loading.
    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C4.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4

; Opens an input buffer and reads the first block of the file. (PREINTRO.BIN)
    ld hl,l245f
    ld de,#97f7
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#97f7
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #97f7

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (PREINTRO.MUS)
    ld hl,l246b
    ld de,#9e59
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#9e59
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #9e59

; Switch to bank C6.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG6

; Opens an input buffer and reads the first block of the file. (BOOGSLID.GFX)
    ld hl,l2477
    ld de,#8eca
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#8eca
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #8eca

; Switch to bank C0.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Opens an input buffer and reads the first block of the file. (PREINTRO.PRG)
    ld hl,l2483
    ld de,#a426
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#a426
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #a426

; Change horizontal screen resolution.
    ld bc,#bc01
    out (c),c
    ld bc,#bd28
    out (c),c
    ld bc,#bc02
    out (c),c
    ld bc,#bd2e
    out (c),c

; Start pre-intro
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (INTRO.GFX)
    ld hl,l248f
    ld de,#8955
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#8955
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #8955

; Switch to bank C7.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG7

; Opens an input buffer and reads the first block of the file. (INTRO.MUS)
    ld hl,l249b
    ld de,#9b56
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#9b56
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #9b56

; Switch to bank C0.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

; Opens an input buffer and reads the first block of the file. (INTRO.PRG)
    ld hl,l24a7
    ld de,#a18c
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#a18c
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #a18c

; Start intro
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Opens an input buffer and reads the first block of the file. (MAINPART.PRG)
    ld hl,l24b3
    ld de,#3000
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3000
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (CHRONO.PAL)
    ld hl,l24bf
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (CHRONO.BS)
    ld hl,l24cb
    ld de,#834f
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#834f
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #834f

    call l26e1

    call l260f

; Start screen 1
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C7.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG7

; Opens an input buffer and reads the first block of the file. (FREEING.BIN)
    ld hl,l24d7
    ld de,#9c57
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#9c57
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #9c57

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (DRAGON.PAL)
    ld hl,l24e3
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (DRAGON.BS)
    ld hl,l24ef
    ld de,#7b21
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#7b21
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #7b21

    call l26e1

    call l260f

; Start screen 2
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (GOHAN.PAL)
    ld hl,l24fb
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (GOHAN.BS)
    ld hl,l2507
    ld de,#7c5e
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#7c5e
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #7c5e

    call l26e1

    call l260f

; Start screen 3
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C7.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG7

; Opens an input buffer and reads the first block of the file. (GOA3.BIN)
    ld hl,l2513
    ld de,#9bc2
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#9bc2
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #9bc2

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (KANED.PAL)
    ld hl,l251f
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (KANED.BS)
    ld hl,l252b
    ld de,#81a6
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#81a6
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #81a6

    call l26e1

    call l260f

; Start screen 4
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (NEW.PAL)
    ld hl,l2537
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (NEW.BS)
    ld hl,l2543
    ld de,#7111
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#7111
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #7111

    call l26e1

    call l260f

; Start screen 5
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C7.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG7

; Opens an input buffer and reads the first block of the file. (GOA4.BIN)
    ld hl,l254f
    ld de,#99a3
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#99a3
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #99a3

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (ORION.PAL)
    ld hl,l255b
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (ORION.BS)
    ld hl,l2567
    ld de,#8028
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#8028
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #8028

    call l26e1

    call l260f

; Start screen 6
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (SONIC.PAL)
    ld hl,l2573
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (SONIC.BS)
    ld hl,l257f
    ld de,#85d4
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#85d4
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #85d4

    call l26e1

    call l260f

; Start screen 7
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C7.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG7

; Opens an input buffer and reads the first block of the file. (GOA.BIN)
    ld hl,l258b
    ld de,#957b
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#957b
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #957b

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (TETSUO.PAL)
    ld hl,l2597
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (TETSUO.BS)
    ld hl,l25a3
    ld de,#7f55
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#7f55
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #7f55

    call l26e1

    call l260f

; Start screen 8
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (WORM.PAL)
    ld hl,l25af
    ld de,#3300
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3300
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (WORM.BS)
    ld hl,l25bb
    ld de,#7fbc
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#7fbc
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #7fbc

    call l26e1

    call l260f

; Start screen 9
    call #3000

    call CLEAR_AND_DISPLAY_LOADING

    call CLEAR_AND_DISPLAY_LOADING

; Switch to bank C4.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG4

; Opens an input buffer and reads the first block of the file. (SPEEDA.END)
    ld hl,l25c7
    ld de,#8ce9
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#8ce9
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #8ce9

; Switch to bank C7.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG7

; Opens an input buffer and reads the first block of the file. (SPEEDB.END)
    ld hl,l25d3
    ld de,#9028
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#9028
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #9028

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

; Opens an input buffer and reads the first block of the file. (ENDPART.GFX)
    ld hl,l25df
    ld de,#8a5d
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#8a5d
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #8a5d

    call l26e1

    call l260f

; Switch to bank C0.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG0

    call CLEAR_AND_DISPLAY_LOADING

; Opens an input buffer and reads the first block of the file. (ENDPART.FNT)
    ld hl,l25eb
    ld de,#a08e
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#a08e
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Decompress file.
    call #a08e

; Opens an input buffer and reads the first block of the file. (ENDPART.PRG)
    ld hl,l25f7
    ld de,#3000
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#3000
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Opens an input buffer and reads the first block of the file. (ENDPART.TXT)
    ld hl,l2603
    ld de,#5000
    ld b,#0c
    call CAS_IN_OPEN

; Reads an entire file directly into memory.
    ld hl,#5000
    call CAS_IN_DIRECT

; Closes an input file.
    call CAS_IN_CLOSE

; Start end part.
    call #3000

.l2453
    db "LOADING .BS "
.l245f
    db "PREINTRO.GFX"
.l246b
    db "PREINTRO.MUS"
.l2477
    db "BOOGSLID.GFX"
.l2483
    db "PREINTRO.PRG"
.l248f
    db "INTRO   .GFX"
.l249b
    db "INTRO   .MUS"
.l24a7
    db "INTRO   .PRG"
.l24b3
    db "MAINPART.PRG"
.l24bf
    db "CHRONO  .PAL"
.l24cb
    db "CHRONO  .BS "
.l24d7
    db "FREEING .BIN"
.l24e3
    db "DRAGON  .PAL"
.l24ef
    db "DRAGON  .BS "
.l24fb
    db "GOHAN   .PAL"
.l2507
    db "GOHAN   .BS "
.l2513
    db "GOA3    .BIN"
.l251f
    db "KANED   .PAL"
.l252b
    db "KANED   .BS "
.l2537
    db "NEW     .PAL"
.l2543
    db "NEW     .BS "
.l254f
    db "GOA4    .BIN"
.l255b
    db "ORION   .PAL"
.l2567
    db "ORION   .BS "
.l2573
    db "SONIC   .PAL"
.l257f
    db "SONIC   .BS "
.l258b
    db "GOA     .BIN"
.l2597
    db "TETSUO  .PAL"
.l25a3
    db "TETSUO  .BS "
.l25af
    db "WORM    .PAL"
.l25bb
    db "WORM    .BS "
.l25c7
    db "SPEEDA  .END"
.l25d3
    db "SPEEDB  .END"
.l25df
    db "ENDPART .GFX"
.l25eb
    db "ENDPART .FNT"
.l25f7
    db "ENDPART .PRG"
.l2603
    db "ENDPART .TXT"

.l260f
    mMEMCPY &71fa,&c000,&31fa

; Switch to bank C6.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG6

    mMEMCPY &c000,&4000,&18fd

    mMEMCPY &d8fd,&6000,&18fd

; Switch to bank C5.
    mRAM_SELECT GA_RAM_BANK0,GA_RAM_CONFIG5

    mMEMCPY &58fd,&c000,&18fd

    mMEMCPY &c000,&6000,&18fd
    
    ret

; *****************************************************************************
; Clear screen, set black color then display LOADING logo
; *****************************************************************************
.CLEAR_AND_DISPLAY_LOADING

; All black inks.
    mPEN_SET_INK 0,0,0
    mPEN_SET_INK 1,0,0
    mPEN_SET_INK 2,0,0
    mPEN_SET_INK 3,0,0

; Border 0
    mBORDER_SET_INK 0,0

; Set middle screen resolution (320x200x2bpp).
    mMODE_SET MODE_MID_RESOLUTION

; Display LOA (50x80 bytes).
    mCOPYSPRITE &4000,&c240,&50,&32

; Display DING (47x81 bytes).
    mCOPYSPRITE &4fa5,&c271,&51,&2f

; Change horizontal screen size.
    ld bc,#bc01
    out (c),c
    ld bc,#bd30
    out (c),c
    ld bc,#bc02
    out (c),c
    ld bc,#bd32
    out (c),c

; Ink 1,26
    mPEN_SET_INK 1,&1a,&1a

;Ink 2,14
    mPEN_SET_INK 2,&0e,&0e

; Ink 3,5
    mPEN_SET_INK 3,&05,&05

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

; *****************************************************************************
;
; *****************************************************************************
.l26e1

; Set high screen resolution (640x200x1bpp).
    mMODE_SET MODE_LOW_RESOLUTION
    
; Ink 0,0
    mPEN_SET_INK 0,0,0

; Border 0
    mBORDER_SET_INK 0,0

; Ink 1,0
    mPEN_SET_INK 1,0,0

    ret
