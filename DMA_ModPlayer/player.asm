; *****************************************************************************
; *                          DMA MOD Player by UKONX                          *
; *                                                                           *
; * Code => Power                                                             *
; *                                                                           *
; *****************************************************************************
 nolist

; *****************************************************************************
; Include some libs.
; *****************************************************************************
  read "../lib/lib_ga.asm"
  read "../lib/lib_psg.asm"
  read "../lib/lib_asic.asm"
  read "../lib/lib_crtc.asm"
  read "../lib/lib_pal.asm"
  read "../lib/lib_ppi.asm"
  read "../lib/lib_misc.asm"

; *****************************************************************************
; Constant definition.
; *****************************************************************************
MOD_SAMPLEOFFSET            equ 200
MOD_SAMPLEINFOADDR          equ &4000
MOD_PATTERNNB               equ MOD_SAMPLEINFOADDR + 155
MOD_PATTERNLIST             equ MOD_PATTERNNB + 1
MOD_PATTERNDATA             equ MOD_PATTERNLIST + 256

MOD_DEFAULT_SPEED           equ 6

MOD_ENDLINEDETECT           equ &FF  ; Line compression detection byte
MOD_EFFECT_9xx              equ &09
MOD_EFFECT_Cxx              equ &0c
MOD_EFFECT_Exx              equ &0e
MOD_EFFECT_Fxx              equ &0f

MOD_LINE_PER_PATTERN        equ 64

MOD_FX_LSB_MASK             equ %00000111
MOD_FX_MSB_MASK             equ %00001000
MOD_INSTRUMENT_MASK         equ %00011111
MOD_NOTE_MASK               equ %01111111

MOD_FIRST_POSITION          equ 0

ASIC_DMA_NO_SOUND           equ #0007
ASIC_DMA_LOAD_8_7           equ PSG_CHANNEL_A_AMPLITUDE*256 + ASIC_DMA_NO_SOUND
ASIC_DMA_LOAD_9_7           equ PSG_CHANNEL_B_AMPLITUDE*256 + ASIC_DMA_NO_SOUND
ASIC_DMA_LOAD_10_7          equ PSG_CHANNEL_C_AMPLITUDE*256 + ASIC_DMA_NO_SOUND

; *****************************************************************************
; Entrypoint
; *****************************************************************************
.Entry_Point

; Disable interrupt.
  di

  mASIC_UNLOCK 0
  
; Initialize first pattern to play 
  mPAL_RAM_SELECT PAL_MMR_BANK0, PAL_MMR_CONFIG4
  ld a,MOD_FIRST_POSITION
  ld (Mod_SongIndex),a
  add a,a
  ld e,a
  ld d,0
  ld hl,MOD_PATTERNLIST
  add hl,de
  ld e,(hl)
  inc hl
  ld d,(hl)
  ex de,hl
  ld (Mod_PatternLineAddress),hl
  mPAL_RAM_SELECT PAL_MMR_BANK0, PAL_MMR_CONFIG0

; Effect to execute.
.Player_loop
 
  mPPI_SCREEN_SYNCHRONISE
  
  call Player_Update
  mGA_BORDER_INK GA_INKR_BLACK
  
  ; Loop back
  jp Player_loop


; *****************************************************************************
; DMA player variable.
; *****************************************************************************
.Mod_SpeedCount
  db 0
.Mod_SpeedDelay
  db MOD_DEFAULT_SPEED
.Mod_LineNumber
  db MOD_LINE_PER_PATTERN
.Mod_SongIndex
  db 0
.Mod_PatternLineAddress
  dw 0

; *****************************************************************************
; Volumes C00 LUT.
; *****************************************************************************  
align 256,0
.Mod_VolumeC00
  ds 256,#07

; *****************************************************************************
; Volumes C10 LUT.
; *****************************************************************************
align 256,0
.Mod_VolumeC10
  db #04,#05,#06,#07,#07,#07,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0b

; *****************************************************************************
; Volumes C20 LUT.
; *****************************************************************************
align 256,0
.Mod_VolumeC20
  db #03,#03,#04,#05,#06,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0c,#0c
 
; *****************************************************************************
; Volumes C30 LUT.
; *****************************************************************************
align 256,0
.Mod_VolumeC30
  db #00,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0d,#0d,#0d

; *****************************************************************************
; Volumes C40 LUT.
; *****************************************************************************
align 256,0
.Mod_VolumeC40
  db #00,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0d,#0d,#0d
  
.chanA_inst_len
  dw 0
.chanB_inst_len
  dw 0
.chanC_inst_len
  dw 0

; *****************************************************************************
; Update sample computing with track 1 information.
; *****************************************************************************
; Track organization
;
;     +---------------+---------------+---------------+
; bit |2|2|2|2|1|1|1|1|1|1|1|1|1|1|0|0|0|0|0|0|0|0|0|0|
; no. |3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
;     +---------------+---------------+---------------+
;      \___/ \_______/ | \___________/\______________/
;      FxLSB   Instr   Fx     Note       Parameter
;                      MSB
;
; Nota
; if first byte = &ff then compressed line (3 bytes to 1 byte).
;
; *****************************************************************************
.Track1_Update

  ld a,(hl)
  cp MOD_ENDLINEDETECT
  ret z

  ld b,a
  
; Get Fx (LSB part)
  rlca
  rlca
  rlca
  and MOD_FX_LSB_MASK
  ld iyl,a
  
; Update instrument number ?
  ld a,b
  and MOD_INSTRUMENT_MASK
  jr z,Track1_next_byte_2_col1
  
; Zero indexed
  dec a

; Update sample address to play.
; (sample infos are 5 bytes length).
  exx
  ld d,0
  ld e,a
  ld h,d
  ld l,a
  ld bc,MOD_SAMPLEINFOADDR
  add hl,hl
  add hl,hl
  add hl,de
  add hl,bc

; Get sample address,ram bank and length.
  ld e,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ld (Track1_Current_Address + 1),de
  ld (Track1_Sample_Address + 1),de
  ld a,(hl)
  inc hl
  ld (Track1_Sample_Bank + 1),a
  ld c,(hl)
  inc hl
  ld b,(hl)
  ld (Track1_Sample_Length + 1),bc
  ld (chanA_inst_len),bc
  
; Reset sample volume to maximum. 
  ld hl,Mod_VolumeC40
  ld (Track1_Sample_Volume + 1),hl
  exx

.Track1_next_byte_2_col1
  inc hl
  ld a,(hl)
  ld b,a

; Get FX (MSB part)
  srl a
  srl a
  srl a
  srl a
  and MOD_FX_MSB_MASK
  or iyl
  ld iyl,a 

; Update note ?
  ld a,b
  and MOD_NOTE_MASK
  dec a
  jp m,Track1_next_byte_3_col1

; Update note
  ld (Track1_Note + 1),a  
  
; Get period.  
  exx
  ld de,period
  ld h,0
  ld l,a
  add hl,hl
  add hl,de
  ld a,(hl)
  ld (Track1_Sample_FixedPoint1+1),a
  inc hl
  ld a,(hl)
  ld (Track1_Sample_Integer+1),a
  exx

; Reset sample offset (fixed point part).
  xor a
  ld (Track1_Sample_FixedPoint0+1),a
  
; Reset sample address
  ld ix,(Track1_Sample_Address + 1)
  ld (Track1_Current_Address + 1),ix

  ld bc,(chanA_inst_len)
  ld (Track1_Sample_Length + 1),bc
  
; Enable channel
  ld a,(DMAON + 1)
  or ASIC_DMA_CHANNEL_0
  ld (DMAON + 1),a
  
.Track1_next_byte_3_col1
  inc hl
  
; FX Cxx ?
  ld a,iyl
  cp MOD_EFFECT_Cxx
  jr nz,Track1_Effet_9xx

  ld a,(hl)
  exx
  ld l,a
  ld h,#00
  ld de,Mod_VolumeC00
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,de
  ld (Track1_Sample_Volume+1),hl
  exx
  jr Track1_end

; FX 9xx ? 
.Track1_Effet_9xx
  cp MOD_EFFECT_9xx
  jr nz,Track1_Effet_Fxx

  ld a,(hl)
  exx
  ld l,0
  ld h,a
.Track1_Sample_Address
  ld de,0
  add hl,de
  ld (Track1_Current_Address+1),hl
  exx

; FX Fxx
.Track1_Effet_Fxx
  cp MOD_EFFECT_Fxx
  jr nz,Track1_end
  
  ld a,(hl)
  ld (Mod_SpeedDelay),a

.Track1_end
  ret  

; *****************************************************************************
; Update computing with track 2 information.
; *****************************************************************************
; Track organization
;
;     +---------------+---------------+---------------+
; bit |3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | |
; no. |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|
;     +---------------+---------------+---------------+
;      \___/ \_______/ |  \_________/ \_____________/
;      FxLSB   Sample  Fx     Note       Parameter
;                      MSB
;
; Nota
; if first byte = &ff then compressed line (3 bytes to 1 byte).
;
; *****************************************************************************
.Track2_Update

  ld a,(hl)
  cp MOD_ENDLINEDETECT
  ret z

  ld b,a
  
; Get Fx (LSB part)
  rlca
  rlca
  rlca
  and MOD_FX_LSB_MASK
  ld iyl,a
  
; Update instrument number ?
  ld a,b
  and MOD_INSTRUMENT_MASK
  dec a
  jp m,Track2_next_byte_2_col1

; Update sample address to play.
; (sample infos are 5 bytes length).
  exx
  ld d,0
  ld e,a
  ld h,d
  ld l,a
  ld bc,MOD_SAMPLEINFOADDR
  add hl,hl
  add hl,hl
  add hl,de
  add hl,bc

; Get sample address,ram bank and length.
  ld e,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ld (Track2_Current_Address + 1),de
  ld (Track2_Sample_Address + 1),de
  ld a,(hl)
  inc hl
  ld (Track2_Sample_Bank + 1),a
  ld c,(hl)
  inc hl
  ld b,(hl)
  ld (Track2_Sample_Length + 1),bc
  ld (chanB_inst_len),bc
  
; Reset sample volume to maximum. 
  ld hl,Mod_VolumeC40
  ld (Track2_Sample_Volume + 1),hl
  exx

.Track2_next_byte_2_col1
  inc hl
  ld a,(hl)
  ld b,a

; Get FX (MSB part)
  srl a
  srl a
  srl a
  srl a
  and MOD_FX_MSB_MASK
  or iyl
  ld iyl,a 

; Update note ?
  ld a,b
  and MOD_NOTE_MASK
  dec a
  jp m,Track2_next_byte_3_col1

; Update note
  ld (Track2_Note + 1),a  
  
; Get period.  
  exx
  ld de,period
  ld h,0
  ld l,a
  add hl,hl
  add hl,de
  ld a,(hl)
  ld (Track2_Sample_FixedPoint1+1),a
  inc hl
  ld a,(hl)
  ld (Track2_Sample_Integer+1),a
  exx

; Reset sample offset (fixed point part).
  xor a
  ld (Track2_Sample_FixedPoint0+1),a
  
; Reset sample address
  ld ix,(Track2_Sample_Address + 1)
  ld (Track2_Current_Address + 1),ix

  ld bc,(chanB_inst_len)
  ld (Track2_Sample_Length + 1),bc

; Enable channel
  ld a,(DMAON + 1)
  or ASIC_DMA_CHANNEL_1
  ld (DMAON + 1),a
  
.Track2_next_byte_3_col1
  inc hl

; FX Cxx ?
  ld a,iyl
  cp MOD_EFFECT_Cxx
  jr nz,Track2_Effet_9xx

  ld a,(hl)
  exx
  ld l,a
  ld h,#00
  ld de,Mod_VolumeC00
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,de
  ld (Track2_Sample_Volume+1),hl
  exx
  jr Track2_end

; FX 9xx ? 
.Track2_Effet_9xx
  cp MOD_EFFECT_9xx
  jr nz,Track2_Effet_Fxx

  ld a,(hl)
  exx
  ld l,0
  ld h,a
.Track2_Sample_Address
  ld de,0
  add hl,de
  ld (Track2_Current_Address+1),hl
  exx

; FX Fxx
.Track2_Effet_Fxx
  cp MOD_EFFECT_Fxx
  jr nz,Track2_end
  
  ld a,(hl)
  ld (Mod_SpeedDelay),a
  
.Track2_end
  ret  
  
; *****************************************************************************
; Update sample computing with track 3 information.
; *****************************************************************************
; Track organization
;
;     +---------------+---------------+---------------+
; bit |3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | |
; no. |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|
;     +---------------+---------------+---------------+
;      \___/ \_______/ |  \_________/ \_____________/
;      FxLSB   Sample  Fx     Note       Parameter
;                      MSB
;
; Nota
; if first byte = &ff then compressed line (3 bytes to 1 byte).
;
; *****************************************************************************
.Track3_Update

  ld a,(hl)
  cp MOD_ENDLINEDETECT
  ret z

  ld b,a
  
; Get Fx (LSB part)
  rlca
  rlca
  rlca
  and MOD_FX_LSB_MASK
  ld iyl,a
  
; Update instrument number ?
  ld a,b
  and MOD_INSTRUMENT_MASK
  jr z,Track3_next_byte_2_col1
  
; Zero indexed
  dec a

; Update sample address to play.
; (sample infos are 5 bytes length).
  exx
  ld d,0
  ld e,a
  ld h,d
  ld l,a
  ld bc,MOD_SAMPLEINFOADDR
  add hl,hl
  add hl,hl
  add hl,de
  add hl,bc

; Get sample address,ram bank and length.
  ld e,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ld (Track3_Current_Address + 1),de
  ld (Track3_Sample_Address + 1),de
  ld a,(hl)
  inc hl
  ld (Track3_Sample_Bank + 1),a
  ld c,(hl)
  inc hl
  ld b,(hl)
  ld (Track3_Sample_Length + 1),bc
  ld (chanC_inst_len),bc
  
; Reset sample volume to maximum. 
  ld hl,Mod_VolumeC40
  ld (Track3_Sample_Volume + 1),hl
  exx

.Track3_next_byte_2_col1
  inc hl
  ld a,(hl)
  ld b,a

; Get FX (MSB part)
  srl a
  srl a
  srl a
  srl a
  and MOD_FX_MSB_MASK
  or iyl
  ld iyl,a 

; Update note ?
  ld a,b
  and MOD_NOTE_MASK
  jr z,Track3_next_byte_3_col1

; Zero indexed
  dec a

; Update note
  ld (Track3_Note + 1),a  
  
; Get period.  
  exx
  ld de,period
  ld h,0
  ld l,a
  add hl,hl
  add hl,de
  ld a,(hl)
  ld (Track3_Sample_FixedPoint1 + 1),a
  inc hl
  ld a,(hl)
  ld (Track3_Sample_Integer + 1),a
  exx

; Reset sample offset (fixed point part).
  xor a
  ld (Track3_Sample_FixedPoint0 + 1),a
  
; Reset sample address
  ld ix,(Track3_Sample_Address + 1)
  ld (Track3_Current_Address + 1),ix

  ld bc,(chanC_inst_len)
  ld (Track3_Sample_Length + 1),bc

; Enable channel
  ld a,(DMAON + 1)
  or ASIC_DMA_CHANNEL_2
  ld (DMAON + 1),a
  
.Track3_next_byte_3_col1
  inc hl
  
; FX Cxx ?
  ld a,iyl
  cp MOD_EFFECT_Cxx
  jr nz,Track3_Effet_9xx

  ld a,(hl)
  exx
  ld l,a
  ld h,#00
  ld de,Mod_VolumeC00
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,de
  ld (Track3_Sample_Volume + 1),hl
  exx
  jr Track3_end

; FX 9xx ? 
.Track3_Effet_9xx
  cp MOD_EFFECT_9xx
  jr nz,Track3_Effet_Fxx

  ld a,(hl)
  exx
  ld l,0
  ld h,a
.Track3_Sample_Address
  ld de,0
  add hl,de
  ld (Track3_Current_Address+1),hl
  exx
  
; FX Fxx
.Track3_Effet_Fxx
  cp MOD_EFFECT_Fxx
  jr nz,Track3_end
  
  ld a,(hl)
  ld (Mod_SpeedDelay),a
  
.Track3_end
  ret
