; Port definition
;        -----------------------------------------------------------------------------------------------
;       | A15 | A14 | A13 | A12 | A11 | A10 |  A9 |  A8 |  A7 |  A6 |  A5 |  A4 |  A3 |  A2 |  A1 |  A0 |
;       ------------------------------------------------------------------------------------------------
; CRTC  |     | CSn |     |     |     |     |R/Wn |  RS |     |     |     |     |     |     |     |     |
; GA    |  x  |  x  |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
; PPI   |     |     |     |     | CSn |     |  A1 |  A0 |     |     |     |     |     |     |     |     |

; **************************************
; Gate Array
; definition.
; **************************************
; Ports.
GA_PORT                       equ &7F00
PAL_PORT                      equ GA_PORT

PORT_GA                       equ &7F00
PORT_PAL                      equ PORT_GA

; Registers.
GA_PEN_SELECTION              equ %00000000
GA_COLOR_SELECTION            equ %01000000
GA_SCR_MODE_ROM_CONF          equ %10000000
GA_RAM_BANKING                equ %11000000

; Gate array definition
GA_PENR                       equ %00000000
GA_INKR                       equ %01000000
GA_RMR                        equ %10000000
GA_RMR2                       equ %10100000
GA_MMR                        equ %11000000

GA_PENR_0                     equ %00000000
GA_PENR_1                     equ %00000001
GA_PENR_2                     equ %00000010
GA_PENR_3                     equ %00000011
GA_PENR_4                     equ %00000100
GA_PENR_5                     equ %00000101
GA_PENR_6                     equ %00000110
GA_PENR_7                     equ %00000111
GA_PENR_8                     equ %00001000
GA_PENR_9                     equ %00001001
GA_PENR_10                    equ %00001010
GA_PENR_11                    equ %00001011
GA_PENR_12                    equ %00001100
GA_PENR_13                    equ %00001101
GA_PENR_14                    equ %00001110
GA_PENR_15                    equ %00001111
GA_PENR_BORDER                equ %00010000

; GATE ARRAY Pen selection value.
GA_PEN0                       equ %00000000
GA_PEN1                       equ %00000001
GA_PEN2                       equ %00000010
GA_PEN3                       equ %00000011
GA_PEN4                       equ %00000100
GA_PEN5                       equ %00000101
GA_PEN6                       equ %00000110
GA_PEN7                       equ %00000111
GA_PEN8                       equ %00001000
GA_PEN9                       equ %00001001
GA_PEN10                      equ %00001010
GA_PEN11                      equ %00001011
GA_PEN12                      equ %00001100
GA_PEN13                      equ %00001101
GA_PEN14                      equ %00001110
GA_PEN15                      equ %00001111
GA_BORDER                     equ %00010000

; GATE ARRAY Color selection value.
GA_COLOR_WHITE                equ %00000000
GA_COLOR_WHITE_2              equ %00000001
GA_COLOR_SEA_GREEN            equ %00000010
GA_COLOR_PASTEL_YELLOW        equ %00000011
GA_COLOR_BLUE                 equ %00000100
GA_COLOR_PURPLE               equ %00000101
GA_COLOR_CYAN                 equ %00000110
GA_COLOR_PINK                 equ %00000111
GA_COLOR_PURPLE_2             equ %00001000
GA_COLOR_PASTEL_YELLOW_2      equ %00001001
GA_COLOR_BRIGHT_YELLOW        equ %00001010
GA_COLOR_BRIGHT_WHITE         equ %00001011
GA_COLOR_BRIGHT_RED           equ %00001100
GA_COLOR_BRIGHT_MAGENTA       equ %00001101
GA_COLOR_ORANGE               equ %00001110
GA_COLOR_PASTEL_MAGENTA       equ %00001111
GA_COLOR_BLUE_2               equ %00010000
GA_COLOR_SEA_GREEN_2          equ %00010001
GA_COLOR_BRIGHT_GREEN         equ %00010010
GA_COLOR_BRIGHT_CYAN          equ %00010011
GA_COLOR_BLACK                equ %00010100
GA_COLOR_BRIGHT_BLUE          equ %00010101
GA_COLOR_GREEN                equ %00010110
GA_COLOR_SKY_BLUE             equ %00010111
GA_COLOR_MAGENTA              equ %00011000
GA_COLOR_PASTEL_GREEN         equ %00011001
GA_COLOR_LIME                 equ %00011010
GA_COLOR_PASTEL_CYAN          equ %00011011
GA_COLOR_RED                  equ %00011100
GA_COLOR_MAUVE                equ %00011101
GA_COLOR_YELLOW               equ %00011110
GA_COLOR_PASTEL_BLUE          equ %00011111

; GATE ARRAY Screen mode and ROM configuraion value.
GA_INT_RESET                  equ %00010000
GA_UPPER_ROM_ENABLE           equ %00001000
GA_LOWER_ROM_ENABLE           equ %00000100
GA_HIG_RESOLUTION             equ %00000010
GA_MID_RESOLUTION             equ %00000001
GA_LOW_RESOLUTION             equ %00000000

; GATE ARRAY RAM banking.
GA_RAM_BANK0                  equ %00000000
GA_RAM_BANK1                  equ %00001000
GA_RAM_BANK2                  equ %00010000
GA_RAM_BANK3                  equ %00011000
GA_RAM_BANK4                  equ %00100000
GA_RAM_BANK5                  equ %00101000
GA_RAM_BANK6                  equ %00110000
GA_RAM_BANK7                  equ %00111000

GA_RAM_CONFIG0                equ %00000000
GA_RAM_CONFIG1                equ %00000001
GA_RAM_CONFIG2                equ %00000010
GA_RAM_CONFIG3                equ %00000011
GA_RAM_CONFIG4                equ %00000100
GA_RAM_CONFIG5                equ %00000101
GA_RAM_CONFIG6                equ %00000110
GA_RAM_CONFIG7                equ %00000111

; **************************************
; Cathode Ray Tube Controller
; definition.
; **************************************
; Ports.
PORT_CRTC_SELECT_REG            equ &BC00
PORT_CRTC_WRITE_DATA            equ &BD00
PORT_CRTC_READ_STATUS           equ &BE00
PORT_CRTC_READ_REG              equ &BF00
CRTC_PORT_SELECT_REG            equ &BC00
CRTC_PORT_WRITE_DATA            equ &BD00
CRTC_PORT_READ_STATUS           equ &BE00
CRTC_PORT_READ_REG              equ &BF00

; Registers.
CRTC_HORIZONTAL_TOTAL           equ 0     ;(7-0)
CRTC_HORIZONTAL_DISPLAYED       equ 1     ;(7-0)
CRTC_HORIZONTAL_SYNC_POSITION   equ 2     ;(7-0)
CRTC_SYNC_WIDTH                 equ 3     ;vertical(7-4), horizontal(3-0)
CRTC_VERTICAL_TOTAL             equ 4     ;(6-0)
CRTC_VERTICAL_TOTAL_ADJUST      equ 5     ;(4-0)
CRTC_VERTICAL_DISPLAYED         equ 6     ;(6-0)
CRTC_VERTICAL_SYNC_POSITION     equ 7     ;(6-0)
CRTC_INTERLACE_SKEW             equ 8     ;C(7-6), D(5-4), V(1), S(0)
CRTC_MAXIMUM_RASTER_ADDRESS     equ 9     ;(4-0)
CRTC_CURSOR_START_RASTER        equ 10    ;B(6),P(5),(4-0)
CRTC_CURSOR_END_RASTER          equ 11
CRTC_START_ADDRESS_H            equ 12
CRTC_START_ADDRESS_L            equ 13
CRTC_CURSOR_H                   equ 14
CRTC_CURSOR_L                   equ 15
CRTC_LIGHT_PEN_H                equ 16
CRTC_LIGHT_PEN_L                equ 17

; **************************************
; Programmable Peripheral Interface
; definition.
; **************************************
; Ports.
PPI_PORTA                       equ &F400
PPI_PORTB                       equ &F500
PPI_PORTC                       equ &F600
PPI_PORT_CTRL                   equ &F700

PPI_MODE_SET_FLAG               equ %10000000
PPI_GROUP_A_MODE_SET_0          equ %00000000
PPI_GROUP_A_MODE_SET_1          equ %00100000
PPI_GROUP_A_MODE_SET_2          equ %01000000
PPI_PORTA_OUTPUT_SET            equ %00000000
PPI_PORTA_INPUT_SET             equ %00010000
PPI_PORTC_UPPER_OUTPUT_SET      equ %00000000
PPI_PORTC_UPPER_INPUT_SET       equ %00001000
PPI_GROUP_B_MODE_SET_0          equ %00000000
PPI_GROUP_B_MODE_SET_1          equ %00000100
PPI_PORTB_OUTPUT_SET            equ %00000000
PPI_PORTB_INPUT_SET             equ %00000010
PPI_PORTC_LOWER_OUTPUT_SET      equ %00000000
PPI_PORTC_LOWER_INPUT_SET       equ %00001000






; **************************************
; Programmable Sound Generator
; definition
; **************************************
PSG_VALIDATE                    equ %00000000
PSG_READ_DATA                   equ %01000000
PSG_WRITE_DATA                  equ %10000000
PSG_SELECT_REG                  equ %11000000

PSG_CHANNEL_A_TONE_GENERATOR_L  equ 0
PSG_CHANNEL_A_TONE_GENERATOR_H  equ 1
PSG_CHANNEL_B_TONE_GENERATOR_L  equ 2
PSG_CHANNEL_B_TONE_GENERATOR_H  equ 3
PSG_CHANNEL_C_TONE_GENERATOR_L  equ 4
PSG_CHANNEL_C_TONE_GENERATOR_H  equ 5
PSG_NOISE_GENERATOR             equ 6
PSG_MIXER                       equ 7
PSG_CHANNEL_A_AMPLITUDE         equ 8
PSG_CHANNEL_B_AMPLITUDE         equ 9
PSG_CHANNEL_C_AMPLITUDE         equ 10
PSG_ENVELOPE_PERIOD_L           equ 11
PSG_ENVELOPE_PERIOD_H           equ 12
PSG_ENVELOPE_SHAPE              equ 13
PSG_R14                         equ 14
PSG_R15                         equ 15

; **************************************
; Floppy Disk Controller
; definition.
; **************************************
; Ports.
FDC_PORT_STATUS                 equ &FB7E
FDC_PORT_DATA                   equ &FB7F

; Main Status Register bit definition.
FDC_MSR_D0B                     equ %00000001 ; FDD 0 Busy
FDC_MSR_D1B                     equ %00000010 ; FDD 1 Busy
FDC_MSR_D2B                     equ %00000100 ; FDD 2 Busy
FDC_MSR_D3B                     equ %00001000 ; FDD 3 Busy
FDC_MSR_CB                      equ %00010000 ; FDC Busy (1 = Busy, 0 = Not Busy)
FDC_MSR_EXM                     equ %00100000 ; Execution Mode
FDC_MSR_DIO                     equ %01000000 ; Data Input/Output (1 = controller has data for CPU, 0 = controller expecting data from CPU)
FDC_MSR_RQM                     equ %10000000 ; Request for Master ( 	1 = data register ready, 0 = data register not ready)

; Commands.
FDC_READ_A_TRACK                equ %00000010
FDC_SPECIFY                     equ %00000011
FDC_SENS_DRIVE_STATUS           equ %00000100
FDC_WRITE_DATA                  equ %00000101
FDC_READ_DATA                   equ %00000110
FDC_RECALIBRATE                 equ %00000111
FDC_SENSE_INTERRUPT_STATUS      equ %00001000
FDC_WRITE_DELETED_DATA          equ %00001001
FDC_READ_ID                     equ %00001010
FDC_READ_DELETED_DATA           equ %00001100
FDC_FORMAT_A_TRACK              equ %00001101
FDC_SEEK                        equ %00001111
FDC_SCAN_EQUAL                  equ %00010001
FDC_SCAN_LOW_OR_EQUAL           equ %00011001
FDC_SCAN_HIGH_OR_EQUAL          equ %00011101

; Commands bits.
FDC_CMD_MT                      equ %10000000 ; Multi-Track
FDC_CMD_MF                      equ %01000000 ; MFM Mode
FDC_CMD_SK                      equ %00100000 ; Skip
FDC_CMD_HD                      equ %00000100 ; Head
FDC_CMD_US1                     equ %00000010 ; Unit Select 1
FDC_CMD_US0                     equ %00000001 ; Unit Select 0

; **************************************
; Miscellaneous
; definition.
; **************************************
; Ports.
UPPER_ROM_PORT                  equ &DF00
PRINTER_PORT                    equ &EF00
PERIPHERAL_SOFT_RESET_PORT      equ &F8FF
FLOPPY_MOTOR_PORT               equ &FA7E
; **************************************
; ASIC
; definition.
; **************************************
ASIC_START_ADR                  equ &4000
ASIC_SPR_XSIZE                  equ &10
ASIC_SPR_YSIZE                  equ &10
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
ASIC_REG_DCSR                   equ &6C0F

ASIC_DMA_LOAD_R_D               equ &0000
ASIC_DMA_PAUSE_N                equ &1000
ASIC_DMA_REPEAT_N               equ &2000
ASIC_DMA_NOP_N                  equ &4000
ASIC_DMA_LOOP                   equ &4001
ASIC_DMA_INT                    equ &4010
ASIC_DMA_STOP                   equ &4020

ASIC_DMA_CHANNEL_0              equ %00000001
ASIC_DMA_CHANNEL_1              equ %00000010
ASIC_DMA_CHANNEL_2              equ %00000100

