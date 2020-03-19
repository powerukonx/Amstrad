; *****************************************************************************
; * KEYBOARD library
; * Code => POWER/UKONX
; *****************************************************************************

; --------------------------------------------------------------------------------------------------------------------------------------------------
; Bit  |
; Line |    7     |             6             |        5      |       4       |        3        |         2       |         1       |       0
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &40  |    F.    |           ENTER           |        F3     |      F6       |        F9       |       CURDOWN   |     CURRIGHT    |     CURUP
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &41  |    F0    |             F2            |        F1     |      F5       |        F8       |         F7      |       COPY      |   CURLEFT
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &42  |  CONTROL |         BACKSLASH         |       SHIFT   |      F4       |   CLOSEHOOK     |       RETURN    |     OPENHOOK    |     CLR
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &43  |    DOT   |           SLASH           |       COLON   |   SEMICOLON   |        P        |         AT      |       DASH      |   POWER
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &44  |  COMMA   |             M             |        K      |       L       |        I        |         O       |         9       |     0
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &45  |  SPACE   |             N             |        J      |       H       |        Y        |         U       |         7       |     8
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &46  |    V     |             B             |        F      | G (Joy2 fire) |  T (Joy2 right) |  R (Joy2 left)  |  5 (Joy2 down)  | 6 (Joy 2 up)  
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &47  |    X     |             C             |        D      |       S       |        W        |         E       |         3       |     4
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &48  |    Z     |         CAPSLOCK          |        A      |      TAB      |        Q        |       ESC       |         2       |     1
; --------------------------------------------------------------------------------------------------------------------------------------------------
; &49  |  DEL     |  Joy 1 Fire 3 (CPC only)  |  Joy 1 Fire 2 |  Joy1 Fire 1  |    Joy1 right   | Joy1 left       |  Joy1 down      |  Joy1 u
; --------------------------------------------------------------------------------------------------------------------------------------------------

; Key line definition
KEYLINE_FDOT_TO_CURRUP      equ &40
KEYLINE_F0_TO_CURLEFT       equ KEYLINE_FDOT_TO_CURRUP + 1
KEYLINE_CONTROL_TO_CLR      equ KEYLINE_F0_TO_CURLEFT + 1
KEYLINE_POINT_TO_CIRCUMLEX  equ KEYLINE_CONTROL_TO_CLR + 1
KEYLINE_COMMA_TO_0          equ KEYLINE_POINT_TO_CIRCUMLEX + 1
KEYLINE_SPACE_TO_8          equ KEYLINE_COMMA_TO_0 + 1
KEYLINE_V_TO_6              equ KEYLINE_SPACE_TO_8  + 1
KEYLINE_X_TO_4              equ KEYLINE_V_TO_6 + 1
KEYLINE_Z_TO_1              equ KEYLINE_X_TO_4 + 1
KEYLINE_DEL_TO_UP           equ KEYLINE_Z_TO_1 + 1


; Key bit definition
KEYBIT_FDOT                 equ 7
KEYBIT_ENTER                equ 6
KEYBIT_F3                   equ 5
KEYBIT_F6                   equ 4
KEYBIT_F9                   equ 3
KEYBIT_CURDOWN              equ 2
KEYBIT_CURRIGHT             equ 1
KEYBIT_CURRUP               equ 0

KEYBIT_F0                   equ 7
KEYBIT_F2                   equ 6
KEYBIT_F1                   equ 5
KEYBIT_F5                   equ 4
KEYBIT_F8                   equ 3
KEYBIT_F7                   equ 2
KEYBIT_COPY                 equ 1
KEYBIT_CURLEFT              equ 0

KEYBIT_CONTROL              equ 7
KEYBIT_BACKSLASH            equ 6
KEYBIT_SHIFT                equ 5
KEYBIT_F4                   equ 4
KEYBIT_CLOSE_HOOK           equ 3
KEYBIT_RETURN               equ 2
KEYBIT_OPEN_HOOK            equ 1
KEYBIT_CLR                  equ 0

KEYBIT_DOT                  equ 7
KEYBIT_SLASH                equ 6
KEYBIT_DOUBLE_DOTS          equ 5
KEYBIT_SEMICOLON            equ 4
KEYBIT_P                    equ 3
KEYBIT_AT                   equ 2
KEYBIT_DASH                 equ 1
KEYBIT_CIRCUMFLEX           equ 0

KEYBIT_COMMA                equ 7
KEYBIT_M                    equ 6
KEYBIT_K                    equ 5
KEYBIT_L                    equ 4
KEYBIT_I                    equ 3
KEYBIT_O                    equ 2
KEYBIT_9                    equ 1
KEYBIT_0                    equ 0

KEYBIT_SPACE                equ 7
KEYBIT_N                    equ 6
KEYBIT_J                    equ 5
KEYBIT_H                    equ 4
KEYBIT_Y                    equ 3
KEYBIT_U                    equ 2
KEYBIT_7                    equ 1
KEYBIT_8                    equ 0

KEYBIT_V                    equ 7
KEYBIT_B                    equ 6
KEYBIT_F                    equ 5
KEYBIT_G                    equ 4
KEYBIT_T                    equ 3
KEYBIT_R                    equ 2
KEYBIT_5                    equ 1
KEYBIT_6                    equ 0

KEYBIT_X                    equ 7
KEYBIT_C                    equ 6
KEYBIT_D                    equ 5
KEYBIT_S                    equ 4
KEYBIT_W                    equ 3
KEYBIT_E                    equ 2
KEYBIT_3                    equ 1
KEYBIT_4                    equ 0

KEYBIT_Z                    equ 7
KEYBIT_CAPSLOCK             equ 6
KEYBIT_A                    equ 5
KEYBIT_TAB                  equ 4
KEYBIT_Q                    equ 3
KEYBIT_ESC                  equ 2
KEYBIT_2                    equ 1
KEYBIT_1                    equ 0

KEYBIT_DEL                  equ 7
KEYBIT_FIRE3                equ 6
KEYBIT_FIRE2                equ 5
KEYBIT_FIRE1                equ 4
KEYBIT_RIGHT                equ 3
KEYBIT_LEFT                 equ 2
KEYBIT_DOWN                 equ 1
KEYBIT_UP                   equ 0

; *****************************************************************************
; Test one keys
; Input
;  A = Key line number
; Output
;  A = Line status (must be filtered with key bit)
; (All others registers and flags are preserved)
; *****************************************************************************
macro mTESTKEYS_ONE

; Save registers used
      push bc
      push hl

      ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_OUTPUT_SET + PPI_PORTB_INPUT_SET
      out (c),c
      ld bc, PPI_PORTA + PSG_PORTA
      out (c),c
      ld bc,PPI_PORTC + PSG_SELECT_REG
      out (c),c
      ld c,0
      out (c),c
      ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_INPUT_SET + PPI_PORTB_INPUT_SET
      out (c),c
      ld b,PPI_PORTC/256
      out (c),a
      ld b,PPI_PORTA/256
      in a,(c)
      ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_OUTPUT_SET + PPI_PORTB_INPUT_SET
      out (c),c
      ld bc,PPI_PORTC
      out (c),c

; Restore registers used
      pop hl
      pop bc

mend

; *****************************************************************************
; Test all keys (results save in TESTKEYS_RESULT)
; Input
;  HL = pointer to 10 bytes buffer
; Output
;  None
; All registers and flags are preserved
; *****************************************************************************
macro mTESTKEYS_ALL

; Save registers used
      push af
      push bc
      push de
      push hl

      ld bc,PPI_PORTA + PSG_PORTA                                                           ; 3
      ld e,b                                                                                ; 1
      out (c),c                                                                             ; 4
      ld bc,PPI_PORTC + PSG_SELECT_REG                                                      ; 3
      ld d,b                                                                                ; 1
      out (c),c                                                                             ; 4
      xor a                                                                                 ; 1
      out (c),a                                                                             ; 4
      ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_INPUT_SET + PPI_PORTB_INPUT_SET   ; 3
      out (c),c                                                                             ; 4

; Set first line and end line (+ 1) to scan
      ld a,&40                                                                              ; 2
      ld c,&4a                                                                              ; 2
                                                                                            ; (= 32)
TESTKEYS_LOOP
      ld b,d                                                                                ; 1
      out (c),a                                                                             ; 4
      ld b,e                                                                                ; 1
      ini                                                                                   ; 5
      inc a                                                                                 ; 1
      cp d                                                                                  ; 1
      jr nz, TESTKEYS_LOOP                                                                  ; 3/2
                                                                                            ; (= 9*16 + 15)
      ld bc,PPI_PORT_CTRL + PPI_MODE_SET_FLAG + PPI_PORTA_OUTPUT_SET + PPI_PORTB_INPUT_SET  ; 3
      out (c),c                                                                             ; 4
      ld bc,PPI_PORTC                                                                       ; 3
      out (c),c                                                                             ; 4
                                                                                            ; = 32 + 9*16 + 15 + 14 = 205
      pop hl
      pop de
      pop bc
      pop af
; Restore registers used
mend


; *****************************************************************************
; *****************************************************************************
macro mTESTKEYS line
      ld (Test_Line + 1),a
      ld bc,PPI_PORTA + PSG_PORTA
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
