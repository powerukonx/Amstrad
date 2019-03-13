; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                              (End part)                                   *
; *                                                                           *
; * Code            => Power                                                  *
; *****************************************************************************
  org &3000
  ;write"endpart.ukx"
  nolist

DMA0_Buffer_1  equ &1100
DMA0_Buffer_2  equ &1400
delock         equ 11

; *****************************************************************************
; Include some definition.
; *****************************************************************************
  read "../../define/firmware.asm"
  read "../../define/macro.asm"
  read "../../define/component.asm"

entrypoint  

; Disable interrupt
  di
  
; Beam synchronization
  ld b,PPI_PORTB/256
sync_end  
  in a,(c)
  rra
  jp nc,sync_end

; Asic page-in.
  ASIC_PAGEIN
  
; DMA Channels programming.
PROG_DMA0  
  ld de,DMA0_Buffer_1
  ld hl,ASIC_REG_SAR0
  ld (hl),e
  inc hl
  ld (hl),d
  ld hl,ASIC_REG_DCSR
  ld (hl),1
  
; Asic page-out.  
  ASIC_PAGEOUT

; DMA buffers swapping.  
dma_swap    
  ld a,0
  xor 1
  ld (dma_swap+1),a
  jr z,dma_swap_next
  ld de,DMA0_Buffer_1
  jr dma_swap_end
dma_swap_next    
  ld de,DMA0_Buffer_2
dma_swap_end  
  ld (PROG_DMA0+1),de

; Palette manager.
pal_manager    
  ld a,1
  inc a
  and 3
  ld (pal_manager+1),a
  jp nz,fill_dma
  ld hl,(ttggg+1)
gere_pal  
  ld a,0
  cp (hl)
  jp p,installe_palette_noir
  jp z,installe_palette_noir

; Installe la palette 1
  ld hl,palette_1_
  jp next_endpart
installe_palette_noir
  ld hl,palette_noir_
next_endpart

; Asic page-in.
  ASIC_PAGEIN

  call fade_to_

; Asic page-out.
  ASIC_PAGEOUT

; Fill DMA buffer.
fill_dma    
  ld hl,saw_down_
  ld de,(PROG_DMA0+1)
  ld bc,156
  exx
  ld de,volume_
ttggg    
  ld hl,offset_volume_
  inc l:inc l
  ld (ttggg+1),hl
  exx
fill_dma_loop    
  exx
  ld a,(hl)
  add a,a
  add a,a
  add a,a
  add a,a
  ld e,a
  exx
  ld a,(hl)
  exx
  add a,e
  ld e,a
  ld a,(de)
  exx
  ld (de),a
  inc de
  inc de:inc de:inc de
  inc l
  dec bc
  ld a,b
  or c
  jp nz,fill_dma_loop
  ld (fill_dma+1),hl

; Escape key test.
  ld bc,&f40e
  out (c),c
  ld bc,&f6c0
  out (c),c
  xor a
  out (c),a
  ld bc,&f792
  out (c),c
  ld bc,&f648
  out (c),c
  ld b,&f4
  in a,(c)
  ld bc,&f782
  out (c),c
  ld bc,&f600
  out (c),c
  rra:rra:rra
  jp c,entrypoint

; Asic page-in.
  ASIC_PAGEIN

; Clear hard sprite.
  ld hl,ASIC_ADR_SPR0
  ld de,ASIC_ADR_SPR0 + 1
  ld (hl),l
  ld bc,&FFF
  ldir

; Clear plus color.
  ld hl,ASIC_ADR_PEN0_COLOR
  ld de,ASIC_ADR_PEN0_COLOR + 1
  ld (hl),l
  ld bc,33
  ldir

; Stop DMA interrupt.
  xor a
  ld (ASIC_REG_PRI),a

; Stop DMA sound.
  ld (ASIC_REG_DCSR),a

; Clear AY list.
  ld (ASIC_REG_SAR0),a
  ld (ASIC_REG_SAR0 + 1),a
  ld (ASIC_REG_SAR1),a
  ld (ASIC_REG_SAR1 + 1),a
  ld (ASIC_REG_SAR2),a
  ld (ASIC_REG_SAR2 + 1),a
  
; Asic page-out.  
  ASIC_PAGEOUT

; Asic lock.
  ld e,16
  ld hl,delock
  ld bc,&bc00
sasic_2 
  ld a,(hl)
  out (c),a
  inc hl
  dec e
  jr nz,sasic_2
  ld a,52
  out (c),a

; Restore firmware.
  ld hl,routine_reset
  ld de,0
  ld bc,60
  ldir

; Bye Bye !
  jp 0

; *****************************************************************************
; Fade color to color
; *****************************************************************************
fade_to_
  ld bc,17
  ld de,&6400
boucle_color_
  push bc
  
; Blue component.
bleu_    
  ld a,(de):and &0F:cp (hl):jp z,rouge_:jp m,bleu_inc_
bleu_dec_   
  dec a:jp rouge_
bleu_inc_   
  inc a

; Red component.
rouge_     
  ld c,a:inc hl:ld a,(de):srl a:srl a:srl a:srl a:cp (hl):jp z,vert_:jp m,rouge_inc_
rouge_dec_   
  dec a:jp vert_
rouge_inc_   
  inc a

; Green component.
vert_    
  add a,a:add a,a:add a,a:add a,a:or c:ld (de),a:inc hl:inc de:ld a,(de):cp (hl):jp z,next_color_:jp m,vert_inc_
vert_dec_   
  dec a:jp next_color_
vert_inc_  
  inc a
next_color_  
  ld (de),a:inc hl:inc de
  pop bc:dec bc:ld a,b:or c:jp nz,boucle_color_
  ret

; *****************************************************************************
; Padding
; *****************************************************************************
  ds 149,0

; *****************************************************************************
; Saw down LUT
; *****************************************************************************
saw_down_
  db #0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F
  db #0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E,#0E
  db #0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D,#0D
  db #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
  db #0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B,#0B
  db #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
  db #09,#09,#09,#09,#09,#09,#09,#09,#09,#09,#09,#09,#09,#09,#09,#09
  db #08,#08,#08,#08,#08,#08,#08,#08,#08,#08,#08,#08,#08,#08,#08,#08
  db #07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07,#07
  db #06,#06,#06,#06,#06,#06,#06,#06,#06,#06,#06,#06,#06,#06,#06,#06
  db #05,#05,#05,#05,#05,#05,#05,#05,#05,#05,#05,#05,#05,#05,#05,#05
  db #04,#04,#04,#04,#04,#04,#04,#04,#04,#04,#04,#04,#04,#04,#04,#04
  db #03,#03,#03,#03,#03,#03,#03,#03,#03,#03,#03,#03,#03,#03,#03,#03
  db #02,#02,#02,#02,#02,#02,#02,#02,#02,#02,#02,#02,#02,#02,#02,#02
  db #01,#01,#01,#01,#01,#01,#01,#01,#01,#01,#01,#01,#01,#01,#01,#01
  db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

; *****************************************************************************
; *****************************************************************************
offset_volume_
  db &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
  db &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
  db &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
  db &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
  db &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
  db &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
  db &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
  db &0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0,&0
  db #1,#1,#1,#1,#1,#1,#1,#1,#2,#2,#2,#2,#2,#2,#2,#2
  db #3,#3,#3,#3,#4,#4,#4,#4,#5,#5,#6,#6,#6,#6,#7,#7
  db #8,#8,#8,#9,#9,#9,#9,#9,#a,#a,#b,#b,#b,#b,#c,#c
  db #d,#d,#d,#d,#d,#e,#e,#e,#e,#f,#f,#f,#f,#f,#f,#f
  db #f,#f,#f,#f,#f,#f,#f,#f,#e,#e,#e,#e,#e,#e,#e,#e
  db #d,#d,#d,#d,#c,#c,#c,#c,#b,#b,#a,#a,#a,#a,#9,#9
  db #8,#8,#8,#7,#7,#7,#6,#6,#5,#5,#5,#5,#5,#5,#4,#4
  db #3,#3,#3,#3,#3,#2,#2,#2,#2,#1,#1,#1,#1,#1,#1,#1

; *****************************************************************************
; *****************************************************************************
volume_
  db 07,07,07,07,07,07,07,07,07,07,07,07,07,07,07,07
  db 07,07,07,07,07,07,07,07,07,07,07,07,07,07,07,08
  db 07,07,07,07,07,07,07,07,07,07,07,07,07,07,08,09
  db 06,07,07,07,07,07,07,07,07,07,07,07,07,07,09,10
  db 06,07,07,07,07,07,07,07,07,07,07,07,07,07,08,09
  db 05,06,07,07,07,07,07,07,07,07,07,07,07,08,09,10
  db 04,05,06,07,07,07,07,07,07,07,07,07,07,08,09,10
  db 04,05,06,07,07,07,07,07,07,07,07,07,08,09,10,11
  db 03,04,05,06,07,07,07,07,07,07,07,07,08,09,10,11
  db 03,04,05,06,07,07,07,07,07,07,07,08,09,10,11,12
  db 03,03,04,05,06,07,07,07,07,07,07,08,09,10,11,12
  db 03,03,04,05,06,07,07,07,07,07,08,09,10,11,12,12
  db 02,03,03,04,05,06,07,07,07,07,08,09,10,11,12,12
  db 01,02,03,04,05,06,07,07,07,08,09,10,11,12,13,13
  db 00,01,02,03,04,05,06,07,07,08,09,10,11,12,13,13
  db 00,01,02,03,04,05,06,07,08,09,10,11,12,13,13,13

; *****************************************************************************
; GFX palette
; *****************************************************************************
palette_1_  
  db &00,&00,&00
  db &00,&02,&00
  db &00,&05,&00
  db &00,&07,&00
  db &01,&08,&01
  db &03,&09,&03
  db &04,&0A,&04
  db &05,&0B,&05
  db &05,&0C,&07
  db &04,&0C,&09
  db &03,&0D,&0A
  db &03,&0E,&0C
  db &06,&0E,&0D
  db &09,&0F,&0E
  db &0D,&0F,&0F
  db &0F,&0F,&0F
  db &00,&00,&00
  
; *****************************************************************************
; Black palette.
; *****************************************************************************  
palette_noir_
  db &00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00
  db &00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00
  db &00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00
  db &00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00
  db &00,&00,&00

; *****************************************************************************
; Firmware at &0000
; *****************************************************************************   
routine_reset  
  db  #01,#89,#7f,#ed,#49,#c3,#91,#05
  db  #c3,#8a,#b9,#c3,#84,#b9,#c5,#c9
  db  #c3,#1d,#ba,#c3,#17,#ba,#d5,#c9
  db  #c3,#c7,#b9,#c3,#b9,#b9,#e9,#00
  db  #c3,#c6,#ba,#c3,#c1,#b9,#00,#00
  db  #c3,#35,#ba,#00,#ed,#49,#d9,#fb
  db  #c7,#d9,#21,#2b,#00,#71,#18,#08
  db  #c3,#41,#b9,#c9
  db &C0