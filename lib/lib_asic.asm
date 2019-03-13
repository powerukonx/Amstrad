; *****************************************************************************
; * ASIC library
; * Code => POWER/UKONX
; *****************************************************************************
nolist

; *****************************************************************************
; Definition.
; *****************************************************************************
ASIC_START_ADR                  equ &4000
ASIC_SPR_XSIZE                  equ 16
ASIC_SPR_YSIZE                  equ 16
ASIC_SPR_SIZE                   equ ASIC_SPR_XSIZE*ASIC_SPR_YSIZE

ASIC_ADR_SPR0                   equ ASIC_START_ADR
ASIC_ADR_SPR1                   equ ASIC_ADR_SPR0 + ASIC_SPR_SIZE
ASIC_ADR_SPR2                   equ ASIC_ADR_SPR1 + ASIC_SPR_SIZE
ASIC_ADR_SPR3                   equ ASIC_ADR_SPR2 + ASIC_SPR_SIZE
ASIC_ADR_SPR4                   equ ASIC_ADR_SPR3 + ASIC_SPR_SIZE
ASIC_ADR_SPR5                   equ ASIC_ADR_SPR4 + ASIC_SPR_SIZE
ASIC_ADR_SPR6                   equ ASIC_ADR_SPR5 + ASIC_SPR_SIZE
ASIC_ADR_SPR7                   equ ASIC_ADR_SPR6 + ASIC_SPR_SIZE
ASIC_ADR_SPR8                   equ ASIC_ADR_SPR7 + ASIC_SPR_SIZE
ASIC_ADR_SPR9                   equ ASIC_ADR_SPR8 + ASIC_SPR_SIZE
ASIC_ADR_SPR10                  equ ASIC_ADR_SPR9 + ASIC_SPR_SIZE
ASIC_ADR_SPR11                  equ ASIC_ADR_SPR10 + ASIC_SPR_SIZE
ASIC_ADR_SPR12                  equ ASIC_ADR_SPR11 + ASIC_SPR_SIZE
ASIC_ADR_SPR13                  equ ASIC_ADR_SPR12 + ASIC_SPR_SIZE
ASIC_ADR_SPR14                  equ ASIC_ADR_SPR13 + ASIC_SPR_SIZE
ASIC_ADR_SPR15                  equ ASIC_ADR_SPR14 + ASIC_SPR_SIZE

ASIC_ADR_SPR0_POSX              equ &6000 ; LSB/MSB (16bits)
ASIC_ADR_SPR0_POSY              equ &6002 ; LSB/MSB (16bits)
ASIC_ADR_SPR0_ZOOM              equ &6004

ASIC_ADR_SPR1_POSX              equ &6008 ; LSB/MSB (16bits)
ASIC_ADR_SPR1_POSY              equ &600A ; LSB/MSB (16bits)
ASIC_ADR_SPR1_ZOOM              equ &600C

ASIC_ADR_SPR2_POSX              equ &6010 ; LSB/MSB (16bits)
ASIC_ADR_SPR2_POSY              equ &6012 ; LSB/MSB (16bits)
ASIC_ADR_SPR2_ZOOM              equ &6014

ASIC_ADR_SPR3_POSX              equ &6018 ; LSB/MSB (16bits)
ASIC_ADR_SPR3_POSY              equ &601A ; LSB/MSB (16bits)
ASIC_ADR_SPR3_ZOOM              equ &601C

ASIC_ADR_SPR4_POSX              equ &6020 ; LSB/MSB (16bits)
ASIC_ADR_SPR4_POSY              equ &6022 ; LSB/MSB (16bits)
ASIC_ADR_SPR4_ZOOM              equ &6024

ASIC_ADR_SPR5_POSX              equ &6028 ; LSB/MSB (16bits)
ASIC_ADR_SPR5_POSY              equ &602A ; LSB/MSB (16bits)
ASIC_ADR_SPR5_ZOOM              equ &602C

ASIC_ADR_SPR6_POSX              equ &6030 ; LSB/MSB (16bits)
ASIC_ADR_SPR6_POSY              equ &6032 ; LSB/MSB (16bits)
ASIC_ADR_SPR6_ZOOM              equ &6034

ASIC_ADR_SPR7_POSX              equ &6038 ; LSB/MSB (16bits)
ASIC_ADR_SPR7_POSY              equ &603A ; LSB/MSB (16bits)
ASIC_ADR_SPR7_ZOOM              equ &603C

ASIC_ADR_SPR8_POSX              equ &6040 ; LSB/MSB (16bits)
ASIC_ADR_SPR8_POSY              equ &6042 ; LSB/MSB (16bits)
ASIC_ADR_SPR8_ZOOM              equ &6044

ASIC_ADR_SPR9_POSX              equ &6048 ; LSB/MSB (16bits)
ASIC_ADR_SPR9_POSY              equ &604A ; LSB/MSB (16bits)
ASIC_ADR_SPR9_ZOOM              equ &604C

ASIC_ADR_SPR10_POSX             equ &6050 ; LSB/MSB (16bits)
ASIC_ADR_SPR10_POSY             equ &6052 ; LSB/MSB (16bits)
ASIC_ADR_SPR10_ZOOM             equ &6054

ASIC_ADR_SPR11_POSX             equ &6058 ; LSB/MSB (16bits)
ASIC_ADR_SPR11_POSY             equ &605A ; LSB/MSB (16bits)
ASIC_ADR_SPR11_ZOOM             equ &605C

ASIC_ADR_SPR12_POSX             equ &6060 ; LSB/MSB (16bits)
ASIC_ADR_SPR12_POSY             equ &6062 ; LSB/MSB (16bits)
ASIC_ADR_SPR12_ZOOM             equ &6064

ASIC_ADR_SPR13_POSX             equ &6068 ; LSB/MSB (16bits)
ASIC_ADR_SPR13_POSY             equ &606A ; LSB/MSB (16bits)
ASIC_ADR_SPR13_ZOOM             equ &606C

ASIC_ADR_SPR14_POSX             equ &6070 ; LSB/MSB (16bits)
ASIC_ADR_SPR14_POSY             equ &6072 ; LSB/MSB (16bits)
ASIC_ADR_SPR14_ZOOM             equ &6074

ASIC_ADR_SPR15_POSX             equ &6078 ; LSB/MSB (16bits)
ASIC_ADR_SPR15_POSY             equ &607A ; LSB/MSB (16bits)
ASIC_ADR_SPR15_ZOOM             equ &607C

ASIC_ADR_PEN0_COLOR             equ &6400
ASIC_ADR_PEN1_COLOR             equ &6402
ASIC_ADR_PEN2_COLOR             equ &6404
ASIC_ADR_PEN3_COLOR             equ &6406
ASIC_ADR_PEN4_COLOR             equ &6408
ASIC_ADR_PEN5_COLOR             equ &640A
ASIC_ADR_PEN6_COLOR             equ &640C
ASIC_ADR_PEN7_COLOR             equ &640E
ASIC_ADR_PEN8_COLOR             equ &6410
ASIC_ADR_PEN9_COLOR             equ &6412
ASIC_ADR_PEN10_COLOR            equ &6414
ASIC_ADR_PEN11_COLOR            equ &6416
ASIC_ADR_PEN12_COLOR            equ &6418
ASIC_ADR_PEN13_COLOR            equ &641A
ASIC_ADR_PEN14_COLOR            equ &641C
ASIC_ADR_PEN15_COLOR            equ &641E
ASIC_ADR_BORDER_COLOR           equ &6420

ASIC_ADR_SPR1_COLOR             equ &6422
ASIC_ADR_SPR2_COLOR             equ &6424
ASIC_ADR_SPR3_COLOR             equ &6426
ASIC_ADR_SPR4_COLOR             equ &6428
ASIC_ADR_SPR5_COLOR             equ &642A
ASIC_ADR_SPR6_COLOR             equ &642C
ASIC_ADR_SPR7_COLOR             equ &642E
ASIC_ADR_SPR8_COLOR             equ &6430
ASIC_ADR_SPR9_COLOR             equ &6432
ASIC_ADR_SPR10_COLOR            equ &6434
ASIC_ADR_SPR11_COLOR            equ &6436
ASIC_ADR_SPR12_COLOR            equ &6438
ASIC_ADR_SPR13_COLOR            equ &643A
ASIC_ADR_SPR14_COLOR            equ &643C
ASIC_ADR_SPR15_COLOR            equ &643E

ASIC_REG_PRI                    equ &6800 ; Programmable raster interrupt (8bits)
ASIC_REG_SPLT                   equ &6801 ; Split screen (8bits)
ASIC_REG_SSA_H                  equ &6802 ; Split screen start address (LSB/MSB 16bits)
ASIC_REG_SSA_L                  equ &6803 ; Split screen start address (LSB/MSB 16bits)
ASIC_REG_SSCR                   equ &6804 ; Soft Scroll (8bits)
ASIC_REG_IVR                    equ &6805 ; Vectored interrupts

ASIC_REG_ADC0                   equ &6808
ASIC_REG_ADC1                   equ &6809
ASIC_REG_ADC2                   equ &680A
ASIC_REG_ADC3                   equ &680B
ASIC_REG_ADC4                   equ &680C
ASIC_REG_ADC5                   equ &680D
ASIC_REG_ADC6                   equ &680E
ASIC_REG_ADC7                   equ &680F

ASIC_REG_SAR0                   equ &6C00 ; DMA0 Source address register (LSB/MSB 16 bits)
ASIC_REG_PPR0                   equ &6C02 ; DMA0 Pause prescaler register (8bits)
ASIC_REG_SAR1                   equ &6C04 ; DMA1 Source address register (LSB/MSB 16 bits)
ASIC_REG_PPR1                   equ &6C06 ; DMA1 Pause prescaler register (8bits)
ASIC_REG_SAR2                   equ &6C08 ; DMA2 Source address register (LSB/MSB 16 bits)
ASIC_REG_PPR2                   equ &6C0A ; DMA2 Pause prescaler register (8bits)
ASIC_REG_DCSR                   equ &6C0F ; Control and status register

ASIC_DMA_LOAD_R_D               equ &0000 ; DMA Command LOAD
ASIC_DMA_PAUSE_N                equ &1000 ; DMA Command PAUSE
ASIC_DMA_REPEAT_N               equ &2000 ; DMA Command REPEAT
ASIC_DMA_NOP_N                  equ &4000 ; DMA Command NOP
ASIC_DMA_LOOP                   equ &4001 ; DMA Command LOOP
ASIC_DMA_INT                    equ &4010 ; DMA Command INT
ASIC_DMA_STOP                   equ &4020 ; DMA Command STOP

ASIC_DMA_CHANNEL_0              equ %00000001
ASIC_DMA_CHANNEL_1              equ %00000010
ASIC_DMA_CHANNEL_2              equ %00000100

; *****************************************************************************
;  Unlock ASIC.
;
; *****************************************************************************
; Definition
ASIC_INT_DISABLE_OFF            equ 0
ASIC_INT_DISABLE_ON             equ 1

; Macro
macro mASIC_UNLOCK disableIT

if disableIT=ASIC_INT_DISABLE_ON
  di
endif

  ld b,CRTC_PORT_SELECT_REG/256
  ld hl,asic_unlock_sequence
  ld e,17
  ld a,(hl)
  out (c),a
  inc hl
  dec e
  jr nz,$-5

if disableIT=ASIC_INT_DISABLE_ON
  ei
endif

  jr asic_unlock_end
.asic_unlock_sequence
  db &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee
.asic_unlock_end
  nop
mend

; *****************************************************************************
; Page in/out ASIC.
; (BC if modified)
; *****************************************************************************
; Definition
ASIC_PAGE_OUT                   equ 0
ASIC_PAGE_IN                    equ 1

; Macro
macro mASIC_PAGE state
if state=ASIC_PAGE_IN
    ld bc,GA_PORT + GA_RMR + GA_RMR2_ASIC_ON
else
    ld bc,GA_PORT + GA_RMR + GA_RMR2_ASIC_OFF
endif
    out (c),c
mend

; *****************************************************************************
; Set blacks colors to pens/sprites.
;
; *****************************************************************************
; Definition
ASIC_PENS_BLACK_OFF             equ 0
ASIC_PENS_BLACK_ON              equ 1

ASIC_SPR_BLACK_OFF              equ 0
ASIC_SPR_BLACK_ON               equ 1

; Macro
macro mASIC_INKS_BLACK pen,sprite
if pen=ASIC_PENS_BLACK_ON
  ld hl,ASIC_ADR_PEN0_COLOR
  ld de,ASIC_ADR_PEN0_COLOR + 1
  ld (hl),l
  if sprite=ASIC_SPR_BLACK_ON
    ld bc,63
  else
    ld bc,31
  endif
  ldir
else
  if sprite=ASIC_SPR_BLACK_ON
    ld hl,ASIC_ADR_SPR1_COLOR
    ld de,ASIC_ADR_SPR1_COLOR + 1
    ld (hl),0
    ld b,29
    ldir
  endif
endif
mend


; *****************************************************************************
; Test ASIC, reset if not.
;
; *****************************************************************************
macro TEST_ASIC
  mASIC_PAGE ASIC_PAGE_OUT
  ld a,1
  ld (ASIC_START_ADR),a

  mASIC_PAGE ASIC_PAGE_IN
  dec a
  ld (ASIC_START_ADR),a
  ld d,a

  mASIC_PAGE ASIC_PAGE_OUT
  ld a,(ASIC_START_ADR)
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



