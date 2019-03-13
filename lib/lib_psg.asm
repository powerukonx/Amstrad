; *****************************************************************************
; * PSG library
; * Code => POWER/UKONX
; *
; * Need lib_ppi
; *****************************************************************************

; *****************************************************************************
; Definition
; *****************************************************************************
; Functions
PSG_VALIDATE                    equ %00000000
PSG_READ_DATA                   equ %01000000
PSG_WRITE_DATA                  equ %10000000
PSG_SELECT_REG                  equ %11000000

; Registers
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
PSG_PORTA                       equ 14
PSG_PORTB                       equ 15

; Registers save-restore inside macros.
PSG_PRESERVE_OFF                equ 0
PSG_PRESERVE_ON                 equ PSG_PRESERVE_OFF + 1


; *****************************************************************************
; Read one PSG register
; Input
;  A = PSG register
; Output
;  A = Register value
; (All others registers and flags are preserved)
; *****************************************************************************
macro mPSGREAD_ONE preserve

; Save registers used.
if preserve = PSG_PRESERVE_ON
    push bc
    push hl
endif

; Initialize PPI ports directions.
    ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_OUTPUT_SET + PPI_PORTB_INPUT_SET
    out (c),c

; Set PSG registers.
    ld b,PPI_PORTA/256
    out (c),a

; Select register.
    ld bc,PPI_PORTC + PSG_SELECT_REG
    out (c),c

; Validate.
    xor a
    out (c),a

; Set PPI port A in input.
    ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_INPUT_SET + PPI_PORTB_INPUT_SET
    out (c),c

; PSG in write mode (read mode in PPI point of view).
    ld bc,PPI_PORTC + PSG_READ_DATA
    out (c),c

; Read value from PSG.
    ld b,PPI_PORTA/256
    in a,(c)

; Set PPI port A in output.
 ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_OUTPUT_SET + PPI_PORTB_INPUT_SET
    out (c),c

; Validate.
    ld bc,PPI_PORTC + PSG_VALIDATE
    out (c),c

; Restore registers used
if preserve = PSG_PRESERVE_ON
    pop hl
    pop bc
endif

mend


