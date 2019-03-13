; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                                                                           *
; * Code            => Power                                                  *
; * Algo            => Power / Deemphasis                                     *
; * Zik             => Deemphasis                                             *
; * Gfxs            => Ozane / Power                                          *
; * Retourche GFXs  => Grimmy                                                 *
; *                                                                           *
; *****************************************************************************
; *                                                                           *
; *  Tools used                                                               *
; *  - Assembler    = WinAPE                                                  *
; *  - GFX/Transfer = The Gimp                                                *
; *  - Packer = Bitbuster v1.2 (Team Bomba)                                   *
; *  - Module = Milky tracker.                                                *
; *                                                                           *
; *****************************************************************************
; *                                                                           *
; * RAM memory mapping                                                        *
; * ------------------                                                        *
; *                                                                           *
; * Bank &C0                                                                  *
; *   &0000 - &0037 = Main loop                                               *
; *   &0038 - &003A = JP to module player                                     *
; *   &003B - &xxxx = Init + Tables (player, screen...)                       *
; *   &xxx+1- &7FFF = Player + effects...                                     *
; *   &8000 - &FFFF = Video memory                                            *
; * Bank &C4                                                                  *
; *   &4000 - 87FFF = MOD                                                     *
; * Bank &C5                                                                  *
; *   &4000 - 87FFF = MOD                                                     *
; * Bank &C6                                                                  *
; *   &4000 - &???? = FX DEFORMATION ADD                                      *
; *   &5430 - &???? = FX DEFORMATION SUB                                      *
; *   &6C80 - &???? = METABALLS 2D                                            *
; *   &7530 - &???? = FIRE                                                    *
; *   &7640 - &???? = PLASMA                                                  *
; * Bank &C7                                                                  *
; *   &4000 - &???? = TXT SPRITE                                              *
; *   &40C0 - &???? = TXT SPRITE                                              *
; *   &4170 - &???? = TXT SPRITE                                              *
; *   &4290 - &???? = TXT SPRITE                                              *
; *   &43D0 - &???? = TXT SPRITE                                              *
; *   &4320 - &???? = TXT SPRITE                                              *
; *   &5000 - &???? = ROTOZOOM                                                *
; *   &5510 - &???? = BUMP                                                    *
; *   &5C40 - &???? = GFX INTRO (WOMAN)                                       *
; *   &7600 - &???? = END PART                                                *
; *   &4000 - 87FFF = FX + sprite + GFX                                       *
; *                                                                           *
; *  Hard sprite 0,1,2,3 = Text banner                                        *
; *  Hard sprite 4,5,6,7,8,9,10,11 = UKX logo                                 *
; *                                                                           *
; *****************************************************************************

; *****************************************************************************
; Include some definition.
; *****************************************************************************
  read "./Define/macro.asm"
  read "./Define/component.asm"

; *****************************************************************************
; Constant definition.
; *****************************************************************************
MOD_SAMPLEOFFSET    equ 200
MOD_SAMPLEINFOADDR  equ &4000
MOD_PATTERNADDR     equ &4052
MOD_ENDLINEDETECT   equ &FF  ; Line compression detection byte
MOD_EFFECT_9xx      equ &09
MOD_EFFECT_Cxx      equ &0c
MOD_EFFECT_Exx      equ &0e

EFFECT_EXECADDR     equ &3000

ASIC_DMA_NO_SOUND   equ #0007
ASIC_DMA_LOAD_8_7   equ PSG_CHANNEL_A_AMPLITUDE*256 + ASIC_DMA_NO_SOUND
ASIC_DMA_LOAD_9_7   equ PSG_CHANNEL_B_AMPLITUDE*256 + ASIC_DMA_NO_SOUND
ASIC_DMA_LOAD_10_7  equ PSG_CHANNEL_C_AMPLITUDE*256 + ASIC_DMA_NO_SOUND

; *****************************************************************************
; &0000 - &0037 = Initialize, Loop...
; *****************************************************************************
Entry_Point

; Disable interrupt.
  di

; *****************************************************************************
; Initialize stack to high memory available (&2000).
; Warning, only 34 pushes allowed !!
; *****************************************************************************
  ld sp,Stack_End

; Initialize demo system.
  call Demo_Init

; Enable interrupt.
  ei

; Effect to execute.
Effect_Exec
  call Init_End

; Text banner to display.  
Text_Exec
  call Init_End

; Loop back
  jp Effect_Exec

; *****************************************************************************
; ASIC unlocking sequence.
; *****************************************************************************
Asic_SequenceLUT
  db #ff,#00,#ff,#77,#b3,#51,#a8,#d4
  db #62,#39,#9c,#46,#2b,#15,#8a,#cd
  db #ee

; *****************************************************************************
; DMA player variable.
; *****************************************************************************
Mod_SpeedCount
  db 0
Mod_SpeedDelay
  db 6
Mod_LineNumber
  db 64
Mod_SongIndex
  db 0

; *****************************************************************************
; Fade in to FX deform add.
; *****************************************************************************
DefAdd_Display

; Initialize text banner position.
  ld hl,Banner_MoveLUT
  ld (Banner_Display + 1),hl

; Set FX callback address.
  ld hl,EFFECT_EXECADDR
  ld (Effect_Exec + 1),hl

; Set effect palette.  
  ld hl,DefAdd_Palette

  jp Put_palette

; *****************************************************************************
; IM1 Subroutine (DMA player, ...).
; *****************************************************************************  
Demo_Isr
  jp Demo_Update

; *****************************************************************************
; Demo system initialization.
; *****************************************************************************
Demo_Init

; Unlock ASIC.
  ld e,#11
  ld hl,Asic_SequenceLUT
  ld bc,PORT_CRTC_SELECT_REG
unlock_asic
  ld a,(hl)
  out (c),a
  inc hl
  dec e
  jr nz,unlock_asic
  
; Asic page-in.
  ASIC_PAGEIN

; Initialize hard sprite.
  call initialize_hardspr

; Set all + inks and sprite color to black color.
  ASIC_INKS_AND_SPR_BLACK
  
; Raster interrupt to line 1.
  ld a,1
  ld (ASIC_REG_PRI),a

; Asic page-out
  ASIC_PAGEOUT
  
; Set low resolution 160x200x4bpp.
  ld c,#8c
  out (c),c
  
; Set video resolution (fake 16/9).
  ld bc,PORT_CRTC_SELECT_REG + CRTC_HORIZONTAL_DISPLAYED
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
  ld c,&06
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

  ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
  out (c),c
  ld bc,PORT_CRTC_WRITE_DATA + &10
  out (c),c

  ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_L
  out (c),c
  ld bc,PORT_CRTC_WRITE_DATA + &00
  out (c),c

; Raster interrupt will call DMA player.
  ld hl,Demo_Update
  ld (Demo_Isr + 1),hl
  
; Set video memory to title (&4000).
  ld a,#10
  ld (page_visible + 1),a
  
; Unpack text banner
  ld hl,depack_txt
  ld (Text_Exec + 1),hl
  
; *****************************************************************************
; Nothing to do subroutine.
; *****************************************************************************
Init_End
  ret
  
; *****************************************************************************
; Archive pack definition,
;  +0 Memory bank
;  +1 Memory address
;  +3 type (0 = data, 1 = code)
;   if +3 = 0, +4 subtype (0 = text banner, 1 = gfx)
; *****************************************************************************
DefAdd_Pack
  db #c6,#00,#40,#01
DefSub_Pack
  db #c6,#30,#54,#01
Fire_Pack
  db #c6,#30,#75,#01
Plasma_Pack
  db #c6,#40,#76,#01
Metaball_Pack
  db #c6,#80,#6c,#01
Rotozoom_Pack
  db #c7,#00,#50,#01
Bump_Pack
  db #c7,#10,#55,#01
EndLogo_Pack
  db #c7,#40,#5c,#00,#01
TextBanner1_Pack
  db #c7,#00,#40,#00,#00
TextBanner2_Pack
  db #c7,#c0,#40,#00,#00
TextBanner3_Pack
  db #c7,#70,#41,#00,#00
TextBanner4_Pack
  db #c7,#f0,#41,#00,#00
TextBanner5_Pack
  db #c7,#90,#42,#00,#00
TextBanner6_Pack
  db #c7,#20,#43,#00,#00
TextBanner7_Pack
  db #c7,#d0,#43,#00,#00
End_Pack
  db #c7,#00,#76,#01

; *****************************************************************************
; DMA buffer filling (&0100).
; *****************************************************************************
fill_buffer
  push hl:exx:ld (TempBC1 + 1),bc:ld (TempHL1 + 1),hl:ld bc,Mod_SampleOffset:sbc hl,bc:pop bc:sbc hl,bc
TempHL1
  ld hl,0
TempBC1
  ld bc,0
  jp p,cont40
  ld bc,volume
cont40
  exx

  repeat 63
  ex af,af':add a,e:adc hl,bc:ex af,af':ld a,(hl):exx:ld c,a:ld a,(bc):ld (de),a:inc e:inc e:inc e:inc e:exx
  rend
  
  ex af,af':add a,e:adc hl,bc:ex af,af':ld a,(hl):exx:ld c,a:ld a,(bc):ld (de),a:inc e:inc de:inc e:inc de:exx

  repeat 6
  ex af,af':add a,e:adc hl,bc:ex af,af':ld a,(hl):exx:ld c,a:ld a,(bc):ld (de),a:inc e:inc e:inc e:inc e:exx
  rend

  push hl:exx
  ld (TempBC2+1),bc:ld (TempHL2+1),hl:ld bc,Mod_SampleOffset:sbc hl,bc:pop bc:sbc hl,bc
TempHL2
  ld hl,0
TempBC2
  ld bc,0
  jp p,cont320
  ld bc,volume
cont320
  exx
  
  repeat 57
  ex af,af':add a,e:adc hl,bc:ex af,af':ld a,(hl):exx:ld c,a:ld a,(bc):ld (de),a:inc e:inc e:inc e:inc e:exx
  rend
  
  ex af,af':add a,e:adc hl,bc:ex af,af':ld a,(hl):exx:ld c,a:ld a,(bc):ld (de),a:inc e:inc de:inc e:inc de:exx
  
  repeat 28
  ex af,af':add a,e:adc hl,bc:ex af,af':ld a,(hl):exx:ld c,a:ld a,(bc):ld (de),a:inc e:inc e:inc e:inc e:exx
  rend

  ret

; *****************************************************************************
; Sound to CPC period LUT.
; *****************************************************************************
period
  dw 0068,0072,0076,0081,0086,0091,0096,0102,0108,0114,0121,0128 ; Octave 1
  dw 0136,0144,0153,0162,0171,0182,0192,0204,0216,0229,0242,0257 ; Octave 2
  dw 0272,0288,0305,0323,0343,0363,0385,0407,0432,0457,0485,0513 ; Octave 3
  dw 0544,0576,0611,0647,0685,0726,0769,0815,0863,0915,0969,1027 ; Octave 4
  dw 1088,1153,1221,1294,1371,1452,1539,1630,1727,1830,1839,2054 ; Octave 5
  
; *****************************************************************************
; Fade out FX fire, display text banner and unpack FX meta-ball.
; *****************************************************************************
Metaball_Depack

  ld hl,Banner_MoveLUT + 95
  ld (Banner_Clear + 1),hl

  ld hl,Grey_Palette
  ld de,Metaball_Pack
  ld bc,clear_effect

  jp Put_fx

; *****************************************************************************
; Fade in meta-ball.
; *****************************************************************************
Metaball_Display

  ld hl,Banner_MoveLUT
  ld (Banner_Display + 1),hl

  ld hl,EFFECT_EXECADDR
  ld (Effect_Exec + 1),hl

  ld hl,Metaball_Palette

  jp Put_palette

; *****************************************************************************
; FX_Wait = Do nothing.
; *****************************************************************************
FX_Wait
  jp Demo_Continue

; *****************************************************************************
; DMA0 AY list buffer1 (&0B00).
; *****************************************************************************
DMA0_Buffer1
  repeat 156
  dw ASIC_DMA_LOAD_8_7, ASIC_DMA_NOP_N
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; Additive deformation palette.
; *****************************************************************************
DefAdd_Palette
  db #01,#00,#00,#03,#01,#01,#06,#02
  db #02,#08,#02,#03,#0b,#03,#04,#0b
  db #04,#05,#09,#05,#06,#07,#07,#07
  db #06,#09,#08,#04,#0a,#09,#03,#0b
  db #0a,#02,#0c,#0c,#03,#0e,#0d,#07
  db #0e,#0e,#0b,#0f,#0f,#0f,#0f,#0f
  db #01,#00,#00,#03,#01,#01,#06,#02
  db #02,#08,#02,#03,#0b,#03,#04,#0b
  db #04,#05,#09,#05,#06,#07,#07,#07
  db #06,#09,#08,#04,#0a,#09,#03,#0b
  db #0a,#02,#0c,#0c,#03,#0e,#0d,#07
  db #0e,#0e,#0b,#0f,#0f,#0f,#0f,#0f

; *****************************************************************************
; Stack location (24 push/pop).
; *****************************************************************************
Stack 
  db #00,#00,#00,#00,#00,#00,#00,#00
  db #00,#00,#00,#00,#00,#00,#00,#00
  db #00,#00,#00,#00,#32,#2a,#83,#8b
  db #32,#2a,#44,#00,#40,#a0,#00,#00
  db #00,#c0,#00,#00,#01,#93,#01,#00
  db #8c,#00,#b7,#00,#0e,#00
Stack_End

; *****************************************************************************
; DMA0 AY list buffer2 (&0E00).
; *****************************************************************************
DMA0_Buffer2
  repeat 156
  dw ASIC_DMA_LOAD_8_7, ASIC_DMA_NOP_N
  rend
  dw ASIC_DMA_STOP
  
; *****************************************************************************
; Fire palette.
; *****************************************************************************
Fire_Palette
  db #03,#02,#00,#05,#03,#00,#07,#04
  db #00,#08,#05,#00,#0a,#06,#00,#08
  db #08,#01,#06,#09,#02,#04,#0b,#02
  db #03,#0d,#03,#03,#0d,#05,#03,#0d
  db #07,#03,#0d,#0a,#06,#0e,#0c,#09
  db #0f,#0d,#0d,#0f,#0f,#0f,#0f,#0f
  db #03,#02,#00,#05,#03,#00,#07,#04
  db #00,#08,#05,#00,#0a,#06,#00,#08
  db #08,#01,#06,#09,#02,#04,#0b,#02
  db #03,#0d,#03,#03,#0d,#05,#03,#0d
  db #07,#03,#0d,#0a,#06,#0e,#0c,#09
  db #0f,#0d,#0d,#0f,#0f,#0f,#0f,#0f

; *****************************************************************************
; Fade in to intro Logo.
; *****************************************************************************
Intro_Display
  
; Select screen memory page.
  ld a,#10
  ld (page_visible + 1),a

; Select palette.
  ld hl,Intro_Palette
  
  jp Put_palette

; *****************************************************************************
; Fade out logo, black screen and unpack FX plasma.
; *****************************************************************************
Plasma_Depack

  ld hl,Black_Palette
  ld de,Plasma_Pack
  ld bc,depack

  jp Put_fx

; *****************************************************************************
; Fade in to FX plasma.
; *****************************************************************************
Plasma_Display

  ld hl,Banner_MoveLUT
  ld (Banner_Display + 1),hl
  ld hl,EFFECT_EXECADDR
  ld (Effect_Exec + 1),hl

  ld hl,Plasma_Palette

  ld a,#30
  ld (page_visible + 1),a

  jp Put_palette
  
; *****************************************************************************
; DMA1 AY list buffer1.
; *****************************************************************************
DMA1_Buffer1
  repeat 156
  dw ASIC_DMA_LOAD_9_7, ASIC_DMA_NOP_N
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; Meta-ball palette.
; *****************************************************************************
Metaball_Palette
  db #00,#00,#00,#00,#00,#00,#00,#00
  db #00,#00,#00,#00,#00,#00,#00,#03
  db #01,#01,#08,#02,#03,#0b,#03,#04
  db #0b,#04,#05,#07,#07,#07,#06,#09
  db #08,#03,#0b,#0a,#02,#0c,#0c,#07
  db #0e,#0e,#0b,#0f,#0f,#0f,#0f,#0f
  db #00,#00,#00,#00,#00,#00,#00,#00
  db #00,#00,#00,#00,#00,#00,#00,#03
  db #01,#01,#08,#02,#03,#0b,#03,#04
  db #0b,#04,#05,#07,#07,#07,#06,#09
  db #08,#03,#0b,#0a,#02,#0c,#0c,#07
  db #0e,#0e,#0b,#0f,#0f,#0f,#0f,#0f

; *****************************************************************************
; Fade out FX plasma, display text banner and unpack FX fire.
; *****************************************************************************
Fire_Depack

  ld a,#0f
  ld (len_fade + 1),a

  ld hl,Banner_MoveLUT + 95
  ld (Banner_Clear + 1),hl

  ld hl,Grey_Palette
  ld de,Fire_Pack
  ld bc,clear_effect

  jp Put_fx
  
; *****************************************************************************
; Fade in FX fire.
; *****************************************************************************
Fire_Display

  ld hl,Banner_MoveLUT
  ld (Banner_Display + 1),hl

  ld hl,EFFECT_EXECADDR
  ld (Effect_Exec + 1),hl

  ld hl,Fire_Palette

  jp Put_palette
  
; *****************************************************************************
; Current MOD MOD_PATTERNADDR line.
; *****************************************************************************  
pattern_line_adress
  dw MOD_PATTERNADDR

; *****************************************************************************
; Padding.
; *****************************************************************************
  align 256,0

; *****************************************************************************
; DMA1 AY list buffer2.
; *****************************************************************************
DMA1_Buffer2
  repeat 156
  dw ASIC_DMA_LOAD_9_7, ASIC_DMA_NOP_N
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; Rotozoom palette.
; *****************************************************************************
Rotozoom_Palette
  db #00,#00,#00,#02,#02,#00,#03,#03
  db #00,#05,#05,#00,#07,#06,#01,#0a
  db #07,#03,#0c,#08,#04,#0f,#09,#05
  db #0e,#0b,#06,#0d,#0c,#07,#0d,#0e
  db #08,#0c,#0f,#08,#08,#0f,#0c,#09
  db #0f,#0d,#0a,#0f,#0f,#0b,#0f,#0f
  db #00,#00,#00,#02,#02,#00,#03,#03
  db #00,#05,#05,#00,#07,#06,#01,#0a
  db #07,#03,#0c,#08,#04,#0f,#09,#05
  db #0e,#0b,#06,#0d,#0c,#07,#0d,#0e
  db #08,#0c,#0f,#08,#08,#0f,#0c,#09
  db #0f,#0d,#0a,#0f,#0f,#0b,#0f,#0f

; *****************************************************************************
; Padding.
; *****************************************************************************
  align 256,0

; *****************************************************************************
; DMA2 AY list buffer1.
; *****************************************************************************
DMA2_Buffer1
  repeat 156
  dw ASIC_DMA_LOAD_10_7, ASIC_DMA_NOP_N
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; Hard sprite disable.
; *****************************************************************************
disable_sprite

; Asic page-in.
  ASIC_PAGEIN

; Disable hard sprite.  
  xor a
  ld (ASIC_ADR_SPR0_ZOOM),a
  ld (ASIC_ADR_SPR1_ZOOM),a
  ld (ASIC_ADR_SPR2_ZOOM),a
  ld (ASIC_ADR_SPR3_ZOOM),a
  ld (ASIC_ADR_SPR4_ZOOM),a
  ld (ASIC_ADR_SPR5_ZOOM),a
  ld (ASIC_ADR_SPR6_ZOOM),a
  ld (ASIC_ADR_SPR7_ZOOM),a
  ld (ASIC_ADR_SPR8_ZOOM),a
  ld (ASIC_ADR_SPR9_ZOOM),a
  ld (ASIC_ADR_SPR10_ZOOM),a
  ld (ASIC_ADR_SPR11_ZOOM),a
  ld (ASIC_ADR_SPR12_ZOOM),a
  ld (ASIC_ADR_SPR13_ZOOM),a
  ld (ASIC_ADR_SPR14_ZOOM),a
  ld (ASIC_ADR_SPR15_ZOOM),a

; Asic page-out.  
  ld c,#a0
  out (c),c

  ret

; *****************************************************************************
; Demo end.
; *****************************************************************************
Demo_End

; Insert CALL wait_2s into Effect exec
  ld a,#cd
  ld (Effect_Exec),a
  ld hl,wait_2s
  ld (Effect_Exec + 1),hl

  jp Demo_Continue
  
; *****************************************************************************
; Fade out FX deform sub, display text banner and unpack FX bump.
; *****************************************************************************
Bump_Depack

  ld hl,Banner_MoveLUT + 95
  ld (Banner_Clear + 1),hl

  ld hl,Grey_Palette

  ld de,Bump_Pack

  ld bc,clear_effect

  jp Put_fx
  
; *****************************************************************************
; Fade in FX bump.
; *****************************************************************************
Bump_Display  

  ld hl,Banner_MoveLUT
  ld (Banner_Display + 1),hl

  ld hl,EFFECT_EXECADDR
  ld (Effect_Exec + 1),hl

  ld hl,Bump_Palette

  jp Put_palette

; *****************************************************************************
; Clear screen and unpack end logo.
; *****************************************************************************
End_Depack

  ld hl,Grey_Palette
  ld de,EndLogo_Pack
  ld bc,clear_effect

  jp Put_fx

; *****************************************************************************
; Black screen and quit.
; *****************************************************************************
End_Display

  ld a,#01
  ld (bye + 1),a

  ld hl,Black_Palette

  ld a,#07
  ld (len_fade + 1),a

  ld a,#ff
  ld (Demo_SelectPart + 1),a

  jp Put_palette

; *****************************************************************************
; DMA2 AY list buffer 2.
; *****************************************************************************
DMA2_Buffer2
  repeat 156
  dw ASIC_DMA_LOAD_10_7, ASIC_DMA_NOP_N
  rend
  dw ASIC_DMA_STOP

; *****************************************************************************
; Demo effects chaining.
; *****************************************************************************
Demo_Chaining
  dw Intro_Display
  dw Plasma_Depack
  dw Plasma_Display
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw Fire_Depack
  dw Fire_Display  
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw Metaball_Depack
  dw Metaball_Display
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw Rotozoom_Depack
  dw Rotozoom_Display
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw DefAdd_Depack
  dw DefAdd_Display
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw DefSub_Depack
  dw DefSub_Display  
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw FX_Wait
  dw Bump_Depack
  dw Bump_Display  
  dw FX_Wait
  dw FX_Wait
  dw End_Depack
  dw End_Display

; *****************************************************************************
; Initialize hard sprite 0,1,2 and 3 (Used for text banner).
; *****************************************************************************  
initialize_hardspr

  ld de,64
  ld hl,768
  ld (ASIC_ADR_SPR0_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR1_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR2_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR3_POSX),hl
  
  ld hl,130
  ld (ASIC_ADR_SPR0_POSY),hl
  ld (ASIC_ADR_SPR1_POSY),hl
  ld (ASIC_ADR_SPR2_POSY),hl
  ld (ASIC_ADR_SPR3_POSY),hl
  
  ld a,#0e
  ld (ASIC_ADR_SPR0_ZOOM),a
  ld (ASIC_ADR_SPR1_ZOOM),a
  ld (ASIC_ADR_SPR2_ZOOM),a
  ld (ASIC_ADR_SPR3_ZOOM),a
  call UKXLogo_Initialize
  ret
  
; *****************************************************************************
; Padding.
; *****************************************************************************
  align 256,0

; *****************************************************************************
; Volumes C00 LUT (&1D00).
; *****************************************************************************  
volume
  ds 256,#07

; *****************************************************************************
; Volumes C10 LUT (&1E00).
; *****************************************************************************
volume_C10
  db #04,#05,#06,#07,#07,#07,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0b

; *****************************************************************************
; Fade color to color.
; *****************************************************************************
fade_to
  ld bc,17 + 15
  ld de,ASIC_ADR_PEN0_COLOR

boucle_color
  push bc
  ld a,(de)
  and #0f
  cp (hl)
  jp z,rouge
  jp m,bleu_inc
  dec a
  jp rouge
bleu_inc
  inc a
rouge
  ld c,a
  inc hl
  ld a,(de)
  srl a
  srl a
  srl a
  srl a
  cp (hl)
  jp z,vert
  jp m,rouge_inc
  dec a
  jp vert
rouge_inc
  inc a
vert
  add a
  add a
  add a
  add a
  or c
  ld (de),a
  inc hl
  inc de
  ld a,(de)
  cp (hl)
  jp z,next_color
  jp m,vert_inc
  dec a
  jp next_color
vert_inc
  inc a
next_color
  ld (de),a
  inc hl
  inc de
  pop bc
  dec bc
  ld a,b
  or c
  jp nz,boucle_color
  jp next_fade

; *****************************************************************************
; 2D bump mapping palette (RGB).
; *****************************************************************************
Bump_Palette
  db #00,#00,#00
  db #03,#01,#00
  db #08,#02,#00
  db #0d,#03,#00
  db #0d,#04,#02
  db #0e,#04,#04
  db #0e,#04,#06
  db #0e,#04,#08
  db #0f,#05,#0a
  db #0f,#05,#0c
  db #0f,#05,#0e
  db #0c,#08,#0f
  db #0d,#0a,#0f
  db #0e,#0c,#0f
  db #0f,#0e,#0f
  db #0f,#0f,#0f
  db #00,#00,#00
  db #03,#01,#00
  db #08,#02,#00
  db #0d,#03,#00
  db #0d,#04,#02
  db #0e,#04,#04
  db #0e,#04,#06
  db #0e,#04,#08
  db #0f,#05,#0a
  db #0f,#05,#0c
  db #0f,#05,#0e
  db #0c,#08,#0f
  db #0d,#0a,#0f
  db #0e,#0c,#0f
  db #0f,#0e,#0f
  db #0f,#0f,#0f

; *****************************************************************************
; Clear and decompress next FX.
;   HL = Pointer to palette
;   DE = Pointer to FX definition (for unpack)
;   BC = Pointer to FX to execute
; *****************************************************************************
Put_fx
  ld (depack + 2),de
  ld (Effect_Exec + 1),bc

Put_palette
  ld (fade_in + 1),hl
  ld a,#10
  ld (enable_fade + 1),a

  jp Demo_Continue

; *****************************************************************************
; Text banner unpacker.
; *****************************************************************************
depack_txt
  ld hl,text_defile
  ld e,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ld (depack_txt + 1),hl

  ld hl,(depack + 2)
  push hl

  ld (depack + 2),de
  call depack

  ld hl,Init_End
  ld (Text_Exec + 1),hl

  pop hl
  ld (depack + 2),hl
  ret
  
; *****************************************************************************
; *Text banner chaining.
; *****************************************************************************
text_defile
  dw TextBanner1_Pack
  dw TextBanner2_Pack
  dw TextBanner3_Pack
  dw TextBanner4_Pack
  dw TextBanner5_Pack
  dw TextBanner6_Pack
  dw TextBanner7_Pack

; *****************************************************************************
; Volumes C20 LUT (&1F00).
; *****************************************************************************
volume_C20 ; &1F00
  db #03,#03,#04,#05,#06,#07,#07,#07,#07,#07,#08,#09,#0a,#0b,#0c,#0c
  
; *****************************************************************************
; Block clear screen.
; *****************************************************************************
clear_effect
  ld bc,#bc0c
  out (c),c
  ld bc,#bd30
  out (c),c
saveiyy
  ld iy,SCREEN_C000_Clear
  ld a,#10
boucle_carre
  ld (nbr_carre + 1),a
  ld c,#64
sync_clear
  ld b,#f5
nosync_clear
  in a,(c)
  rra
  jp nc,nosync_clear
  dec c
  jp nz,sync_clear
  ld l,(iy+#00)
  inc ly
  ld h,(iy+#00)
  inc ly
ld d,#20
boucle_y
  push hl
  ld e,#08
boucle_x
  xor a
  ld (hl),a
  inc hl
  dec e
  jp nz,boucle_x
  pop hl
  ld a,h
  add #08
  ld h,a
  jp nc,cont_clear
  ld bc,#c05f
  adc hl,bc
cont_clear
  dec d
  jp nz,boucle_y
nbr_carre
  ld a,#00
  dec a
  jp nz,boucle_carre
  ld (saveiyy + 2),iy
  ld hl,depack
  ld (Effect_Exec + 1),hl
  ret

; *****************************************************************************
; Introduction palette (RGB).
; *****************************************************************************  
Intro_Palette
  db #0f,#0f,#0f
  db #00,#00,#00
  db #02,#02,#02
  db #0a,#0f,#0f
  db #07,#08,#08
  db #0b,#0c,#0c
  db #03,#04,#03
  db #07,#0f,#0c
  db #04,#08,#05
  db #04,#0f,#08
  db #00,#0f,#05
  db #00,#0c,#01
  db #00,#02,#01
  db #00,#07,#00
  db #00,#00,#00
  db #05,#05,#05
  ds 16*3,#00
  
; *****************************************************************************
; Fade out FX meta-ball, display text banner and unpack FX Rotozoom.
; *****************************************************************************
Rotozoom_Depack

  ld hl,Banner_MoveLUT + 95
  ld (Banner_Clear + 1),hl

  ld hl,Grey_Palette
  ld de,Rotozoom_Pack
  ld bc,clear_effect

  jp Put_fx
  
; *****************************************************************************
; Fade in FX Rotozoom.
; *****************************************************************************
Rotozoom_Display

  ld hl,Banner_MoveLUT
  ld (Banner_Display + 1),hl

  ld hl,EFFECT_EXECADDR
  ld (Effect_Exec + 1),hl

  ld hl,Rotozoom_Palette

  jp Put_palette

; *****************************************************************************
; Fade out FX Rotozoom, display text banner and unpack FX deform add.
; *****************************************************************************
DefAdd_Depack

  ld hl,Banner_MoveLUT + 95
  ld (Banner_Clear + 1),hl

  ld hl,Grey_Palette
  ld de,DefAdd_Pack
  ld bc,clear_effect

  jp Put_fx

; *****************************************************************************
; Current back number.
; *****************************************************************************
bank_cur
  db #C0
  
; *****************************************************************************
; Volumes C30 LUT.
; *****************************************************************************
volume_C30
  db #00,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0d,#0d,#0d

; *****************************************************************************
; Plasma palette (RGB).
; ***************************************************************************** 
Plasma_Palette
  db #00,#00,#00,#00,#00,#00,#00,#01
  db #00,#00,#03,#00,#00,#05,#00,#00
  db #07,#00,#00,#09,#02,#00,#0b,#03
  db #01,#0d,#05,#02,#0f,#07,#03,#0f
  db #09,#05,#0f,#0b,#07,#0f,#0d,#09
  db #0f,#0f,#0b,#0f,#0f,#0e,#0f,#0f
  db #00,#00,#00,#00,#00,#00,#00,#01
  db #00,#00,#03,#00,#00,#05,#00,#00
  db #07,#00,#00,#09,#02,#00,#0b,#03
  db #01,#0d,#05,#02,#0f,#07,#03,#0f
  db #09,#05,#0f,#0b,#07,#0f,#0d,#09
  db #0f,#0f,#0b,#0f,#0f,#0e,#0f,#0f

; *****************************************************************************
; Black palette (RGB).
; *****************************************************************************
Black_Palette
  ds 32*3,#00

; *****************************************************************************
; 2sec waiting before end part.
; *****************************************************************************
  wait_2s
  ld h,#64
  ld b,#f5
nosync
  in a,(c)
  rra
  jr nc,nosync
sync
  in a,(c)
  rra
  jr c,sync
  dec h
  jr nz,nosync
  di
  call disable_sprite
  ld de,End_Pack
  ld (depack + 2),de
  call depack
  ld hl,EFFECT_EXECADDR
  ld (Effect_Exec + 1),hl
  ld bc,#bc0c
  out (c),c
  ld bc,#bd10
  out (c),c
  ret
  
; *****************************************************************************
; Volumes C40 LUT.
; *****************************************************************************
volume_C40
  db #00,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0a,#0b,#0c,#0d,#0d,#0d

; *****************************************************************************
; &8000 video memory LUT.
; *****************************************************************************
SCREEN_8000
  db #c5,#a0,#c5,#a8,#c5,#b0,#c5,#b8
  db #25,#81,#25,#89,#25,#91,#25,#99
  db #25,#a1,#25,#a9,#25,#b1,#25,#b9
  db #85,#81,#85,#89,#85,#91,#85,#99
  db #85,#a1,#85,#a9,#85,#b1,#85,#b9
  db #e5,#81,#e5,#89,#e5,#91,#e5,#99
  db #e5,#a1,#e5,#a9,#e5,#b1,#e5,#b9
  db #45,#82,#45,#8a,#45,#92,#45,#9a
  db #45,#a2,#45,#aa,#45,#b2,#45,#ba
  db #a5,#82,#a5,#8a,#a5,#92,#a5,#9a
  db #a5,#a2,#a5,#aa,#a5,#b2,#a5,#ba
  db #05,#83,#05,#8b,#05,#93,#05,#9b
  db #05,#a3,#05,#ab,#05,#b3,#05,#bb
  db #65,#83,#65,#8b,#65,#93,#65,#9b
  db #65,#a3,#65,#ab,#65,#b3,#65,#bb
  db #c5,#83,#c5,#8b,#c5,#93,#c5,#9b
  db #c5,#a3,#c5,#ab,#c5,#b3,#c5,#bb
  db #25,#84,#25,#8c,#25,#94,#25,#9c
  db #25,#a4,#25,#ac,#25,#b4,#25,#bc
  db #85,#84,#85,#8c,#85,#94,#85,#9c
  db #85,#a4,#85,#ac,#85,#b4,#85,#bc
  db #e5,#84,#e5,#8c,#e5,#94,#e5,#9c
  db #e5,#a4,#e5,#ac,#e5,#b4,#e5,#bc
  db #45,#85,#45,#8d,#45,#95,#45,#9d
  db #45,#a5,#45,#ad,#45,#b5,#45,#bd
  db #a5,#85,#a5,#8d,#a5,#95,#a5,#9d
  db #a5,#a5,#a5,#ad,#a5,#b5,#a5,#bd
  db #05,#86,#05,#8e,#05,#96,#05,#9e
  db #05,#a6,#05,#ae,#05,#b6,#05,#be
  db #65,#86,#65,#8e,#65,#96,#65,#9e
  db #65,#a6,#65,#ae,#65,#b6,#65,#be
  db #c5,#86,#c5,#8e,#c5,#96,#c5,#9e

; *****************************************************************************
; &C000 video memory LUT.
; *****************************************************************************
SCREEN_C000
  db #c5,#e0,#c5,#e8,#c5,#f0,#c5,#f8
  db #25,#c1,#25,#c9,#25,#d1,#25,#d9
  db #25,#e1,#25,#e9,#25,#f1,#25,#f9
  db #85,#c1,#85,#c9,#85,#d1,#85,#d9
  db #85,#e1,#85,#e9,#85,#f1,#85,#f9
  db #e5,#c1,#e5,#c9,#e5,#d1,#e5,#d9
  db #e5,#e1,#e5,#e9,#e5,#f1,#e5,#f9
  db #45,#c2,#45,#ca,#45,#d2,#45,#da
  db #45,#e2,#45,#ea,#45,#f2,#45,#fa
  db #a5,#c2,#a5,#ca,#a5,#d2,#a5,#da
  db #a5,#e2,#a5,#ea,#a5,#f2,#a5,#fa
  db #05,#c3,#05,#cb,#05,#d3,#05,#db
  db #05,#e3,#05,#eb,#05,#f3,#05,#fb
  db #65,#c3,#65,#cb,#65,#d3,#65,#db
  db #65,#e3,#65,#eb,#65,#f3,#65,#fb
  db #c5,#c3,#c5,#cb,#c5,#d3,#c5,#db
  db #c5,#e3,#c5,#eb,#c5,#f3,#c5,#fb
  db #25,#c4,#25,#cc,#25,#d4,#25,#dc
  db #25,#e4,#25,#ec,#25,#f4,#25,#fc
  db #85,#c4,#85,#cc,#85,#d4,#85,#dc
  db #85,#e4,#85,#ec,#85,#f4,#85,#fc
  db #e5,#c4,#e5,#cc,#e5,#d4,#e5,#dc
  db #e5,#e4,#e5,#ec,#e5,#f4,#e5,#fc
  db #45,#c5,#45,#cd,#45,#d5,#45,#dd
  db #45,#e5,#45,#ed,#45,#f5,#45,#fd
  db #a5,#c5,#a5,#cd,#a5,#d5,#a5,#dd
  db #a5,#e5,#a5,#ed,#a5,#f5,#a5,#fd
  db #05,#c6,#05,#ce,#05,#d6,#05,#de
  db #05,#e6,#05,#ee,#05,#f6,#05,#fe
  db #65,#c6,#65,#ce,#65,#d6,#65,#de
  db #65,#e6,#65,#ee,#65,#f6,#65,#fe
  db #c5,#c6,#c5,#ce,#c5,#d6,#c5,#de

; *****************************************************************************
; Parts transition palette (RGB).
; *****************************************************************************
Grey_Palette
  db #00,#00,#00,#01,#01,#01,#02,#02
  db #02,#03,#03,#03,#04,#04,#04,#05
  db #05,#05,#06,#06,#06,#07,#07,#07
  db #08,#08,#08,#09,#09,#09,#0a,#0a
  db #0a,#0b,#0b,#0b,#0c,#0c,#0c,#0d
  db #0d,#0d,#0e,#0e,#0e,#0f,#0f,#0f
  db #00,#00,#00,#01,#01,#01,#02,#02
  db #02,#03,#03,#03,#04,#04,#04,#05
  db #05,#05,#06,#06,#06,#07,#07,#07
  db #08,#08,#08,#09,#09,#09,#0a,#0a
  db #0a,#0b,#0b,#0b,#0c,#0c,#0c,#0d
  db #0d,#0d,#0e,#0e,#0e,#0f,#0f,#0f

; *****************************************************************************
; Subtract deformation palette.
; *****************************************************************************
DefSub_Palette
  db #00,#01,#00,#00,#02,#00,#00,#05
  db #00,#00,#07,#00,#01,#08,#01,#03
  db #09,#03,#04,#0a,#04,#05,#0b,#05
  db #05,#0c,#07,#04,#0c,#09,#03,#0d
  db #0a,#03,#0e,#0c,#06,#0e,#0d,#09
  db #0f,#0e,#0d,#0f,#0f,#0f,#0f,#0f
  db #00,#01,#00,#00,#02,#00,#00,#05
  db #00,#00,#07,#00,#01,#08,#01,#03
  db #09,#03,#04,#0a,#04,#05,#0b,#05
  db #05,#0c,#07,#04,#0c,#09,#03,#0d
  db #0a,#03,#0e,#0c,#06,#0e,#0d,#09
  db #0f,#0e,#0d,#0f,#0f,#0f,#0f,#0f

; *****************************************************************************
; Fade in FX deform sub.
; *****************************************************************************
DefSub_Display

  ld hl,Banner_MoveLUT
  ld (Banner_Display + 1),hl

  ld hl,EFFECT_EXECADDR
  ld (Effect_Exec + 1),hl

  ld hl,DefSub_Palette

  jp Put_palette

; *****************************************************************************
; Fade out FX deform add, display text banner and unpack FX deform sub.
; *****************************************************************************
DefSub_Depack

  ld hl,Banner_MoveLUT + 95
  ld (Banner_Clear + 1),hl

  ld hl,Grey_Palette

  ld de,DefSub_Pack

  ld bc,clear_effect

  jp Put_fx

; *****************************************************************************
; Padding.
; *****************************************************************************
  align 256,0

; *****************************************************************************
; Moving text banner LUT.
; *****************************************************************************  
Banner_MoveLUT
  db #ff,#ff,#fe,#fc,#fb,#f9,#f7,#f5
  db #f2,#f0,#ed,#e9,#e6,#e2,#de,#d9
  db #d5,#d0,#cb,#c6,#c1,#bb,#b6,#b0
  db #aa,#a4,#9e,#98,#92,#8c,#86,#7f
  db #82,#83,#85,#86,#88,#89,#8b,#8c
  db #8e,#8f,#90,#92,#93,#94,#95,#97
  db #98,#99,#9a,#9b,#9b,#9c,#9d,#9d
  db #9e,#9e,#9f,#9f,#9f,#a0,#a0,#a0
  db #a0,#a0,#9f,#9f,#9f,#9e,#9e,#9d
  db #9d,#9c,#9b,#9a,#99,#98,#97,#96
  db #95,#94,#93,#91,#90,#8f,#8d,#8c
  db #8b,#89,#88,#86,#84,#83,#81,#80
  db #81,#81,#82,#83,#84,#84,#85,#85
  db #86,#87,#87,#88,#88,#89,#8a,#8a
  db #8b,#8b,#8b,#8c,#8c,#8c,#8d,#8d
  db #8d,#8e,#8e,#8e,#8e,#8e,#8e,#8e
  db #8e,#8e,#8e,#8e,#8e,#8d,#8d,#8d
  db #8d,#8c,#8c,#8c,#8b,#8b,#8a,#8a
  db #89,#89,#88,#88,#87,#87,#86,#85
  db #85,#84,#83,#83,#82,#81,#81,#80
  db #80,#81,#81,#82,#82,#82,#83,#83
  db #83,#84,#84,#84,#85,#85,#85,#86
  db #86,#86,#86,#87,#87,#87,#87,#87
  db #87,#88,#88,#88,#88,#88,#88,#88
  db #88,#88,#88,#88,#88,#88,#87,#87
  db #87,#87,#87,#87,#86,#86,#86,#86
  db #85,#85,#85,#84,#84,#84,#83,#83
  db #83,#82,#82,#82,#81,#81,#80,#80
  db #80,#80,#80,#80,#80,#80,#80,#80
  db #80,#80,#80,#80,#80,#80,#80,#80
  db #80,#80,#80,#80,#80,#80,#80,#80
  db #80,#80,#80,#80,#80,#80,#80,#80

; *****************************************************************************
; Clear square block organization.
; *****************************************************************************
SCREEN_C000_Clear
  db #c5,#e0,#cd,#e0,#d5,#e0,#dd,#e0
  db #45,#e2,#4d,#e2,#55,#e2,#5d,#e2
  db #c5,#e3,#cd,#e3,#d5,#e3,#dd,#e3
  db #45,#e5,#4d,#e5,#55,#e5,#5d,#e5
  db #dd,#e0,#d5,#e0,#cd,#e0,#c5,#e0
  db #5d,#e2,#55,#e2,#4d,#e2,#45,#e2
  db #dd,#e3,#d5,#e3,#cd,#e3,#c5,#e3
  db #5d,#e5,#55,#e5,#4d,#e5,#45,#e5
  db #c5,#e0,#cd,#e0,#d5,#e0,#dd,#e0
  db #5d,#e2,#dd,#e3,#5d,#e5,#55,#e5
  db #4d,#e5,#45,#e5,#c5,#e3,#45,#e2
  db #4d,#e2,#55,#e2,#d5,#e3,#cd,#e3
  db #cd,#e3,#d5,#e3,#55,#e2,#4d,#e2
  db #45,#e2,#c5,#e3,#45,#e5,#4d,#e5
  db #55,#e5,#5d,#e5,#dd,#e3,#5d,#e2
  db #dd,#e0,#d5,#e0,#cd,#e0,#c5,#e0
  db #c5,#e0,#45,#e2,#c5,#e3,#45,#e5
  db #cd,#e0,#4d,#e2,#cd,#e3,#4d,#e5
  db #d5,#e0,#55,#e2,#d5,#e3,#55,#e5
  db #dd,#e0,#5d,#e2,#dd,#e3,#5d,#e5
  db #dd,#e0,#5d,#e2,#dd,#e3,#5d,#e5
  db #d5,#e0,#55,#e2,#d5,#e3,#55,#e5
  db #cd,#e0,#4d,#e2,#cd,#e3,#4d,#e5
  db #c5,#e0,#45,#e2,#c5,#e3,#45,#e5
  db #c5,#e0,#45,#e5,#4d,#e5,#45,#e2
  db #55,#e5,#d5,#e3,#55,#e2,#d5,#e0
  db #cd,#e3,#dd,#e0,#c5,#e3,#5d,#e5
  db #5d,#e2,#dd,#e3,#cd,#e0,#4d,#e2
  db #c5,#e0,#45,#e5,#4d,#e5,#45,#e2
  db #5d,#e2,#dd,#e3,#cd,#e0,#4d,#e2
  db #55,#e5,#d5,#e3,#55,#e2,#d5,#e0
  db #cd,#e3,#dd,#e0,#c5,#e3,#5d,#e5 

; *****************************************************************************
; Bitbuster V1.2 unpacker.
; *****************************************************************************  
depack
  ld ix,0
  ld bc,#bc0c
  out (c),c
page_visible
  ld bc,#bd10
  out (c),c
  ld a,(ix+#00)
  ld (bank_cur),a
  ld c,a
  ld b,#7f
  out (c),c
  ld l,(ix+#01)
  ld h,(ix+#02)
  ld c,(hl)
  inc hl
  ld b,(hl)
  inc hl
  ld (savelen + 1),bc
  inc hl
  inc hl
  ld de,#8000
  ld a,#80
  exx
  ld de,1
  exx
depack_loop
  call GET_BIT_FROM_BITSTREAM
  jr c,output_compressed
  ldi
  jr depack_loop
output_compressed
  ld c,(hl)
  inc hl
  ld b,#00
  bit 7,c
  jr z,output_match1
  call GET_BIT_FROM_BITSTREAM
  rl b
  call GET_BIT_FROM_BITSTREAM
  rl b
  call GET_BIT_FROM_BITSTREAM
  rl b
  call GET_BIT_FROM_BITSTREAM
  jr c,output_match1
  res 7,c
output_match1
  inc bc
  exx
  ld h,d
  ld l,e
  ld b,e
get_gamma_value_size
  exx
  call GET_BIT_FROM_BITSTREAM
  exx
  jr nc,get_gamma_value_size_end
  inc b
  jr get_gamma_value_size
get_gamma_value_bits
  exx
  call GET_BIT_FROM_BITSTREAM
  exx
  adc hl,hl
get_gamma_value_size_end
  djnz get_gamma_value_bits
  inc hl
  exx
  jr c,depack_end
  push hl
  exx
  push hl
  exx
  ld h,d
  ld l,e
  sbc hl,bc
  pop bc
  ldir
  pop hl
  call GET_BIT_FROM_BITSTREAM
  jr c,output_compressed
  ldi
  call GET_BIT_FROM_BITSTREAM
  jr c,output_compressed
  ldi
  jr depack_loop
GET_BIT_FROM_BITSTREAM
  add a
  ret nz
  ld a,(hl)
  inc hl
  rla
  ret
depack_end
  ld a,#c0
  ld (bank_cur),a
  ld c,a
  ld b,#7f
  out (c),c
  ld a,(ix+#03)
  or a
  jp z,depack_data
  
; Copy FX to #8000.
  ld de,EFFECT_EXECADDR
  ld hl,#8000
savelen
  ld bc,0
  ldir

; Make copy of background.  
  ld hl,#c000
  ld de,#8000
  ld bc,#4000
  ldir
  
; Stop current FX execution.
  ld hl,Init_End
  ld (Effect_Exec + 1),hl
  ret

; *****************************************************************************
; Unpack data. IX = contain archive definition.
; *****************************************************************************
depack_data
  ld a,(ix+#04)
  or a
  jp z,depack_banner

; Copy unpacked data into #4000.
  ld hl,#8000
  ld de,#4000
  ld bc,#4000
  ldir

; Stop current FX execution.
  ld hl,Init_End
  ld (Effect_Exec + 1),hl
  ret
  
; *****************************************************************************
; Unpack text banner. IX = contain archive definition.
; *****************************************************************************
depack_banner

; ASIC page-in.
  ld a,#b8
  ld (bank_cur),a
  ld c,a
  ld b,#7f
  out (c),c

; Copy unpacked text banner into hard sprite.
  ld hl,#8000
  ld de,#4000
  ld bc,#0400
  ldir

; ASIC page-out.  
  ld a,#a0
  ld (bank_cur),a
  ld c,a
  ld b,#7f
  out (c),c

; Make copy of background.  
  ld hl,#c000
  ld de,#8000
  ld bc,#4000
  ldir

  ret
  
; *****************************************************************************
; DMA player and demo manager
; *****************************************************************************
; COLUMN organization                
; Byte1 => xxxyyyyy with xxx is effect LSB and yyyyy is instrument number,
; if yyyyy> then play new note.                             
; *****************************************************************************  
Demo_Update

; Save all used registers
  exx
  push bc
  push de
  push hl
  exx
  push bc
  push de
  push hl
  push af
  ex af,af'
  push af
  ex af,af'

; Divisor use for strange VBL bug.  
divisor
  ld a,#01
  xor #01
  ld (divisor + 1),a
  jp z,fin_play
  
; ASIC page-in.
  ASIC_PAGEIN
  
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

  ld hl,ASIC_REG_DCSR
DMAON
  ld (hl),0
  
; ASIC page-out.
  ASIC_PAGEOUT

; Update speed counter.
  ld hl,Mod_SpeedDelay
  ld a,(Mod_SpeedCount)
  inc a
  ld (Mod_SpeedCount),a
  cp (hl)
  jp nz,swap0
  
; Music end ?
bye
  ld a,#00
  or a
  jp z,update_col
  
; Disable DMA channels.
  xor a
  ld (DMAON+1),a
  jp swap0

update_col

; Select bank configuration C4.
  SELECT_BANK_CONF_C4
  
; HL will contain current pattern line.
  ld hl,(pattern_line_adress)
  ld a,(hl)
  cp MOD_ENDLINEDETECT
  jp z,Update_col2

; Get effect LSB
  ld a,(hl)
  srl a
  srl a
  srl a
  srl a
  srl a
  ld (col1_effet + 1),a
  ld a,(hl)
  and #1f
  dec a
  jp m,next_byte_2_col1

; Update sample address to play.
; (sample infos are 9 bytes length).
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
  ld e,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ld (smp0_cur_adr+1),de
  ld (smp0_adr+1),de
  ld a,(hl)
  inc hl
  ld (smp0_bk+1),a

; Compute max sample address.
  ld c,(hl)
  inc hl
  ld b,(hl)
  ex de,hl
  add hl,bc
  ld (smp0_adr_max+1),hl
  ex de,hl
  exx
  
; Reset volume
  ld de,volume_C40
  ld (smp0_vol+1),de
  
next_byte_2_col1
  inc hl

; Get effect MSB
  ld a,(hl)
  srl a
  srl a
  srl a
  srl a
  and #08
  ld e,a

col1_effet
  or #00
  ld (col1_effet2+1),a

  ld a,(hl)
  and #7f
  dec a
  jp m,next_byte_3_col1
  
; Get period.  
  exx
  ld de,period
  ld h,#00
  ld l,a
  add hl,hl
  add hl,de
  ld a,(hl)
  ld (smp0_fl1+1),a
  inc hl
  ld a,(hl)
  ld (smp0_int+1),a
  exx
  xor a
  ld (smp0_fl0+1),a

  ld a,(DMAON+1)
  or ASIC_DMA_CHANNEL_0
  ld (DMAON+1),a
  
next_byte_3_col1
  inc hl
  
col1_effet2
  ld a,0
  cp MOD_EFFECT_Cxx
  jr nz,Effet_9xx

  ld a,(hl)
  exx
  ld l,a
  ld h,#00
  ld de,volume
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,de
  ld (smp0_vol+1),hl
  exx
  jr Update_col2

Effet_9xx
  cp MOD_EFFECT_9xx
  jr nz,Update_col2

  ld a,(hl)
  exx
  ld l,0
  ld h,a
smp0_adr
  ld de,0
  add hl,de
  ld (smp0_cur_adr+1),hl
  exx
  
Update_col2
  inc hl
  ld a,(hl)
  cp MOD_ENDLINEDETECT
  jp z,Update_col3
  ld a,(hl)
  srl a
  srl a
  srl a
  srl a
  srl a
  ld (col2_effet+1),a
  ld a,(hl)
  and #1f
  dec a
  jp m,next_byte_2_col2
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
  ld e,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ld (smp1_cur_adr+1),de
  ld a,(hl)
  inc hl
  ld (smp1_bk+1),a
  ld c,(hl)
  inc hl
  ld b,(hl)
  ex de,hl
  add hl,bc
  ld (smp1_adr_max+1),hl
  ex de,hl
  exx

; Reset volume
  ld de,volume_C40
  ld (smp1_vol+1),de

next_byte_2_col2
  inc hl
  ld a,(hl)
  srl a
  srl a
  srl a
  srl a
  and #08
  ld e,a

col2_effet
  or #00
  ld (col2_effet2+1),a
  ld a,(hl)
  and #7f
  dec a
  jp m,next_byte_3_col2

  exx
  ld de,period
  ld h,#00
  ld l,a
  add hl,hl
  add hl,de
  ld a,(hl)
  ld (smp1_fl1+1),a
  inc hl
  ld a,(hl)
  ld (smp1_int+1),a
  exx

  xor a
  ld (smp1_fl0+1),a

  ld a,(DMAON+1)
  or ASIC_DMA_CHANNEL_1
  ld (DMAON+1),a

next_byte_3_col2
  inc hl

col2_effet2
  ld a,0
  cp MOD_EFFECT_Exx
  jr nz,col2_Cxx
  
  ld a,(Demo_SelectPart + 1)
  inc a
  cp #2c
  jp nz,suite_col2_effet2_E
  ld a,2

suite_col2_effet2_E
  ld (Demo_SelectPart + 1),a
  jr Update_col3

col2_Cxx
  cp MOD_EFFECT_Cxx
  jr nz,Update_col3
  ld a,(hl)
  exx
  ld l,a
  ld h,0
  ld de,volume
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,de
  ld (smp1_vol+1),hl
  exx

Update_col3
  inc hl

  ld a,(hl)
  cp MOD_ENDLINEDETECT
  jp z,Update_fin

  ld a,(hl)
  srl a
  srl a
  srl a
  srl a
  srl a
  ld (col3_effet+1),a
  ld a,(hl)
  and #1f
  dec a
  jp m,next_byte_2_col3

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
  ld e,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ld (smp2_cur_adr+1),de
  ld (smp2_adr+1),de
  ld a,(hl)
  inc hl
  ld (smp2_bk+1),a

  ld c,(hl)
  inc hl
  ld b,(hl)
  ex de,hl
  add hl,bc
  ld (smp2_adr_max+1),hl
  ex de,hl
  exx

  ld de,volume_C40
  ld (smp2_vol+1),de

next_byte_2_col3
  inc hl
  ld a,(hl)
  srl a
  srl a
  srl a
  srl a
  and #08
  ld e,a

col3_effet
  or 0
  ld (col3_effet2+1),a

  ld a,(hl)
  and #7f
  dec a
  jp m,next_byte_3_col3

  exx
  ld de,period
  ld h,0
  ld l,a
  add hl,hl
  add hl,de
  ld a,(hl)
  ld (smp2_fl1+1),a
  inc hl
  ld a,(hl)
  ld (smp2_int+1),a
  exx
  xor a
  ld (smp2_fl0+1),a

  ld a,(DMAON+1)
  or ASIC_DMA_CHANNEL_2
  ld (DMAON+1),a

next_byte_3_col3
  inc hl

col3_effet2
  ld a,0
  cp MOD_EFFECT_9xx
  jr nz,col3_effet_Cxx

  ld a,(hl)
  exx
  ld l,0
  ld h,a
smp2_adr
  ld de,0
  add hl,de
  ld (smp2_cur_adr+1),hl
  exx
  jr Update_fin

col3_effet_Cxx
  cp MOD_EFFECT_Cxx
  jr nz,Update_fin
  ld a,(hl)
  exx
  ld l,a
  ld h,0
  ld de,volume
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,de
  ld (smp2_vol+1),hl
  exx

Update_fin
  inc hl

  ld a,(Mod_LineNumber)
  dec a
  jr nz,next_line

  ld h,a

  ld a,(Mod_SongIndex)
  inc a
  ld (Mod_SongIndex),a
  ld l,a
  add hl,hl
  ld de,#4024
  add hl,de
  ld e,(hl)
  inc hl
  ld d,(hl)
  ex de,hl
  ld a,#40

next_line
  ld (Mod_LineNumber),a
  ld (pattern_line_adress),hl
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
  
smp0_bk
  ld bc,#7fc5
  out (c),c
  
  exx
  ld de,(PROGDMA0+1)
smp0_vol
  ld bc,volume
smp0_adr_max
  ld hl,0
  exx

smp0_cur_adr
  ld hl,0
smp0_int
  ld bc,0
  ex af,af'
smp0_fl0
  ld a,0
  ex af,af'
smp0_fl1
  ld e,0
  call fill_buffer
  ld (smp0_cur_adr+1),hl
  exx
  ld (smp0_vol+1),bc
  exx
  
smp1_bk
  ld bc,#7fc5
  out (c),c

  exx
  ld de,(PROGDMA1+1)
smp1_vol
  ld bc,volume
smp1_adr_max
  ld hl,0
  exx

smp1_cur_adr
  ld hl,0
smp1_int
  ld bc,0
  ex af,af'
smp1_fl0
  ld a,0
  ex af,af'
.smp1_fl1
  ld e,0
  call fill_buffer
  ld (smp1_cur_adr+1),hl
  exx
  ld (smp1_vol+1),bc
  exx

smp2_bk
  ld bc,#7fc5
  out (c),c

  exx
  ld de,(PROGDMA2+1)
smp2_vol
  ld bc,volume
smp2_adr_max
  ld hl,0
  exx

smp2_cur_adr
  ld hl,0
smp2_int
  ld bc,0
  ex af,af'
smp2_fl0
  ld a,0
  ex af,af'
smp2_fl1
  ld e,0
  call fill_buffer
  ld (smp2_cur_adr+1),hl
  exx
  ld (smp2_vol+1),bc
  exx

fin_play

; Asic page-in.
  ASIC_PAGEIN

; Display text banner.
Banner_Display
  ld hl,Banner_MoveLUT + 255
  inc l
  jp z,Banner_Clear
  ld (Banner_Display + 1),hl
  ld l,(hl)
  ld h,#00
  add hl,hl
  ld bc,258
  ld de,64
  add hl,bc
  ld (ASIC_ADR_SPR0_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR1_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR2_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR3_POSX),hl
  ld hl,Banner_MoveLUT
  ld (modif_y2+1),hl
  
modif_y1
  ld hl,Banner_MoveLUT+1
  ld c,(hl)
  dec l
  jp z,Banner_Clear
  ld (modif_y1+1),hl
  
  ld l,c
  ld h,0
  ld de,-44
  ld bc,-32
  add hl,de
  ld (ASIC_ADR_SPR8_POSY),hl
  ld (ASIC_ADR_SPR9_POSY),hl
  ld (ASIC_ADR_SPR10_POSY),hl
  ld (ASIC_ADR_SPR11_POSY),hl
  add hl,bc
  ld (ASIC_ADR_SPR4_POSY),hl
  ld (ASIC_ADR_SPR5_POSY),hl
  ld (ASIC_ADR_SPR6_POSY),hl
  ld (ASIC_ADR_SPR7_POSY),hl

; Clear text banner.
Banner_Clear
  ld hl,Banner_MoveLUT+1
  dec l
  jp z,depacking_txt
  ld (Banner_Clear + 1),hl
  ld l,(hl)
  ld h,0
  add hl,hl
  ld bc,258
  ld de,64
  add hl,bc
  ld (ASIC_ADR_SPR0_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR1_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR2_POSX),hl
  add hl,de
  ld (ASIC_ADR_SPR3_POSX),hl
  ld hl,Banner_MoveLUT + 95
  ld (modif_y1+1),hl
  ld a,1
  ld (depacking_txt+1),a

; Update UKX logo position inside window.
modif_y2
  ld hl,Banner_MoveLUT+255
  ld c,(hl)
  inc l
  jp z,nbr_fade
  ld (modif_y2+1),hl
  ld a,#ff
  sub c
  ld l,a
  ld h,0
  ld de,-44
  ld bc,-32
  add hl,de
  ld (ASIC_ADR_SPR8_POSY),hl
  ld (ASIC_ADR_SPR9_POSY),hl
  ld (ASIC_ADR_SPR10_POSY),hl
  ld (ASIC_ADR_SPR11_POSY),hl
  add hl,bc
  ld (ASIC_ADR_SPR4_POSY),hl
  ld (ASIC_ADR_SPR5_POSY),hl
  ld (ASIC_ADR_SPR6_POSY),hl
  ld (ASIC_ADR_SPR7_POSY),hl
  jp nbr_fade

depacking_txt
  ld a,0
  or a
  jp z,nbr_fade
  ld hl,depack_txt
  ld (Text_Exec + 1),hl
  xor a
  ld (depacking_txt+1),a

; Fade in/out palette.
nbr_fade
  ld a,0
  inc a

len_fade
  and 0
  ld (nbr_fade+1),a
  jp nz,next_fade

enable_fade
  ld a,0
  dec a
  jp m,next_fade
  ld (enable_fade + 1),a

fade_in
  ld hl,Intro_Palette
  jp fade_to

next_fade

; Asic page-out
  ASIC_PAGEOUT

; A  = &FF => Demo_End
; A != &00 => Demo_NextPart    
Demo_SelectPart
  ld a,1
test
  cp 1
  jp z,Demo_Continue
  cp #ff
  jp z,Demo_End
  ld (test+1),a

; Select effect to execute.  
Effect_Selection
  ld hl,Demo_Chaining
  ld e,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ld (Effect_Selection + 1),hl
  ex de,hl
  jp (hl)

Demo_Continue

; Restore previous RAM bank/config number.
  ld a,(bank_cur)
  ld c,a
  ld b,#7f
  out (c),c

; Restore registers.
  ex af,af'
  pop af
  ex af,af'
  pop af
  pop hl
  pop de
  pop bc
  exx
  pop hl
  pop de
  pop bc
  exx

; Enable interrupt.  
  ei
  ret

; *****************************************************************************
; Setup UKX logo to hard sprite.
; *****************************************************************************
UKXLogo_Initialize

; Asic page-out.
  ASIC_PAGEOUT

; Select memory bank C7
  SELECT_BANK_CONF_C7

; Copy UKX logo to main RAM.  
  ld hl,#4500
  ld de,#8000
  ld bc,#0800
  ldir

; Select memory bank C0
  SELECT_BANK_CONF_C0

; Asic page-in.
  ASIC_PAGEIN

; Copy UKX logo to hardsprite 4,5,6,7,8,9,10 and 11.
  ld hl,#8000
  ld de,ASIC_ADR_SPR4
  ld bc,#0800
  ldir

; Set X position.
  ld hl,40
  ld (ASIC_ADR_SPR4_POSX),hl
  ld (ASIC_ADR_SPR8_POSX),hl
  ld hl,104
  ld (ASIC_ADR_SPR5_POSX),hl
  ld (ASIC_ADR_SPR9_POSX),hl
  ld hl,168
  ld (ASIC_ADR_SPR6_POSX),hl
  ld (ASIC_ADR_SPR10_POSX),hl
  ld hl,232
  ld (ASIC_ADR_SPR7_POSX),hl
  ld (ASIC_ADR_SPR11_POSX),hl

; Set Y position.
  ld hl,-48
  ld (ASIC_ADR_SPR4_POSY),hl
  ld (ASIC_ADR_SPR5_POSY),hl
  ld (ASIC_ADR_SPR6_POSY),hl
  ld (ASIC_ADR_SPR7_POSY),hl
  ld (ASIC_ADR_SPR8_POSY),hl
  ld (ASIC_ADR_SPR9_POSY),hl
  ld (ASIC_ADR_SPR10_POSY),hl
  ld (ASIC_ADR_SPR11_POSY),hl

; Set magnification (zoom).
  ld a,#0e
  ld (ASIC_ADR_SPR4_ZOOM),a
  ld (ASIC_ADR_SPR5_ZOOM),a
  ld (ASIC_ADR_SPR6_ZOOM),a
  ld (ASIC_ADR_SPR7_ZOOM),a
  ld (ASIC_ADR_SPR8_ZOOM),a
  ld (ASIC_ADR_SPR9_ZOOM),a
  ld (ASIC_ADR_SPR10_ZOOM),a
  ld (ASIC_ADR_SPR11_ZOOM),a
  ret

; *****************************************************************************  
; Include images.
; *****************************************************************************  
  read "./Screen/introduction.asm"
  read "./Screen/background.asm"  
