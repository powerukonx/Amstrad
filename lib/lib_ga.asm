; *****************************************************************************
; * GATE ARRAY library
; * Code => POWER/UKONX
; *****************************************************************************

; Main port.
GA_PORT                       equ &7F00

; Registers definition.
GA_PENR                       equ %00000000
GA_INKR                       equ %01000000
GA_RMR                        equ %10000000

; Register PENR bit definition.
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

; Register INKR bit definition.
GA_INKR_WHITE                 equ %00000000
GA_INKR_WHITE_2               equ %00000001
GA_INKR_SEA_GREEN             equ %00000010
GA_INKR_PASTEL_YELLOW         equ %00000011
GA_INKR_BLUE                  equ %00000100
GA_INKR_PURPLE                equ %00000101
GA_INKR_CYAN                  equ %00000110
GA_INKR_PINK                  equ %00000111
GA_INKR_PURPLE_2              equ %00001000
GA_INKR_PASTEL_YELLOW_2       equ %00001001
GA_INKR_BRIGHT_YELLOW         equ %00001010
GA_INKR_BRIGHT_WHITE          equ %00001011
GA_INKR_BRIGHT_RED            equ %00001100
GA_INKR_BRIGHT_MAGENTA        equ %00001101
GA_INKR_ORANGE                equ %00001110
GA_INKR_PASTEL_MAGENTA        equ %00001111
GA_INKR_BLUE_2                equ %00010000
GA_INKR_SEA_GREEN_2           equ %00010001
GA_INKR_BRIGHT_GREEN          equ %00010010
GA_INKR_BRIGHT_CYAN           equ %00010011
GA_INKR_BLACK                 equ %00010100
GA_INKR_BRIGHT_BLUE           equ %00010101
GA_INKR_GREEN                 equ %00010110
GA_INKR_SKY_BLUE              equ %00010111
GA_INKR_MAGENTA               equ %00011000
GA_INKR_PASTEL_GREEN          equ %00011001
GA_INKR_LIME                  equ %00011010
GA_INKR_PASTEL_CYAN           equ %00011011
GA_INKR_RED                   equ %00011100
GA_INKR_MAUVE                 equ %00011101
GA_INKR_YELLOW                equ %00011110
GA_INKR_PASTEL_BLUE           equ %00011111

; RMR bit definition.
GA_RMR_RMR2_ON                equ %00100000
GA_RMR_RMR2_OFF               equ %00000000
GA_RMR_INT_RESET              equ %00010000
GA_RMR_UPPER_ROM_DISABLE      equ %00001000
GA_RMR_UPPER_ROM_ENABLE       equ %00000000
GA_RMR_LOWER_ROM_DISABLE      equ %00000100
GA_RMR_LOWER_ROM_ENABLE       equ %00000000
GA_RMR_MODE_0                 equ %00000000
GA_RMR_MODE_1                 equ GA_RMR_MODE_0 + 1
GA_RMR_MODE_2                 equ GA_RMR_MODE_1 + 1
GA_RMR_MODE_3                 equ GA_RMR_MODE_2 + 1

; RMR2 definition.
GA_RMR2_ASIC_ON               equ GA_RMR_RMR2_ON + %00011000
GA_RMR2_ASIC_OFF              equ GA_RMR_RMR2_ON + %00000000


; *****************************************************************************
; Set screen resolution.
;   mode = 0,1,2 or 3
;
; BC is modified.
; *****************************************************************************
macro mGA_MODE_SET mode
  ld bc,GA_PORT + GA_RMR + GA_RMR_UPPER_ROM_DISABLE + GA_RMR_LOWER_ROM_DISABLE + mode
  out (c),c
mend


; *****************************************************************************
; Set all pens to black ink.
;
; AF,BC are modified.
; *****************************************************************************
macro mGA_PENS_INK_BLACK
    ld bc,GA_PORT + GA_PENR + GA_PENR_BORDER
    ld a,GA_INKR + GA_INKR_BLACK
    out (c),c
    out (c),a
    dec c
    jr nz,$-7
    out (c),c
    out (c),a
mend

; *****************************************************************************
; Set pen ink.
;   pen = 0 to 15
;   ink = hardware color (INKR)
;
; AF,BC are modified.
; *****************************************************************************
macro mGA_PEN_INK pen,ink
    ld bc,GA_PORT + GA_PENR + pen
    ld a,GA_INKR + ink
    out (c),c
    out (c),a
mend

; *****************************************************************************
; Set border ink.
;   ink = hardware color (INKR)
;
; AF,BC are modified.
; *****************************************************************************
macro mGA_BORDER_INK ink
    ld bc,GA_PORT + GA_PENR + GA_PENR_BORDER
    ld a,GA_INKR + ink
    out (c),c
    out (c),a
mend


