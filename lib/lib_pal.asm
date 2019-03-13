; *****************************************************************************
; * PAL library
; * Code => POWER/UKONX
; *****************************************************************************

PAL_PORT                      equ &7F00


; Registers definition.
PAL_MMR                       equ %11000000


; MMR bit definition.
PAL_MMR_BANK0                  equ %00000000
PAL_MMR_BANK1                  equ %00001000
PAL_MMR_BANK2                  equ %00010000
PAL_MMR_BANK3                  equ %00011000
PAL_MMR_BANK4                  equ %00100000
PAL_MMR_BANK5                  equ %00101000
PAL_MMR_BANK6                  equ %00110000
PAL_MMR_BANK7                  equ %00111000
PAL_MMR_CONFIG0                equ %00000000
PAL_MMR_CONFIG1                equ %00000001
PAL_MMR_CONFIG2                equ %00000010
PAL_MMR_CONFIG3                equ %00000011
PAL_MMR_CONFIG4                equ %00000100
PAL_MMR_CONFIG5                equ %00000101
PAL_MMR_CONFIG6                equ %00000110
PAL_MMR_CONFIG7                equ %00000111


; *****************************************************************************
; Set RAM configuration
; Input
;  bk = 64K bank number (0..7).
;  cfg = RAM Config (0..7).
; Ouput
;  None
; BC is modified
; *****************************************************************************
macro mPAL_RAM_SELECT bk,cfg
    ld bc,PAL_PORT + PAL_MMR + cfg + bk
    out (c),c
mend


; *****************************************************************************
; * Test 128Ko memory, reset if not                                           *
; *****************************************************************************
macro mPAL_TEST_128KO
  mPAL_RAM_SELECT PAL_MMR_BANK0, PAL_MMR_CONFIG0
  ld a,1
  ld (&4000),a

  mPAL_RAM_SELECT PAL_MMR_BANK0, PAL_MMR_CONFIG4
  dec a
  ld (&4000),a
  ld d,a

  mPAL_RAM_SELECT PAL_MMR_BANK0, PAL_MMR_CONFIG0
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

