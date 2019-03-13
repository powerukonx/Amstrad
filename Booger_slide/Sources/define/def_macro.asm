	nolist

IM1_ISR_ADDR              equ &0038

; **************************************
; * Set High/Mid/Low resolution mode   *
; * Low 160x200x16                     *
; * Mid 320*200*4                      *
; * High 640*200*2                     *
; **************************************
MODE_LOW_RESOLUTION      equ &00
MODE_MID_RESOLUTION      equ MODE_LOW_RESOLUTION + 1
MODE_HIGH_RESOLUTION     equ MODE_MID_RESOLUTION + 1

macro MODE_SET_LOW_RES
   xor a
   call SCR_SET_MODE
mend

macro MODE_SET_MID_RES
   ld a,MODE_MID_RESOLUTION
   call SCR_SET_MODE
mend

macro MODE_SET_HIGH_RES
   ld a,MODE_HIGH_RESOLUTION
   call SCR_SET_MODE
mend

macro mPEN_SET_INK pen,ink1,ink2
    ld a,pen
    ld bc,ink1*256 + ink2
    call SCR_SET_INK
mend

macro mBORDER_SET_INK ink1,ink2
    ld bc,ink1*256 + ink2
    call SCR_SET_BORDER
mend

macro mMODE_SET mode
   ld a,mode
   call SCR_SET_MODE
mend

macro mFW_MODE_SET mode
    ld a,mode
    call SCR_SET_MODE
mend

macro mHW_MODE_SET mode
    ld bc,GA_PORT + GA_SCR_MODE_ROM_CONF + GA_UPPER_ROM_ENABLE + GA_LOWER_ROM_ENABLE + mode
    out (c),c
mend



; **************************************
; * Disable event bloc that refresh    *
; * ink (RESET when mode change !!!)   *
; **************************************
macro REFRESH_OFF
  ld hl,&b7f9
  call KL_DEL_FRAME_FLY
mend

; **************************************
; * Reinitialize ROM7                  *
; **************************************
FIRST_USABLE_BYTE_OF_MEM equ &0040
LAST_USABLE_BYTE_OF_MEM  equ &ABFF
ROM_AMSDOS               equ &07

macro REINIT_ROM7
  ld de,FIRST_USABLE_BYTE_OF_MEM
  ld hl,LAST_USABLE_BYTE_OF_MEM
  ld c,ROM_AMSDOS
  call KL_INIT_BACK
mend


; ***************************************
; * Set RAM configuration               *
; * Input                               *
; *  bk = 64K bank number (0..7).       *
; *  cfg = RAM Config (0..7).           *
; * Ouput                               *
; *  None                               *
; * BC is modified                      *
; ***************************************
macro mRAM_SELECT bk,cfg
    ld bc,GA_PORT + GA_RAM_BANKING + cfg + bk
    out (c),c
mend

; Initialize ST128 song at address addr in bank bk.
macro mST128_INITSONG adr,bk,cfg
    mRAM_SELECT bk,cfg
    call adr
mend

; Play ST128 song at address addr in bank bk.
macro ST128_PLAY adr,bk,cfg
    mRAM_SELECT bk,cfg
    call adr
mend

; Stop ST128 song at address addr in bank bk.
macro ST128_STOP adr,bk,cfg
    mRAM_SELECT bk,cfg
    call adr
mend

; Save system from &8000 to &FFFF area in C4 bank
macro SAVEUPPERSYS adr,bk,cfg
    mRAM_SELECT bk,cfg
    ld hl,UPPERSYS_BEGINADDR
    ld de,adr
    ld bc,SCREEN_INIT_MEMORYADDR - UPPERSYS_BEGINADDR
    ldir
  mend

; Save system from &8000 to &FFFF area in C4 bank
macro RESTOREEUPPERSYS adr,bk,cfg
    mRAM_SELECT bk,cfg
    ld hl,adr
    ld de,UPPERSYS_BEGINADDR
    ld bc,SCREEN_INIT_MEMORYADDR - UPPERSYS_BEGINADDR
    ldir
mend

macro mISR_REMAP remap, save
    ld hl,(IM1_ISR_ADDR)
    ld (save),hl
    ld hl,remap
    ld (IM1_ISR_ADDR),hl
mend


macro SP_REMAP remap, save
    ld (save),sp
    ld sp,remap
mend

; *****************************************************************************
;
; *****************************************************************************
macro mMEMCPY src,dst,len
    ld hl,src
    ld de,dst
    ld bc,len
    ldir
mend

; *****************************************************************************
;
; *****************************************************************************
macro mMEMCLR startaddr,len  
    ld hl,startaddr
    ld de,startaddr + 1
    ld bc,len - 1
    ld (hl),l
    ldir
mend

; *****************************************************************************
;
; *****************************************************************************
macro mCOPYSPRITE src,dst,heigth,width
    ld hl,src
    ld de,dst
    ld b,heigth
    push bc
    push de
    ld bc,width
    ldir
    pop de
    ex de,hl
    call ComputeNextLine
    ex de,hl
    pop bc
    djnz $-14
mend


; **************************************
; * Set all inks black.                *
; **************************************
macro BLACK_INKS
  ld bc,PORT_GA + GA_PENR_BORDER
  ld a,GA_COLOR_BLACK
  out (c),c
  out (c),a
  dec c
  jr nz,$-7
  out (c),c
  out (c),a
mend

; **************************************
; * Set Hate Beats screen resolution.  *
; **************************************
macro SCREEN_CUSTOM_HATEBEATS
  ld bc,PORT_CRTC_SELECT_REG + CRTC_HORIZONTAL_DISPLAYED
  out (c),c
  inc b
  ld d,&30
  out (c),d
  dec b
  inc c
  out (c),c
  inc b
  ld d,&32
  out (c),d
  dec b
  inc c
  out (c),c
  inc b
  ld d,&06
  out (c),d
  dec b
  ld c,CRTC_VERTICAL_DISPLAYED
  out (c),c
  inc b
  ld d,&15
  out (c),d
  dec b
  inc c
  out (c),c
  inc b
  ld d,&1D
  out (c),d

mend



; **************************************
; * Screen synchronisation.            *
; **************************************
macro mSCREEN_SYNCHRONISE
  ld b,PPI_PORTB/256
  in a,(c)
  rra
  jr nc,$-3
  in a,(c)
  rra
  jr c,$-3
mend

; **************************************
; * Unlock ASIC.                       *
; **************************************
macro ASIC_UNLOCK
  di
  ld b,&bc
  ld hl,asic_unlock_sequence
  ld e,17
  ld a,(hl)
  out (c),a
  inc hl
  dec e
  jr nz,$-5
  ei
  jr asic_unlock_end
asic_unlock_sequence
  db &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee
asic_unlock_end
mend

; **************************************
; * Unlock ASIC (no di/ei).            *
; **************************************
macro ASIC_UNLOCK_NOIT
  ld b,PORT_CRTC_SELECT_REG/256
  ld hl,asic_unlock_sequence
  ld e,17
  ld a,(hl)
  out (c),a
  inc hl
  dec e
  jr nz,$-5
  jr asic_unlock_end
asic_unlock_sequence
  db &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee
asic_unlock_end
mend

; **************************************
; * ASIC page-in.                      *
; **************************************
macro ASIC_PAGEIN
  ld bc,&7fb8
  out (c),c
mend

; **************************************
; * ASIC page-out.                     *
; **************************************
macro ASIC_PAGEOUT
  ld bc,&7fa0
  out (c),c
mend


; **************************************
; * ASIC all colors (ink+spr) black.   *
; **************************************
macro ASIC_INKS_AND_SPR_BLACK
  ld hl,&6400
  ld (hl),l
  ld de,&6401
  ld bc,63
  ldir
mend

; **************************************
; * Test ASIC, reset if not            *
; **************************************
macro TEST_ASIC
  ASIC_PAGEOUT
  ld a,1
  ld (&4000),a

  ASIC_PAGEIN
  dec a
  ld (&4000),a
  ld d,a

  ASIC_PAGEOUT
  ld a,(&4000)
  cp d
  jr nz,Test_Asic_End

; Test Ko
  ld hl,Test_Asic_Text
Test_Asic_Loop
  ld a,(hl)
  or a
  jr z,Test_Asic_Loop_Reset
  call TXT_OUTPUT
  inc hl
  jr Test_Asic_Loop

; Wait 5s before reset
Test_Asic_Loop_Reset
  ld b,250
loop_reset2
  call MC_WAIT_FLYBACK
  djnz loop_reset2
  jp 0

Test_Asic_Text
  db "Sorry, no ASIC...",0
Test_Asic_End

mend

; **************************************
; * Test 128Ko memory, reset if not    *
; **************************************
macro TEST_128KO
  SELECT_BANK_CONF_C0
  ld a,1
  ld (&4000),a

  SELECT_BANK_CONF_C4
  dec a
  ld (&4000),a
  ld d,a

  SELECT_BANK_CONF_C0
  ld a,(&4000)
  cp d
  jr nz,Test_128Ko_End

; Test Ko
  ld hl,Test_128Ko_Text
Test_128Ko_Loop
  ld a,(hl)
  or a
  jr z,Test_128Ko_Loop_Reset
  call TXT_OUTPUT
  inc hl
  jr Test_128Ko_Loop

; Wait 5s before reset
Test_128Ko_Loop_Reset
  ld b,250
loop_reset
  call MC_WAIT_FLYBACK
  djnz loop_reset
  jp 0

Test_128Ko_Text
  db "Sorry, need 128Ko...",0
Test_128Ko_End
mend

macro M_TESTKEYS line
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
      ld bc,PPI_PORTC + line
      out (c),c
      ld b,PPI_PORTA/256
      in a,(c)
      ld bc,PPI_PORT_CTRL + #82
      out (c),c
      ld bc,PPI_PORTC + PSG_VALIDATE
      out (c),c
mend

