;-------------------------------------------------------------------------------
;   Killing Sound v0.5 by POWER from KOD
;   (Reverse engineering)
;-------------------------------------------------------------------------------
    run entryPoint
    nolist

;-------------------------------------------------------------------------------
MC_START_PROGRAM  equ &bd16
KL_ROM_WALK       equ &bccb
SCR_SET_INK       equ &bc32
SCR_SET_MODE      equ &bc0e 
SCR_SET_BORDER    equ &bc38
KM_WAIT_CHAR      equ &bb06
CAS_IN_OPEN       equ &bc77 
CAS_IN_DIRECT     equ &bc83 
CAS_IN_CLOSE      equ &bc7a
CAS_IN_ABANDON    equ &bc7d
TXT_SET_CURSOR    equ &bb75
TXT_OUTPUT        equ &bb5a
CAS_OUT_OPEN      equ &bc8c
CAS_OUT_ABANDON   equ &bc92
CAS_OUT_DIRECT    equ &bc98
CAS_OUT_CLOSE     equ &bc8f
CAS_CATALOG       equ &bc9b
TEXT_INPUT        equ &bd5e

;-------------------------------------------------------------------------------
    org #4000

.entryPoint

; Runs a foreground program
; warning C not initialized 
    ld hl,l4006 ; entry point for the program
    jp MC_START_PROGRAM

;-------------------------------------------------------------------------------
.l4006

; Finds and initialises all background ROMs
    ld hl,#abff ; address of the last usable byte of memory
    ld de,#0040 ; address of first usable byte of memory
    call KL_ROM_WALK

; INK 0,1,1
    xor a
    ld bc,#0101
    call SCR_SET_INK

; BORDER 1
    ld bc,#0101
    call SCR_SET_BORDER

.l401c

; INK 1,1,1
    ld a,#01
    ld bc,#0101
    call SCR_SET_INK

; MODE 2
    ld a,#02
    call SCR_SET_MODE

; Display menu
    ld hl,l4490
    call dispText

; INK 1,23,23
    ld a,#01
    ld bc,#1717
    call SCR_SET_INK

.l4037

;Waits for the next character from the keyboard buffer
    call KM_WAIT_CHAR
    cp "1"
    jp z,l4062  ; Open and load WAV file

    cp "2"
    jp z,l4138  ; Save 4 bits mono sample

    cp "3"
    jp z,l41c9  ; Play 4 bits mono sample

    cp "4"
    jp nz,l4037 ; Loop

; MODE 2
    ld a,#02
    call SCR_SET_MODE

; INK 1,24,24
    ld a,#01
    ld bc,#1818
    call SCR_SET_INK

; Display "A bientot !"
    ld hl,l4597
    call dispText

; Quit
    ret

;-------------------------------------------------------------------------------
.l4062  ; Open and load WAV file

; No sample in memory
    xor a
    ld (l45a7),a

    call l42ca

; Opens an input buffer and reads the first block of the file
    ld hl,#4f00 ; filename's address.
    ld de,#5000 ; 2K buffer to use for reading the file
    call CAS_IN_OPEN

    ld (l40bd + 1),bc ; Save file length
    jp c,l4082        ; Opened succefully

; Abandons an input file.
    call CAS_IN_ABANDON

; Display "Erreur d'ouverture du fichier -SPACE- ", wait a key and return to menu
    ld hl,l437f
    jp l411d

;-------------------------------------------------------------------------------
.l4082

; Reads an entire file directly into memory.
    ld hl,#5000 ; address where the file is to be placed in RAM
    call CAS_IN_DIRECT
    jp c,l4094  ; operation was successful

; Abandons an input file.
    call CAS_IN_ABANDON

; Diplay "Erreur de lecture du fichier -SPACE-  ", wait a key and return to menu
    ld hl,l43a6
    jp l411d

;-------------------------------------------------------------------------------
.l4094

; Closes an input file. 
    call CAS_IN_CLOSE
    jp c,l40a3 ; closed successfully,

; Abandons an input file.
    call CAS_IN_ABANDON

; Display "Erreur de fermeture du fichier -SPACE-", wait a key and return to menu
    ld hl,l43cd
    jp l411d

;-------------------------------------------------------------------------------
.l40a3

; Search "RIFF" chunk
    ld hl,#5000
    ld de,l45ac
    ld b,#04
.l40ab
    ld a,(de)
    cp (hl)
    jp z,l40b6

; Display "        Fichier non WAV -SPACE-       ", wait a key and return to menu
    ld hl,l4358
    jp l411d

.l40b6

    inc hl
    inc de
    djnz l40ab

; Search "data" sub-chunk
    ld de,l45b0
.l40bd
    ld bc,#0000 ; File length

    xor a
    ld (l40cb + 1),a

.l40c4
    ld a,(de)
    cp (hl)
    jp nz,l40d9

    inc hl
    inc de
.l40cb
    ld a,#00
    inc a
    ld (l40cb + 1),a
    cp #04
    jp z,l40ed

    jp l40e1

;-------------------------------------------------------------------------------
.l40d9

    inc hl

    xor a
    ld (l40cb + 1),a

    ld de,l45b0
.l40e1
    dec bc
    ld a,b
    or c
    jp nz,l40c4

; Display "        Fichier non WAV -SPACE-       ", wait a key and return to menu
    ld hl,l4358
    jp l411d

;-------------------------------------------------------------------------------
.l40ed  ; WAV file found

; Save chunk size (only 16 bits)
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl
    inc hl
    inc hl
    ld (l45a3),bc

; Save samples begin address
    ld (l45a5),hl

    ld iy,#500c ; "fmt" sub-chunk

; TODO Save nb of channel ?
    ld a,(iy+#0a)
    ld (l45ab),a

; TODO Save samplerate ?
    ld a,(iy+#0c)
    ld l,a
    ld a,(iy+#0d)
    ld h,a
    ld (l45a8),hl
; TODO 
    ld a,(iy+#16)
    ld (l45aa),a

; Sample in memory 
    ld a,#01
    ld (l45a7),a

; Display "      Fichier WAV trouv{ -SPACE-      ", wait a key and return to menu
    ld hl,l4331
.l411d

; LOCATE 21,25
    push hl
    ld h,#15
    ld l,#19
    call TXT_SET_CURSOR
    pop hl

.l4126
    ld a,(hl)
    or a
    jp z,l4132

    call TXT_OUTPUT
    inc hl
    jp l4126

;-------------------------------------------------------------------------------
.l4132

; Waits for the next character from the keyboard buffer
    call KM_WAIT_CHAR

; Return to menu
    jp l401c

;-------------------------------------------------------------------------------
.l4138 ; Save 4 bits mono sample

    ld a,(l45a7)
    or a
    jp nz,l415f ; Sample in memory

; LOCATE 21,25
    ld h,#15
    ld l,#19
    call TXT_SET_CURSOR

; Display "    Aucun sample en m{moire -SPACE-   "
    ld hl,l4442
    call dispText

    call KM_WAIT_CHAR

; LOCATE 21,25
    ld h,#15
    ld l,#19
    call TXT_SET_CURSOR

; Display "                                      "
    ld hl,l4469
    call dispText

; Return to menu
    jp l4037

;-------------------------------------------------------------------------------
.l415f

    call l42ca

    push bc
    ld bc,(l45a3) ; Sample size
    ld de,#5000   ; Destination address
    ld hl,(l45a5) ; Samples begin address
.l416d

; 4 bits linear conversion
    ld a,(hl)
    srl a
    srl a
    srl a
    srl a
    ld (de),a
    inc hl
    inc de
    dec bc
    ld a,b
    or c
    jp nz,l416d


; Opens an output file
    pop bc      ; length of the filename.
    ld hl,#4f00 ; address of the filename.
    ld de,#5000 ; address of the 2K buffer to be used.
    call CAS_OUT_OPEN
    jp c,l4195  ; file was opened correctly

; Abandons an output file. 
    call CAS_OUT_ABANDON

; Display "Erreur d'ouverture du fichier -SPACE- ", wait a key and return to menu
    ld hl,l437f
    jp l411d

;-------------------------------------------------------------------------------
.l4195

; Writes an entire file directly
    ld hl,#5000   ; address of the data which is to be written
    ld bc,#0000   ; execution address.
    ld de,(l45a3) ; length of this data.
    ld a,#02      ; file type.
    call CAS_OUT_DIRECT
    jp c,l41b0    ; operation was successful

; Abandons an output file. 
    call CAS_OUT_ABANDON

; Display "Erreur d'ecriture du fichier -SPACE-  ", wait a key and return to menu
    ld hl,l43f4
    jp l411d

;-------------------------------------------------------------------------------
.l41b0

; Closes an output file.
    call CAS_OUT_CLOSE
    jp c,l41bf  ; closed successfully

; Abandons an output file. 
    call CAS_OUT_ABANDON

; Display "Erreur de fermeture du fichier -SPACE-", wait a key and return to menu
    ld hl,l43cd
    jp l411d

;-------------------------------------------------------------------------------
.l41bf

    ld hl,l441b

; No sample in memory
    xor a
    ld (l45a7),a

    jp l411d

;-------------------------------------------------------------------------------
.l41c9 ; Play 4 bits mono sample

    ld a,(l45a7)
    or a
    jp nz,l41f0 ; Sample in memory

; LOCATE 21,25
    ld h,#15
    ld l,#19
    call TXT_SET_CURSOR

; Display "    Aucun sample en m{moire -SPACE-   "
    ld hl,l4442
    call dispText

    call KM_WAIT_CHAR

; LOCATE 21,25
    ld h,#15
    ld l,#19
    call TXT_SET_CURSOR

; Display "                                      "
    ld hl,l4469
    call dispText

; Return to menu
    jp l4037

;-------------------------------------------------------------------------------
.l41f0

; LOCATE 1,15
    ld h,#01
    ld l,#0f
    call TXT_SET_CURSOR

; Display "Lecture du sample en cours ..."
    ld hl,l4537
    call dispText

; Save and remove system interrupt manager
    di
    ld hl,(#0038)
    ld (l42b3 + 1),hl
    ld hl,#c9fb
    ld (#0038),hl
    ei

    ld b,#00
    ld hl,(l45a3)
    ld de,#00dc
.l4213
    xor a
    sbc hl,de
    jp c,l421d

    inc b
    jp l4213

;-------------------------------------------------------------------------------
.l421d

    ld a,b
    ld (l4256 + 1),a

    ld hl,(l45a5) ; Samples begin address
    ld (l4251 + 1),hl

; Play sample
.l4227
    ld b,#f5
.l4229
    in a,(c)
    rra
    jp nc,l4229

    ld a,#07
    call l430c
    or #12
    ld bc,#f407
    out (c),c
    ld bc,#f6c0
    out (c),c
    ld bc,#f600
    out (c),c
    ld b,#f4
    out (c),a
    ld bc,#f680
    out (c),c
    xor a
    out (c),a

.l4251
    ld hl,#0000

    ld d,#dc
.l4256
    ld e,#00

    ld bc,#f409
    out (c),c
    ld bc,#f6c0
    out (c),c
    xor a
    out (c),a
.l4265
    ld b,#f4
    ld a,(hl)

; 4 bits linear conversion
    srl a
    srl a
    srl a
    srl a
    out (c),a
    inc hl
    ld bc,#f680
    out (c),c
    xor a
    out (c),a

    ds 37,0

    dec d
    jp nz,l4265

    dec e
    jp z,l42b2

    ld (l4251 + 1),hl

    ld a,e
    ld (l4256 + 1),a

    jp l4227

;-------------------------------------------------------------------------------
.l42b2

; Restore system interrupt manager
    di
.l42b3
    ld hl,#0000
    ld (#0038),hl
    ei

; LOCATE 1,15
    ld h,#01
    ld l,#0f
    call TXT_SET_CURSOR

; Display "                              "
    ld hl,l4556
    call dispText

; Return to menu
    jp l4037

;-------------------------------------------------------------------------------
.l42ca

; Clear filename
    ld hl,#4f00
    xor a
    ld (hl),a
    ld de,#4f01
    ld bc,#00fe
    ldir

; MODE 2
    ld a,#02
    call SCR_SET_MODE

; Creates a catalogue of all the files
    ld de,#5000 ; address of the 2K buffer to be used to store the information.
    call CAS_CATALOG

; LOCATE 1,20
    ld h,#01
    ld l,#14
    call TXT_SET_CURSOR

; Display "Nom du fichier (avec extension) "
    ld hl,l4575
    call dispText

; Allows upto 255 characters to be input from the keyboard into a buffer. 
    ld hl,#4f00 ; start of the buffer.
    call TEXT_INPUT

    ld b,#00
    ld hl,#4f00
.l42fa
    ld a,(hl)
    or a
    ret z

    inc b
    inc hl

    jp l42fa

;-------------------------------------------------------------------------------
.dispText

    ld a,(hl)
    or a
    ret z

    call TXT_OUTPUT

    inc hl
    jp dispText

;-------------------------------------------------------------------------------
.l430c

    ld b,#f4
    out (c),a
    ld bc,#f6c0
    out (c),c
    xor a
    out (c),a
    ld bc,#f792
    out (c),c
    ld bc,#f640
    out (c),c
    ld b,#f4
    in a,(c)
    ld bc,#f782
    out (c),c
    ld bc,#f600
    out (c),c

    ret

;-------------------------------------------------------------------------------
.l4331
    db "      Fichier WAV trouv{ -SPACE-      ",#00

;-------------------------------------------------------------------------------
.l4358
    db "        Fichier non WAV -SPACE-       ",#00

;-------------------------------------------------------------------------------
.l437f
    db "Erreur d'ouverture du fichier -SPACE- ",#00
;-------------------------------------------------------------------------------
.l43a6
    db "Erreur de lecture du fichier -SPACE-  ",#00
;-------------------------------------------------------------------------------
.l43cd
    db "Erreur de fermeture du fichier -SPACE-",#00
;-------------------------------------------------------------------------------
.l43f4
    db "Erreur d'ecriture du fichier -SPACE-  ",#00
;-------------------------------------------------------------------------------
.l441b
    db "      Fichier enregistr{ -SPACE-      ",#00
;-------------------------------------------------------------------------------
.l4442
    db "    Aucun sample en m{moire -SPACE-   ",#00
;-------------------------------------------------------------------------------
.l4469
    db "                                      ",#00
;-------------------------------------------------------------------------------
.l4490
    db "Killing Sound v0.5 by POWER from KOD",#0d,#0a,#0a,#0a,#0a,#0a
    db "1. Chargement d'un fichier WAV",#0d,#0a
    db "2. Sauvegarde du sample en 4 bits mono",#0d,#0a
    db "3. Lecture du sample en 4bits mono (PSG)",#0d,#0a
    db "4. Quitter",#00
;-------------------------------------------------------------------------------
.l4537
    db "Lecture du sample en cours ...",#00
;-------------------------------------------------------------------------------
.l4556
    db "                              ",#00
;-------------------------------------------------------------------------------
.l4575
    db "Nom du fichier (avec extension) :",#00
;-------------------------------------------------------------------------------
.l4597
    db "A bientot !",#00
;-------------------------------------------------------------------------------
.l45a3  ; chunk (sample) size
    dw #0000
;-------------------------------------------------------------------------------
.l45a5  ; Samples begin address
    dw #0000
;-------------------------------------------------------------------------------
.l45a7  ; 1=Sample in memory else 0
    db #00
;-------------------------------------------------------------------------------
.l45a8
    db #00,#00
;-------------------------------------------------------------------------------
.l45aa
    db #00
;-------------------------------------------------------------------------------
.l45ab
    db #00
;-------------------------------------------------------------------------------
.l45ac
    db "RIFF"
;-------------------------------------------------------------------------------
.l45b0
    db "data"

