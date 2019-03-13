; *****************************************************************************
; * ROM library
; * Code => POWER/UKONX
; *****************************************************************************

; Ports.
UPPER_ROM_PORT                  equ &DF00

; *****************************************************************************
; Select upper ROM number.
; 
; Common ROM Bank Numbers (cpcwiki.eu)
; 00h       BASIC (or AMSDOS, depending on LK1 on the DDI-1 board)
; 07h       AMSDOS (or BASIC, depending on LK1 on the DDI-1 board)
; 00h..07h  Bootable ROMs on CPC 464/664/6128 (KL_ROM_WALK)
; 08h..0Fh  Bootable ROMs on CPC 664/6128 (KL_ROM_WALK)
; 10h..FFh  Non-bootable ROMs (or secondary banks of Bootable ROMs)
; FCh..FFh  Can be used, but aren't accessible by BIOS functions
; FFh       BASIC (or ROM with similar ID; for the crude 128K RAM-size detection in CP/M+)
; FFh       BASIC (or ROM with similar ID; for the BIOS key scan detection in AMSDOS+)
;
; Input
;  number = ROM number
; Output
;  None
; BC is modified
; *****************************************************************************
macro mROM_SELECT number save 
  ld bc,UPPER_ROM_PORT + number
  out c,(c)
mend