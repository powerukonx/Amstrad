; *****************************************************************************
; * PPI library
; * Code => POWER/UKONX
; *****************************************************************************

; Ports.
PPI_PORTA                       equ &F400 ; PSG (Sound/Keyboard/Joystick) 
PPI_PORTB                       equ &F500 ; Vsync/Jumpers/PrinterBusy/CasIn/Exp 
PPI_PORTC                       equ &F600 ; KeybRow/CasOut/PSG
PPI_PORT_CTRL                   equ &F700 ; Control

; Control port bit definition
PPI_MODE_SET_FLAG               equ %10000000
PPI_GROUP_A_MODE_SET_2          equ %01000000
PPI_GROUP_A_MODE_SET_1          equ %00100000
PPI_PORTA_INPUT_SET             equ %00010000
PPI_PORTC_UPPER_INPUT_SET       equ %00001000
PPI_GROUP_B_MODE_SET_1          equ %00000100
PPI_PORTB_INPUT_SET             equ %00000010

PPI_GROUP_A_MODE_SET_0          equ %00000000
PPI_PORTA_OUTPUT_SET            equ %00000000
PPI_PORTC_UPPER_OUTPUT_SET      equ %00000000
PPI_GROUP_B_MODE_SET_0          equ %00000000
PPI_PORTB_OUTPUT_SET            equ %00000000
PPI_PORTC_LOWER_OUTPUT_SET      equ %00000000
PPI_PORTC_LOWER_INPUT_SET       equ %00001000

; Port B bit definition
PPI_PORTB_VSYNC                 equ %00000000 ; Vertical Sync ("1"=VSYNC active, "0"=VSYNC inactive)
PPI_PORTB_LK1                   equ %00000010 ; 3 bit Distributor ID. Usually set to 4=Awa,
PPI_PORTB_LK2                   equ %00000100 ; 5=Schneider, or 7=Amstrad,
PPI_PORTB_LK3                   equ %00001000 ; see LK-selectable Brand Names for details.
PPI_PORTB_LK4                   equ %00010000 ; Screen Refresh Rate ("1"=50Hz, "0"=60Hz)
PPI_PORTB_NEXP                  equ %00100000 ; Expansion Port /EXP pin
PPI_PORTB_PRN_BUSY              equ %01000000 ; Parallel/Printer port ready signal, "1" = not ready, "0" = Ready
PPI_PORTB_CAS_IN                equ %10000000 ; Cassette data input

; Port C bit definition
PPI_PORTC_PSG_BDIR              equ %10000000 ; PSG function selection
PPI_PORTC_PSG_BC1               equ %01000000 ; PSG function selection
PPI_PORTC_CAS_OUT               equ %00100000 ; Cassette Out (sometimes also used as Printer Bit7, see 8bit Printer Ports) 
PPI_PORTC_CAS_MOTOR_CTRL        equ %00010000 ; set bit to "1" for motor on, or "0" for motor off 
PPI_PORTC_KBD_LINE15            equ %00001111
PPI_PORTC_KBD_LINE14            equ %00001110
PPI_PORTC_KBD_LINE13            equ %00001101
PPI_PORTC_KBD_LINE12            equ %00001100
PPI_PORTC_KBD_LINE11            equ %00001011
PPI_PORTC_KBD_LINE10            equ %00001010
PPI_PORTC_KBD_LINE9             equ %00001001
PPI_PORTC_KBD_LINE8             equ %00001000
PPI_PORTC_KBD_LINE7             equ %00000111
PPI_PORTC_KBD_LINE6             equ %00000110
PPI_PORTC_KBD_LINE5             equ %00000101
PPI_PORTC_KBD_LINE4             equ %00000100
PPI_PORTC_KBD_LINE3             equ %00000011
PPI_PORTC_KBD_LINE2             equ %00000010
PPI_PORTC_KBD_LINE1             equ %00000001
PPI_PORTC_KBD_LINE0             equ %00000000

; *****************************************************************************
; Screen synchronization.
; *****************************************************************************
macro mPPI_SCREEN_SYNCHRONISE
  ld b,PPI_PORTB/256
  in a,(c)
  rra
  jr nc,$-3
  in a,(c)
  rra
  jr c,$-3
mend

; *****************************************************************************
; Set port A direction.
;  dir = direction (PPI_PORTA_DIR_INPUT or PPI_PORTA_DIR_OUTPUT)
;
; BC is modified
; *****************************************************************************
PPI_PORTA_DIR_INPUT   equ 1
PPI_PORTA_DIR_OUTPUT  equ 0
macro mPPI_PORTA_DIR dir
if dir=PPI_PORTA_DIR_INPUT
  ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_INPUT_SET + PPI_PORTB_INPUT_SET
else
  ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_OUTPUT_SET + PPI_PORTB_INPUT_SET
endif
  out (c),c
mend



