; *****************************************************************************
; * PRINTER library
; * Code => POWER/UKONX
; *
; * Need lib_ppi
; *****************************************************************************
PRINTER_PORT                    equ &EF00
PRINTER_DATA_MASK               equ &7F
PRINTER_STROBE_MASK             equ &80

; *****************************************************************************
; Read printer busy flag
; Input
;  None
; Output
;  A = busy flag state (also carry flag)
; AF and BC are modified
; *****************************************************************************
macro mPRINTER_GET_BUSY_FLAG
  ld b,PPI_PORTB/256
  in a,(c)
  rlca
  rlca
mend