; *****************************************************************************
; * CRTC library
; * Code => POWER/UKONX
; *****************************************************************************

; Ports.
CRTC_PORT_SELECT_REG            equ &BC00 ; Select 6845 register
CRTC_PORT_WRITE_DATA            equ &BD00 ; Write 6845 register data
CRTC_PORT_READ_STATUS           equ &BE00 ; The function of these I/O ports is dependant on the CRTC type 
CRTC_PORT_READ_REG              equ &BF00 ; The function of these I/O ports is dependant on the CRTC type 

; Registers.
CRTC_HORIZONTAL_TOTAL           equ 0     ; Width of the screen, in characters. Should always be 63 (64 characters). 1 character == 1μs. 
CRTC_HORIZONTAL_DISPLAYED       equ 1     ; Number of characters displayed. Once horizontal character count (HCC) matches this value, DISPTMG is set to 1.
CRTC_HORIZONTAL_SYNC_POSITION   equ 2     ; When to start the HSync signal. 
CRTC_SYNC_WIDTH                 equ 3     ; HSync pulse width in characters (0 means 16 on some CRTC), should always be more than 8; VSync width in scan-lines. (0 means 16 on some CRTC. Not present on all CRTCs, fixed to 16 lines on these) 
CRTC_VERTICAL_TOTAL             equ 4     ; Height of the screen, in characters. 
CRTC_VERTICAL_TOTAL_ADJUST      equ 5     ; Measured in scanlines, can be used for smooth vertical scrolling on CPC. 
CRTC_VERTICAL_DISPLAYED         equ 6     ; Height of displayed screen in characters. Once vertical character count (VCC) matches this value, DISPTMG is set to 1.
CRTC_VERTICAL_SYNC_POSITION     equ 7     ; When to start the VSync signal, in characters. 
CRTC_INTERLACE_SKEW             equ 8     ; 00= No interlace; 01= Interlace Sync Raster Scan Mode; 10= No Interlace; 11= Interlace Sync and Video Raster Scan Mode 
CRTC_MAXIMUM_RASTER_ADDRESS     equ 9     ; Maximum scan line address on CPC can hold between 0 and 7, higher values' upper bits are ignored 
CRTC_CURSOR_START_RASTER        equ 10    ; Cursor not used on CPC. B = Blink On/Off; P = Blink Period Control (Slow/Fast). Sets first raster row of character that cursor is on to invert.
CRTC_CURSOR_END_RASTER          equ 11    ; Sets last raster row of character that cursor is on to invert 
CRTC_START_ADDRESS_H            equ 12    ; 
CRTC_START_ADDRESS_L            equ 13    ; Allows you to offset the start of screen memory for hardware scrolling, and if using memory from address &0000 with the firmware. 
CRTC_CURSOR_H                   equ 14    ; 
CRTC_CURSOR_L                   equ 15    ; 
CRTC_LIGHT_PEN_H                equ 16    ; Read Only 
CRTC_LIGHT_PEN_L                equ 17    ; Read Only 


; *****************************************************************************
; Reprogramming CRTC
;
; *****************************************************************************
macro mCRTC_REPROG
    ld b,CRTC_PORT_SELECT_REG/256
    ld a,CRTC_START_ADDRESS_L + 1
    dec a    
    ld c,(hl):out (c),c:inc b:inc hl
    ld c,(hl):out (c),c:dec b:inc hl
    or a
    jr nz,$-12
mend


; *****************************************************************************
; Specific Hate Beats screen resolution.
;
; *****************************************************************************
macro mCRTC_CUSTOM_HATEBEATS
  ld bc,CRTC_PORT_SELECT_REG + CRTC_HORIZONTAL_DISPLAYED
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


