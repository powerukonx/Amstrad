; *****************************************************************************
; *                          DMA MOD Player by UKONX                          *
; *                                                                           *
; * Code => Power                                                             *
; *                                                                           *
; *****************************************************************************
; COLUMN organization                
; Byte1 => xxxyyyyy with xxx is effect LSB and yyyyy is instrument number,
; if yyyyy> then play new note.                             
; *****************************************************************************  
.Player_Update

; ASIC page-in.
  mASIC_PAGE ASIC_PAGE_IN
  
; Set AY list source for DMA Channel 0.
PROGDMA0
  ld de,DMA0_Buffer1
  ld hl,ASIC_REG_SAR0
  ld (hl),e
  inc l
  ld (hl),d

; Set AY list source for DMA Channel 1.
PROGDMA1
  ld de,DMA1_Buffer1
  ld hl,ASIC_REG_SAR1
  ld (hl),e
  inc l
  ld (hl),d

; Set AY list source for DMA Channel 2.
PROGDMA2
  ld de,DMA2_Buffer1
  ld hl,ASIC_REG_SAR2
  ld (hl),e
  inc l
  ld (hl),d

; Enable/Disable DMA Channels
  ld hl,ASIC_REG_DCSR
DMAON
  ld (hl),0
  
; ASIC page-out.
  mASIC_PAGE ASIC_PAGE_OUT

; Update speed counter.
  ld hl,Mod_SpeedDelay
  ld a,(Mod_SpeedCount)
  inc a
  ld (Mod_SpeedCount),a
  cp (hl)
  jp nz,swap0

; Select bank configuration C4.
  mPAL_RAM_SELECT PAL_MMR_BANK0, PAL_MMR_CONFIG4
  
; HL will contain current pattern line.
  ld hl,(Mod_PatternLineAddress)
  
  call Track1_Update
  inc hl  

  call Track2_Update
  inc hl

  call Track3_Update
  inc hl

  ld a,(Mod_LineNumber)
  dec a
  jr nz,next_line

; Increment song position
  ld hl,MOD_PATTERNNB
  ld a,(Mod_SongIndex)
  inc a
  cp (hl)
  jr nz,compute_next_pattern

; Reset position (TODO insert restart)
 xor a
  
.compute_next_pattern  
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
  
; Reset number of line per pattern
  ld a,MOD_LINE_PER_PATTERN

next_line
  ld (Mod_LineNumber),a
  ld (Mod_PatternLineAddress),hl
  xor a
  ld (Mod_SpeedCount),a

swap0
  ld a,0
  xor 1
  ld (swap0 + 1),a
  jr z,swap1

  ld bc,DMA0_Buffer1
  ld de,DMA1_Buffer1
  ld hl,DMA2_Buffer1
  jr swap_end

swap1
  ld bc,DMA0_Buffer2
  ld de,DMA1_Buffer2
  ld hl,DMA2_Buffer2

swap_end
  ld (PROGDMA0+1),bc
  ld (PROGDMA1+1),de
  ld (PROGDMA2+1),hl

; Fill Track 1 DMA buffer.  
.Track1_Sample_Bank
  ld bc,#7fc5
  out (c),c

  mGA_BORDER_INK GA_INKR_SEA_GREEN
.Track1_Note
  ld a,0
  add a,a
  ld l,a
  ld h,AverageStep/256
  ld c,(hl)
  inc hl
  ld b,(hl)  
  
.Track1_Sample_Length
  ld hl,0
  sbc hl,bc
  jp p,Track1_Cont_Init

  ld bc,Mod_VolumeC00
  ld (Track1_Sample_Volume +1),bc

.Track1_Cont_Init
  ld (Track1_Sample_Length + 1),hl
  
.Track1_Current_Address
  ld hl,0
  
.Track1_Sample_Volume
  ld bc,Mod_VolumeC00
  
.Track1_Sample_Integer
  ld de,0

  exx
  ld hl,(PROGDMA0 + 1)
  ld bc,2

.Track1_Sample_FixedPoint1  
  ld e,0
  exx
  
  ex af,af'
.Track1_Sample_FixedPoint0
  ld a,0
  ex af,af'
  
  call DMA_Filler
  
  ld (Track1_Current_Address + 1),hl

; Fill Track 2 DMA buffer.  
mGA_BORDER_INK GA_INKR_PURPLE
.Track2_Sample_Bank
  ld bc,#7fc5
  out (c),c

.Track2_Note
  ld a,0
  add a,a
  ld l,a
  ld h,AverageStep/256
  ld c,(hl)
  inc hl
  ld b,(hl)  
  
.Track2_Sample_Length
  ld hl,0
  sbc hl,bc
  jp p,Track2_Cont_Init

  ld bc,Mod_VolumeC00
  ld (Track2_Sample_Volume +1),bc

.Track2_Cont_Init
  ld (Track2_Sample_Length + 1),hl
  
.Track2_Current_Address
  ld hl,0
  
.Track2_Sample_Volume
  ld bc,Mod_VolumeC00
  
.Track2_Sample_Integer
  ld de,0

  exx
  ld hl,(PROGDMA1 + 1)
  ld bc,2

.Track2_Sample_FixedPoint1  
  ld e,0
  exx
  
  ex af,af'
.Track2_Sample_FixedPoint0
  ld a,0
  ex af,af'
  
  call DMA_Filler
  
  ld (Track2_Current_Address + 1),hl

; Fill Track 3 DMA buffer.
mGA_BORDER_INK GA_INKR_ORANGE
.Track3_Sample_Bank
  ld bc,#7fc5
  out (c),c

.Track3_Note
  ld a,0
  add a,a
  ld l,a
  ld h,AverageStep/256
  ld c,(hl)
  inc hl
  ld b,(hl)  
  
.Track3_Sample_Length
  ld hl,0
  sbc hl,bc
  jp p,Track3_Cont_Init

  ld bc,Mod_VolumeC00
  ld (Track3_Sample_Volume +1),bc

.Track3_Cont_Init
  ld (Track3_Sample_Length + 1),hl
  
.Track3_Current_Address
  ld hl,0
  
.Track3_Sample_Volume
  ld bc,Mod_VolumeC00
  
.Track3_Sample_Integer
  ld de,0

  exx
  ld hl,(PROGDMA2 + 1)
  ld bc,2

.Track3_Sample_FixedPoint1  
  ld e,0
  exx
  
  ex af,af'
.Track3_Sample_FixedPoint0
  ld a,0
  ex af,af'
  
  call DMA_Filler
  
  ld (Track3_Current_Address + 1),hl

fin_play

; Asic page-out
  mASIC_PAGE ASIC_PAGE_OUT

  ret

; *****************************************************************************
; Fill DMA buffer.
;
; HL  = Sample address offset (integer part)
; DE  = Sample period (interger part).
; BC  = Volume table.
;
; HL' = DMA table
; BC' = 2 (DMA table step).
; A'  = Sample address offset (fixed point part).
; E'  = Sample period (fixed point part).
;
; AF, HL, AF' and HL' are modified
; *****************************************************************************
.DMA_Filler 

  repeat 312
  ; Get sample
  ld c,(hl)   ; 1byte - 2us
  
  ; Apply volume
  ld a,(bc)   ; 1byte - 2us

  ; Copy to DMA table
  exx         ; 1byte - 1us
  ld (hl),a   ; 1byte - 2us
  add hl,bc   ; 1byte - 3us

  ; Compute next sample offset with sample period 
  ex af,af'   ; 1byte - 1us
  add a,e     ; 1byte - 1us
  exx         ; 1byte - 1us
  adc hl,de   ; 1byte - 4us
  ex af,af'   ; 1byte - 1us 
              ; => 312 x 10 bytes = 3120 bytes / channel
              ; => 312 x 18 us    = 5616 us / channel 
  rend

  ret

; *****************************************************************************
; DMA0 AY list buffer1 (&0B00).
; *****************************************************************************
align 256,0
.DMA0_Buffer1
  repeat 312
  dw ASIC_DMA_LOAD_8_7
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; DMA0 AY list buffer2 (&0E00).
; *****************************************************************************
align 256,0
.DMA0_Buffer2
  repeat 312
  dw ASIC_DMA_LOAD_8_7
  rend
  dw ASIC_DMA_STOP
 
; *****************************************************************************
; DMA1 AY list buffer1.
; *****************************************************************************
align 256,0
.DMA1_Buffer1
  repeat 312
  dw ASIC_DMA_LOAD_9_7
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; DMA1 AY list buffer2.
; *****************************************************************************
align 256,0
.DMA1_Buffer2
  repeat 312
  dw ASIC_DMA_LOAD_9_7
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; DMA2 AY list buffer1.
; *****************************************************************************
align 256,0
.DMA2_Buffer1
  repeat 312
  dw ASIC_DMA_LOAD_10_7
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; DMA2 AY list buffer 2.
; *****************************************************************************
align 256,0
.DMA2_Buffer2
  repeat 312
  dw ASIC_DMA_LOAD_10_7
  rend
  dw ASIC_DMA_STOP
  
; *****************************************************************************
; Average incrementation LUT for each note.
; *****************************************************************************
align 256,0
.AverageStep
  dw &002B, &002B, &002E, &0031, &0034, &003A, &003A, &003F, &0041, &0045, &004E, &004E
  dw &0057, &0057, &005C, &0062, &0068, &0075, &0075, &003F, &007E, &008A, &0092, &009C
  dw &00A5, &00AE, &00B8, &00C4, &00CF, &00DB, &00E8, &00FD, &0105, &0115, &0125, &0138
  dw &014B, &015D, &0171, &0187, &019F, &01B7, &01D2, &01ED, &020A, &0229, &024A, &0270
  dw &0292, &02B9, &02E3, &030F, &033F, &036F, &03A4, &03DB, &0415, &041B, &0495, &04E0  
  
; *****************************************************************************
; Sound to CPC period LUT (60 notes).
; *****************************************************************************
align 256,0
.period
  dw 0034,0036,0038,0040,0046,0045,0048,0051,0054,0057,0060,0064
  dw 0068,0072,0076,0081,0086,0091,0096,0102,0108,0114,0121,0128 ; Octave 1
  dw 0136,0144,0153,0162,0171,0182,0192,0204,0216,0229,0242,0257 ; Octave 2
  dw 0272,0288,0305,0323,0343,0363,0385,0407,0432,0457,0485,0513 ; Octave 3
  dw 0544,0576,0611,0647,0685,0726,0769,0815,0863,0915,0969,1027 ; Octave 4
  dw 1088,1153,1221,1294,1371,1452,1539,1630,1727,1830,1839,2054 ; Octave 5
