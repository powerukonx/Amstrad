; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                         (2D Bump mapping part )                           *
; *                                                                           *
; * Code => Power                                                             *
; * Gfxs => Power                                                     *
; *                                                                           *
; *****************************************************************************
  org &3000
;  write direct "bump.ukx"
  nolist

FX_HEIGHT equ 31  
RELEASE   EQU 0 
  
; Page flipping
  ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
  out (c),c
  inc b
UpdateCRTCVideoBlock
  ld a,%00110000
  out (c),a
  dec b
  inc c
  out (c),c
  inc b
  xor a
  out (c),a

; IX point to video memory LUT
video_offset
  ld ix,SCR8000

; BC = bumpmapy
  ld bc,bumpmapy

; HL = depx/depy
Set_Move
  ld hl,depy
  
; A contain FX height.
  ld a,FX_HEIGHT
bump_loop
  ld (bump_loopend+1),a

; BC', DE', HL' and IY will point to video memory (extract from IX).
  exx
  ld a,(ix):ld iyl,a:inc ix
  ld a,(ix):ld iyh,a:inc ix
  ld l,(ix):inc ix
  ld h,(ix):inc ix
  ld e,(ix):inc ix
  ld d,(ix):inc ix
  ld c,(ix):inc ix
  ld b,(ix):inc ix
  exx

IF RELEASE

  PRINT  "RELEASING..."

  repeat 26
  ld d,0:ld a,(bc):sub (hl):and &3f:ld e,a:set 2,B:inc h:ld a,(bc):sub (hl):and &3f:ex de,hl:add hl,hl:add hl,hl:add hl,hl:add hl,hl:add hl,hl
  add hl,hl:ex de,hl:or e:ld e,a:set 6,D:res 2,b:dec h:ld a,(de):exx:ld (hl),a:inc l:ld (de),a:ld (bc),a:ld (iy),a:inc c:inc e:inc iyl:exx:inc c
  rend

  ld d,0:ld a,(bc):sub (hl):and &3f:ld e,a:set 2,B:inc h:ld a,(bc):sub (hl):and &3f:ex de,hl:add hl,hl:add hl,hl:add hl,hl:add hl,hl:add hl,hl
  add hl,hl:ex de,hl:or e:ld e,a:set 6,D:res 2,b:dec h:ld a,(de):exx:ld (hl),a:inc hl:ld (de),a:ld (bc),a:ld (iy),a:inc bc:inc de:inc iy:exx:inc c
 
  repeat 4
  ld d,0:ld a,(bc):sub (hl):and &3f:ld e,a:set 2,B:inc h:ld a,(bc):sub (hl):and &3f:ex de,hl:add hl,hl:add hl,hl:add hl,hl:add hl,hl:add hl,hl
  add hl,hl:ex de,hl:or e:ld e,a:set 6,D:res 2,b:dec h:ld a,(de):exx:ld (hl),a:inc l:ld (de),a:ld (bc),a:ld (iy),a:inc c:inc e:inc iyl:exx:inc c
  rend        

  ld d,0:ld a,(bc):sub (hl):and &3f:ld e,a:set 2,B:inc h:ld a,(bc):sub (hl):and &3f:ex de,hl:add hl,hl:add hl,hl:add hl,hl:add hl,hl:add hl,hl
  add hl,hl:ex de,hl:or e:ld e,a:set 6,D:res 2,b:dec h:ld a,(de):exx:ld (hl),a:inc l:ld (de),a:ld (bc),a:ld (iy),a:inc c:inc e:inc iyl:exx:inc bc

ELSE ; Debug 

  PRINT  "DEBUGGING..."  
  
  repeat 32        

; Compute DE (point to light map coordinate)
  ld d,0
  ld a,(bc)   ; Get nY (bumpmap[x][y+1]-bumpmap[x][y-1])
  sub (hl)    ; nY -= lighty
  and &3f     ; Clip
  ld e,a

  ex de,hl    ; Exchange DE and Hl 
  add hl,hl   ; x2
  add hl,hl   ; x4
  add hl,hl   ; x8
  add hl,hl   ; x16
  add hl,hl   ; x32
  add hl,hl   ; x64 => ny <<= 6
  ex de,hl    ; Exchange DE and Hl 
  
  set 2,B     ; BC point now to bumpmapy
  inc h       ; HL point now to depx
  
  ld a,(bc)   ; Get nX (bumpmap[x+1][y]-bumpmap[x-1][y])
  sub (hl)    ; nX -= lightx
  and &3f     ; Clip
  
  or e
  ld e,a
  set 6,D     ; DE point light map (#4000 | (nY<<6|nX)).

  res 2,b     ; BC point now to bumpmapx
  dec h       ; HL point now to depy
  
  ld a,(de)   ; Get pixel
  exx

; Save pixel to video memory
  ld (hl),a  
  ld (de),a
  ld (bc),a
  ld (iy),a
  inc hl
  inc bc
  inc de
  inc iy
  exx
  inc bc
  rend

ENDIF 
  
bump_loopend
  ld a,0
  dec a
  jp nz,bump_loop

; Toggle video memory displayed.
  ld a,(UpdateCRTCVideoBlock + 1)
  xor %00010000
  ld (UpdateCRTCVideoBlock + 1),a

; Flipping page.
Update_Flipping
  ld a,0
  xor 1
  ld (Update_Flipping + 1),a
  jp nz,ECRC000

; Set &8000 video memory.
  ld hl,SCR8000
  jp flip_suitep

; Set &C000 video memory.
ECRC000
  ld hl,SCRC000
  
; Update video memory.
flip_suitep
  ld (video_offset + 2),hl
  
; Update deplacement.
  ld a,(Set_Move + 1)
  inc a
  ld (Set_Move + 1),a
  ret

; *****************************************************************************
; Padding
; *****************************************************************************
  align #1000,0

; *****************************************************************************
; #4000 - Light map 64x64 
; (32*32 L/R pixels)
; *****************************************************************************
LUT_Light_map
  repeat 14:ds 64,#00:rend
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#C0,#C0,#C0,#C0,#C0,#C0,#C0,#C0,#C0,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#C0,#C0,#C0,#C0,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#C0,#C0,#C0,#C0,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#00,#00,#00,#C0,#C0,#C0,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#C0,#C0,#C0,#00,#00,#00,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#00,#C0,#C0,#C0,#0C,#0C,#0C,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#0C,#0C,#0C,#C0,#C0,#C0,#00,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#C0,#C0,#0C,#0C,#0C,#CC,#CC,#CC,#30,#30,#30,#30,#30,#30,#30,#30,#30,#CC,#CC,#CC,#0C,#0C,#0C,#C0,#C0,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#C0,#C0,#0C,#0C,#CC,#CC,#CC,#30,#30,#30,#30,#F0,#F0,#F0,#F0,#F0,#30,#30,#30,#30,#CC,#CC,#CC,#0C,#0C,#C0,#C0,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#C0,#C0,#0C,#0C,#CC,#CC,#30,#30,#30,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#30,#30,#30,#CC,#CC,#0C,#0C,#C0,#C0,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#C0,#C0,#0C,#0C,#CC,#CC,#30,#30,#F0,#F0,#F0,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#F0,#F0,#F0,#30,#30,#CC,#CC,#0C,#0C,#C0,#C0,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#C0,#0C,#0C,#CC,#CC,#30,#30,#F0,#F0,#3C,#3C,#3C,#FC,#FC,#FC,#FC,#FC,#FC,#FC,#3C,#3C,#3C,#F0,#F0,#30,#30,#CC,#CC,#0C,#0C,#C0,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#C0,#C0,#0C,#CC,#CC,#30,#30,#F0,#F0,#3C,#3C,#FC,#FC,#FC,#03,#03,#03,#03,#03,#FC,#FC,#FC,#3C,#3C,#F0,#F0,#30,#30,#CC,#CC,#0C,#C0,#C0,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#C0,#0C,#0C,#CC,#30,#30,#F0,#F0,#3C,#FC,#FC,#FC,#03,#03,#03,#03,#C3,#03,#03,#03,#03,#FC,#FC,#FC,#3C,#F0,#F0,#30,#30,#CC,#0C,#0C,#C0,#00,#00:ds 13,#00
  ds 14,#00:db #00,#C0,#C0,#0C,#CC,#CC,#30,#F0,#F0,#3C,#FC,#FC,#03,#03,#03,#C3,#C3,#C3,#C3,#C3,#C3,#C3,#03,#03,#03,#FC,#FC,#3C,#F0,#F0,#30,#CC,#CC,#0C,#C0,#C0,#00:ds 13,#00
  ds 14,#00:db #00,#C0,#0C,#0C,#CC,#30,#30,#F0,#3C,#3C,#FC,#03,#03,#C3,#C3,#C3,#0F,#0F,#0F,#0F,#0F,#C3,#C3,#C3,#03,#03,#FC,#3C,#3C,#F0,#30,#30,#CC,#0C,#0C,#C0,#00:ds 13,#00
  ds 14,#00:db #00,#C0,#0C,#CC,#CC,#30,#F0,#F0,#3C,#FC,#FC,#03,#C3,#C3,#0F,#0F,#0F,#CF,#CF,#CF,#0F,#0F,#0F,#C3,#C3,#03,#FC,#FC,#3C,#F0,#F0,#30,#CC,#CC,#0C,#C0,#00:ds 13,#00
  ds 14,#00:db #C0,#C0,#0C,#CC,#30,#30,#F0,#3C,#3C,#FC,#03,#03,#C3,#0F,#0F,#CF,#CF,#CF,#33,#CF,#CF,#CF,#0F,#0F,#C3,#03,#03,#FC,#3C,#3C,#F0,#30,#30,#CC,#0C,#C0,#C0:ds 13,#00
  ds 14,#00:db #C0,#0C,#0C,#CC,#30,#30,#F0,#3C,#FC,#FC,#03,#C3,#C3,#0F,#CF,#CF,#33,#33,#33,#33,#33,#CF,#CF,#0F,#C3,#C3,#03,#FC,#FC,#3C,#F0,#30,#30,#CC,#0C,#0C,#C0:ds 13,#00
  ds 14,#00:db #C0,#0C,#0C,#CC,#30,#F0,#F0,#3C,#FC,#03,#03,#C3,#0F,#0F,#CF,#33,#33,#F3,#F3,#F3,#33,#33,#CF,#0F,#0F,#C3,#03,#03,#FC,#3C,#F0,#F0,#30,#CC,#0C,#0C,#C0:ds 13,#00
  ds 14,#00:db #C0,#0C,#0C,#CC,#30,#F0,#F0,#3C,#FC,#03,#03,#C3,#0F,#CF,#CF,#33,#F3,#F3,#3F,#F3,#F3,#33,#CF,#CF,#0F,#C3,#03,#03,#FC,#3C,#F0,#F0,#30,#CC,#0C,#0C,#C0:ds 13,#00
  ds 14,#00:db #C0,#0C,#0C,#CC,#30,#F0,#F0,#3C,#FC,#03,#C3,#C3,#0F,#CF,#33,#33,#F3,#3F,#ff,#3F,#F3,#33,#33,#CF,#0F,#C3,#C3,#03,#FC,#3C,#F0,#F0,#30,#CC,#0C,#0C,#C0:ds 13,#00
  ds 14,#00:db #C0,#0C,#0C,#CC,#30,#F0,#F0,#3C,#FC,#03,#03,#C3,#0F,#CF,#CF,#33,#F3,#F3,#3F,#F3,#F3,#33,#CF,#CF,#0F,#C3,#03,#03,#FC,#3C,#F0,#F0,#30,#CC,#0C,#0C,#C0:ds 13,#00
  ds 14,#00:db #C0,#0C,#0C,#CC,#30,#F0,#F0,#3C,#FC,#03,#03,#C3,#0F,#0F,#CF,#33,#33,#F3,#F3,#F3,#33,#33,#CF,#0F,#0F,#C3,#03,#03,#FC,#3C,#F0,#F0,#30,#CC,#0C,#0C,#C0:ds 13,#00
  ds 14,#00:db #C0,#0C,#0C,#CC,#30,#30,#F0,#3C,#FC,#FC,#03,#C3,#C3,#0F,#CF,#CF,#33,#33,#33,#33,#33,#CF,#CF,#0F,#C3,#C3,#03,#FC,#FC,#3C,#F0,#30,#30,#CC,#0C,#0C,#C0:ds 13,#00
  ds 14,#00:db #C0,#C0,#0C,#CC,#30,#30,#F0,#3C,#3C,#FC,#03,#03,#C3,#0F,#0F,#CF,#CF,#CF,#33,#CF,#CF,#CF,#0F,#0F,#C3,#03,#03,#FC,#3C,#3C,#F0,#30,#30,#CC,#0C,#C0,#C0:ds 13,#00
  ds 14,#00:db #00,#C0,#0C,#CC,#CC,#30,#F0,#F0,#3C,#FC,#FC,#03,#C3,#C3,#0F,#0F,#0F,#CF,#CF,#CF,#0F,#0F,#0F,#C3,#C3,#03,#FC,#FC,#3C,#F0,#F0,#30,#CC,#CC,#0C,#C0,#00:ds 13,#00
  ds 14,#00:db #00,#C0,#0C,#0C,#CC,#30,#30,#F0,#3C,#3C,#FC,#03,#03,#C3,#C3,#C3,#0F,#0F,#0F,#0F,#0F,#C3,#C3,#C3,#03,#03,#FC,#3C,#3C,#F0,#30,#30,#CC,#0C,#0C,#C0,#00:ds 13,#00
  ds 14,#00:db #00,#C0,#C0,#0C,#CC,#CC,#30,#F0,#F0,#3C,#FC,#FC,#03,#03,#03,#C3,#C3,#C3,#C3,#C3,#C3,#C3,#03,#03,#03,#FC,#FC,#3C,#F0,#F0,#30,#CC,#CC,#0C,#C0,#C0,#00:ds 13,#00
  ds 14,#00:db #00,#00,#C0,#0C,#0C,#CC,#30,#30,#F0,#F0,#3C,#FC,#FC,#FC,#03,#03,#03,#03,#C3,#03,#03,#03,#03,#FC,#FC,#FC,#3C,#F0,#F0,#30,#30,#CC,#0C,#0C,#C0,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#C0,#C0,#0C,#CC,#CC,#30,#30,#F0,#F0,#3C,#3C,#FC,#FC,#FC,#03,#03,#03,#03,#03,#FC,#FC,#FC,#3C,#3C,#F0,#F0,#30,#30,#CC,#CC,#0C,#C0,#C0,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#C0,#0C,#0C,#CC,#CC,#30,#30,#F0,#F0,#3C,#3C,#3C,#FC,#FC,#FC,#FC,#FC,#FC,#FC,#3C,#3C,#3C,#F0,#F0,#30,#30,#CC,#CC,#0C,#0C,#C0,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#C0,#C0,#0C,#0C,#CC,#CC,#30,#30,#F0,#F0,#F0,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#F0,#F0,#F0,#30,#30,#CC,#CC,#0C,#0C,#C0,#C0,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#C0,#C0,#0C,#0C,#CC,#CC,#30,#30,#30,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#30,#30,#30,#CC,#CC,#0C,#0C,#C0,#C0,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#C0,#C0,#0C,#0C,#CC,#CC,#CC,#30,#30,#30,#30,#F0,#F0,#F0,#F0,#F0,#30,#30,#30,#30,#CC,#CC,#CC,#0C,#0C,#C0,#C0,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#C0,#C0,#0C,#0C,#0C,#CC,#CC,#CC,#30,#30,#30,#30,#30,#30,#30,#30,#30,#CC,#CC,#CC,#0C,#0C,#0C,#C0,#C0,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#00,#C0,#C0,#C0,#0C,#0C,#0C,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#CC,#0C,#0C,#0C,#C0,#C0,#C0,#00,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#00,#00,#00,#C0,#C0,#C0,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#C0,#C0,#C0,#00,#00,#00,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#C0,#C0,#C0,#C0,#0C,#0C,#0C,#0C,#0C,#0C,#0C,#C0,#C0,#C0,#C0,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00:ds 13,#00
  ds 14,#00:db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#C0,#C0,#C0,#C0,#C0,#C0,#C0,#C0,#C0,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00:ds 13,#00
  repeat 13:ds 64,#00:rend

; *****************************************************************************
; #5000 - Preparation de l'image pour le bump
; (32x32)
; *****************************************************************************
bumpmapy
  db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
  db #00,#20,#20,#20,#1F,#1F,#1E,#1E,#1D,#1C,#1B,#1B,#1B,#1C,#1C,#1B,#1A,#1A,#1A,#1B,#1D,#1E,#1E,#1E,#1F,#1F,#1F,#20,#20,#20,#20,#20
  db #00,#21,#21,#20,#20,#1E,#1D,#1C,#1B,#1A,#18,#17,#18,#1A,#1B,#19,#17,#16,#16,#19,#1C,#1D,#1D,#1D,#1D,#1E,#20,#20,#21,#21,#21,#21
  db #00,#22,#21,#21,#1F,#1D,#1B,#19,#19,#18,#17,#16,#17,#1A,#1B,#1A,#17,#15,#16,#18,#1B,#1C,#1A,#1A,#1A,#1C,#1F,#20,#21,#22,#22,#22
  db #00,#22,#22,#21,#1F,#1C,#19,#18,#1A,#1B,#1B,#1B,#1C,#1F,#20,#1E,#1C,#1B,#1B,#1D,#1F,#1D,#1A,#18,#18,#1A,#1D,#20,#21,#22,#22,#23
  db #00,#21,#21,#21,#20,#1E,#1C,#1C,#1F,#22,#23,#23,#24,#25,#25,#24,#23,#24,#25,#26,#24,#22,#1E,#1B,#19,#1A,#1D,#20,#21,#21,#22,#23
  db #00,#20,#20,#22,#23,#23,#23,#24,#27,#29,#2A,#29,#29,#28,#26,#26,#28,#2A,#2C,#2C,#29,#28,#26,#23,#20,#20,#20,#20,#20,#20,#21,#23
  db #00,#1E,#20,#23,#26,#27,#29,#29,#2B,#2B,#2B,#2A,#29,#27,#25,#25,#29,#2D,#2F,#2D,#2B,#2B,#2C,#2B,#29,#27,#24,#22,#1F,#1E,#20,#22
  db #00,#1F,#22,#25,#28,#2A,#2B,#2B,#2B,#2A,#2A,#28,#27,#24,#23,#25,#2A,#2E,#2E,#2C,#2B,#2B,#2D,#2E,#2D,#2A,#27,#24,#20,#1F,#1F,#22
  db #00,#23,#26,#28,#29,#2A,#2A,#2A,#2A,#29,#28,#27,#25,#22,#23,#27,#2C,#2E,#2D,#2B,#2A,#2A,#2D,#2E,#2E,#2B,#27,#25,#23,#22,#22,#24
  db #00,#29,#2A,#2A,#2A,#2A,#2A,#29,#29,#29,#28,#26,#24,#23,#26,#2B,#2E,#2E,#2C,#2A,#29,#2A,#2C,#2D,#2D,#2A,#26,#25,#27,#28,#29,#28
  db #00,#2C,#2B,#2B,#2A,#2A,#2A,#2A,#2A,#29,#28,#26,#24,#25,#29,#2D,#2E,#2D,#2B,#2A,#2A,#2A,#2B,#2D,#2D,#2A,#26,#26,#2A,#2E,#2F,#2D
  db #00,#2C,#2B,#2B,#2B,#2B,#2B,#2B,#2A,#2A,#2A,#28,#27,#28,#2C,#2E,#2E,#2C,#2B,#2B,#2B,#2B,#2B,#2C,#2D,#2B,#28,#29,#2D,#31,#31,#2F
  db #00,#2C,#2B,#2B,#2B,#2B,#2C,#2C,#2C,#2C,#2B,#2C,#2C,#2C,#2C,#2C,#2C,#2C,#2C,#2C,#2C,#2C,#2C,#2D,#2D,#2C,#2B,#2B,#2F,#31,#30,#2F
  db #00,#2D,#2C,#2C,#2C,#2D,#2C,#2C,#2D,#2D,#2E,#2F,#30,#2F,#2C,#2A,#2A,#2B,#2C,#2D,#2D,#2D,#2D,#2C,#2C,#2C,#2C,#2D,#2E,#2E,#2E,#2E
  db #00,#2E,#2D,#2D,#2D,#2D,#2D,#2D,#2E,#2E,#2F,#31,#32,#32,#2E,#2A,#29,#2A,#2C,#2D,#2E,#2D,#2D,#2C,#2B,#2C,#2E,#2E,#2D,#2C,#2C,#2D
  db #00,#2F,#2D,#2D,#2C,#2C,#2D,#2E,#2E,#2F,#30,#31,#33,#34,#31,#2C,#29,#2A,#2C,#2D,#2E,#2E,#2D,#2C,#2B,#2D,#31,#30,#2D,#2A,#2B,#2D
  db #00,#30,#2D,#2C,#2B,#2B,#2C,#2E,#2F,#2F,#30,#31,#33,#35,#33,#2F,#2B,#29,#2B,#2D,#2E,#2E,#2C,#2B,#2C,#30,#33,#32,#2E,#2A,#2A,#2C
  db #00,#32,#2E,#2A,#29,#2A,#2D,#30,#31,#30,#2F,#30,#31,#34,#35,#32,#2D,#2A,#2A,#2C,#2D,#2C,#2B,#2A,#2C,#31,#34,#33,#2F,#2C,#2C,#2E
  db #00,#34,#31,#2D,#2B,#2C,#30,#33,#33,#31,#2E,#2E,#2F,#31,#34,#33,#2F,#2A,#29,#29,#2B,#2A,#29,#29,#2D,#32,#34,#34,#33,#32,#31,#31
  db #00,#37,#36,#33,#31,#33,#36,#37,#34,#31,#2E,#2E,#2E,#30,#32,#32,#30,#2C,#29,#29,#2A,#2A,#2A,#2C,#30,#33,#35,#37,#38,#39,#38,#36
  db #00,#38,#3A,#3A,#3A,#3B,#3B,#39,#36,#33,#32,#32,#31,#31,#32,#33,#32,#31,#2F,#2D,#2E,#2F,#31,#34,#36,#37,#37,#39,#3C,#3C,#3A,#37
  db #00,#38,#3B,#3E,#3F,#3F,#3D,#3A,#38,#37,#38,#39,#38,#36,#36,#37,#39,#39,#38,#37,#37,#38,#3B,#3D,#3D,#3B,#39,#3A,#3B,#3B,#39,#37
  db #00,#38,#3A,#3D,#3E,#3E,#3C,#39,#39,#3B,#3E,#40,#3F,#3C,#3B,#3C,#3F,#41,#41,#3F,#3E,#3F,#40,#41,#3F,#3C,#39,#39,#39,#39,#38,#37
  db #00,#37,#39,#3A,#3B,#3B,#3A,#39,#39,#3B,#3F,#41,#41,#3E,#3D,#3E,#41,#43,#43,#41,#3F,#3F,#40,#3F,#3D,#3B,#39,#38,#38,#38,#37,#37
  db #00,#38,#38,#39,#39,#39,#38,#38,#39,#3B,#3D,#3E,#3E,#3D,#3C,#3D,#3E,#3F,#3F,#3E,#3D,#3D,#3C,#3C,#3B,#39,#38,#38,#38,#38,#38,#38
  db #00,#39,#39,#39,#39,#39,#39,#39,#39,#3A,#3B,#3B,#3B,#3B,#3A,#3B,#3C,#3C,#3C,#3B,#3B,#3A,#3A,#3A,#39,#39,#39,#39,#39,#39,#39,#39
  db #00,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A,#3A
  db #00,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B
  db #00,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C
  db #00,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D
  db #00,#28,#28,#1F,#3E,#3E,#3D,#39,#36,#30,#3E,#3E,#3C,#3E,#3D,#1E,#24,#24,#24,#24,#24,#24,#24,#24,#24,#24,#24,#24,#24,#24,#24,#24

; *****************************************************************************
; #5400 - Preparation de l'image pour le bump
; (32x32)
; *****************************************************************************
bumpmapx
  db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
  db #00,#20,#21,#22,#23,#24,#24,#25,#26,#27,#28,#29,#2B,#2C,#2D,#2D,#2E,#30,#31,#33,#34,#34,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#21,#21,#22,#23,#24,#24,#25,#25,#26,#29,#2C,#2D,#2C,#2C,#2D,#2F,#33,#35,#35,#35,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#20,#21,#21,#21,#22,#23,#24,#24,#25,#29,#2D,#2F,#2C,#29,#2A,#2F,#34,#38,#38,#35,#34,#36,#39,#3A,#3A,#3A,#3B,#3C,#3D,#3E
  db #00,#1F,#20,#1F,#1E,#1E,#20,#23,#24,#23,#24,#29,#30,#31,#2C,#27,#28,#2E,#36,#3B,#39,#34,#33,#36,#3A,#3D,#3D,#3C,#3C,#3C,#3D,#3D
  db #00,#1F,#1F,#1E,#1C,#1B,#1E,#24,#27,#25,#25,#2A,#31,#32,#2C,#25,#26,#2F,#37,#3B,#38,#31,#2F,#34,#3B,#40,#40,#3E,#3D,#3D,#3D,#3D
  db #00,#1E,#20,#1E,#1B,#1A,#1E,#26,#2A,#27,#25,#2B,#31,#31,#2B,#25,#27,#30,#38,#3A,#35,#2E,#2B,#31,#3A,#41,#42,#3F,#3D,#3E,#3E,#3B
  db #00,#1E,#21,#21,#1D,#1B,#1F,#28,#2B,#28,#25,#2A,#30,#2F,#2A,#27,#2B,#33,#39,#38,#33,#2D,#2A,#2E,#37,#40,#41,#3E,#3C,#3E,#40,#39
  db #00,#1F,#24,#24,#20,#1D,#20,#28,#2B,#28,#24,#28,#2E,#2D,#29,#2A,#30,#36,#38,#36,#33,#2E,#2C,#2E,#35,#3D,#3E,#3A,#3A,#3F,#42,#39
  db #00,#21,#27,#27,#22,#1E,#20,#28,#2B,#27,#23,#26,#2C,#2B,#2B,#2E,#34,#37,#37,#35,#33,#30,#2E,#2E,#33,#3A,#3A,#37,#37,#3E,#44,#3B
  db #00,#22,#28,#27,#22,#1E,#20,#28,#2B,#26,#22,#24,#29,#2B,#2E,#33,#36,#37,#35,#33,#32,#31,#30,#2F,#31,#36,#38,#36,#37,#3D,#44,#3F
  db #00,#21,#28,#27,#22,#1E,#20,#28,#2A,#26,#20,#22,#28,#2E,#33,#36,#37,#35,#33,#32,#32,#32,#31,#30,#30,#33,#36,#37,#3A,#40,#44,#3F
  db #00,#20,#27,#26,#21,#1E,#20,#28,#2A,#25,#1F,#20,#28,#30,#37,#38,#36,#33,#32,#32,#33,#33,#32,#30,#2F,#30,#34,#39,#3F,#42,#43,#3D
  db #00,#1F,#26,#26,#21,#1E,#20,#28,#2A,#25,#1E,#20,#28,#32,#38,#39,#36,#33,#31,#32,#33,#33,#33,#31,#2E,#2E,#33,#3B,#42,#44,#42,#3A
  db #00,#1E,#26,#26,#22,#1E,#20,#28,#2A,#25,#1F,#21,#28,#31,#37,#38,#36,#33,#32,#32,#33,#33,#33,#31,#2E,#2E,#33,#3D,#44,#44,#42,#39
  db #00,#1E,#26,#26,#22,#1E,#20,#28,#2A,#26,#20,#22,#28,#2E,#33,#37,#37,#35,#33,#32,#33,#33,#32,#31,#2E,#2E,#34,#3D,#44,#44,#42,#39
  db #00,#1D,#25,#26,#22,#1E,#21,#28,#2B,#26,#22,#24,#29,#2C,#2F,#33,#36,#36,#35,#33,#33,#32,#32,#30,#2E,#30,#36,#3C,#42,#44,#43,#3B
  db #00,#1C,#23,#25,#21,#1E,#22,#29,#2C,#27,#23,#26,#2B,#2B,#2B,#2F,#35,#37,#37,#35,#33,#32,#30,#2F,#30,#34,#37,#3A,#3E,#42,#44,#3E
  db #00,#1A,#20,#23,#21,#1F,#24,#2B,#2C,#27,#23,#27,#2D,#2C,#2A,#2B,#31,#37,#38,#36,#33,#31,#2F,#2F,#33,#37,#38,#37,#3A,#40,#45,#42
  db #00,#18,#1C,#20,#21,#22,#28,#2D,#2C,#25,#22,#28,#2F,#2F,#2A,#28,#2C,#34,#38,#38,#34,#30,#2E,#31,#37,#3B,#39,#35,#37,#3F,#45,#45
  db #00,#17,#19,#1D,#20,#25,#2B,#2D,#29,#23,#21,#28,#30,#31,#2B,#26,#28,#30,#37,#38,#34,#2F,#2E,#33,#3B,#3E,#3A,#36,#38,#3E,#44,#45
  db #00,#19,#18,#1B,#20,#27,#2C,#2B,#26,#1F,#1F,#28,#31,#32,#2D,#25,#26,#2E,#35,#38,#34,#30,#31,#37,#3E,#40,#3D,#39,#39,#3E,#42,#42
  db #00,#1B,#1B,#1D,#21,#26,#2A,#28,#23,#1E,#1F,#27,#30,#32,#2D,#26,#26,#2D,#34,#37,#35,#32,#33,#38,#3E,#40,#3D,#3A,#3B,#3D,#3F,#40
  db #00,#1E,#1E,#1F,#22,#25,#27,#26,#23,#20,#21,#28,#2E,#30,#2D,#28,#28,#2D,#33,#36,#36,#34,#36,#39,#3C,#3D,#3C,#3B,#3B,#3C,#3E,#3E
  db #00,#1F,#20,#21,#22,#24,#25,#25,#24,#23,#24,#28,#2C,#2E,#2D,#2B,#2B,#2E,#32,#34,#35,#35,#36,#37,#39,#3A,#3A,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#20,#21,#23,#24,#25,#25,#25,#26,#27,#29,#2B,#2C,#2D,#2C,#2D,#2F,#31,#33,#34,#34,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#21,#22,#23,#24,#25,#26,#26,#27,#28,#29,#2B,#2C,#2D,#2D,#2E,#2F,#31,#32,#33,#34,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#21,#22,#23,#24,#25,#26,#27,#28,#29,#2A,#2B,#2C,#2D,#2E,#2F,#30,#31,#32,#33,#34,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#21,#22,#23,#24,#25,#26,#27,#28,#29,#2A,#2B,#2C,#2D,#2E,#2F,#30,#31,#32,#33,#34,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#21,#22,#23,#24,#25,#26,#27,#28,#29,#2A,#2B,#2C,#2D,#2E,#2F,#30,#31,#32,#33,#34,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#21,#22,#23,#24,#25,#26,#27,#28,#29,#2A,#2B,#2C,#2D,#2E,#2F,#30,#31,#32,#33,#34,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E
  db #00,#20,#21,#22,#23,#24,#25,#26,#27,#28,#29,#2A,#2B,#2C,#2D,#2E,#2F,#30,#31,#32,#33,#34,#35,#36,#37,#38,#39,#3A,#3B,#3C,#3D,#3E

; *****************************************************************************
; #5800 - Spot displace LUT (y-axis).
; (256)
; *****************************************************************************
depy
  db #08,#08,#08,#08,#09,#09,#09,#0A
  db #0A,#0A,#0A,#0B,#0B,#0B,#0B,#0C
  db #0C,#0C,#0C,#0D,#0D,#0D,#0D,#0D
  db #0D,#0E,#0E,#0E,#0E,#0E,#0E,#0e
  db #0E,#0E,#0E,#0E,#0F,#0F,#0F,#0F
  db #0F,#0E,#0E,#0E,#0E,#0E,#0E,#0e
  db #0E,#0E,#0E,#0E,#0E,#0D,#0D,#0D
  db #0D,#0D,#0D,#0C,#0C,#0C,#0C,#0C
  db #0C,#0B,#0B,#0B,#0B,#0A,#0A,#0A
  db #0A,#0A,#09,#09,#09,#09,#09,#09
  db #08,#08,#08,#08,#08,#08,#07,#07
  db #07,#07,#07,#07,#07,#07,#06,#06
  db #06,#06,#06,#06,#06,#06,#06,#06
  db #06,#06,#06,#06,#06,#06,#06,#06
  db #06,#06,#06,#06,#06,#07,#07,#07
  db #07,#07,#07,#07,#07,#07,#07,#07
  db #07,#08,#08,#08,#08,#08,#08,#08
  db #08,#08,#08,#08,#09,#09,#09,#09
  db #09,#09,#09,#09,#09,#09,#09,#09
  db #09,#09,#09,#09,#09,#09,#09,#09
  db #09,#09,#09,#08,#08,#08,#08,#08
  db #08,#08,#08,#07,#07,#07,#07,#07
  db #07,#06,#06,#06,#06,#06,#06,#05
  db #05,#05,#05,#05,#04,#04,#04,#04
  db #04,#03,#03,#03,#03,#03,#02,#02
  db #02,#02,#02,#02,#01,#01,#01,#01
  db #01,#01,#01,#01,#01,#01,#01,#01
  db #00,#00,#00,#00,#00,#01,#01,#01
  db #01,#01,#01,#01,#01,#01,#01,#01
  db #02,#02,#02,#02,#02,#02,#03,#03
  db #03,#03,#04,#04,#04,#04,#05,#05
  db #05,#05,#06,#06,#06,#07,#07,#07

; *****************************************************************************
; #5900 - Spot displace LUT (x-axis).
; (256)
; *****************************************************************************
depx
  db #16,#16,#16,#17,#17,#18,#18,#18
  db #19,#19,#19,#1A,#1A,#1A,#1A,#1A
  db #1B,#1B,#1B,#1B,#1B,#1B,#1B,#1B
  db #1A,#1A,#1A,#1A,#19,#19,#19,#18
  db #18,#18,#17,#17,#16,#16,#15,#15
  db #14,#13,#13,#12,#12,#11,#11,#10
  db #10,#0F,#0E,#0E,#0D,#0D,#0D,#0C
  db #0C,#0B,#0B,#0B,#0A,#0A,#0A,#0A
  db #0A,#09,#09,#09,#09,#09,#09,#09
  db #09,#09,#0A,#0A,#0A,#0A,#0A,#0B
  db #0B,#0B,#0B,#0C,#0C,#0C,#0D,#0D
  db #0D,#0E,#0E,#0E,#0F,#0F,#0F,#0F
  db #0F,#10,#10,#10,#10,#10,#10,#10
  db #10,#10,#10,#10,#10,#10,#10,#10
  db #10,#0F,#0F,#0F,#0E,#0E,#0E,#0D
  db #0D,#0D,#0C,#0C,#0B,#0B,#0A,#0A
  db #0A,#09,#09,#08,#08,#07,#07,#07
  db #06,#06,#06,#05,#05,#05,#05,#05
  db #04,#04,#04,#04,#04,#04,#04,#04
  db #05,#05,#05,#05,#06,#06,#06,#07
  db #07,#07,#08,#08,#09,#09,#0A,#0A
  db #0B,#0C,#0C,#0D,#0D,#0E,#0E,#0F
  db #0F,#10,#11,#11,#12,#12,#12,#13
  db #13,#14,#14,#14,#15,#15,#15,#15
  db #15,#16,#16,#16,#16,#16,#16,#16
  db #16,#16,#15,#15,#15,#15,#15,#14
  db #14,#14,#14,#13,#13,#13,#12,#12
  db #12,#11,#11,#11,#10,#10,#10,#10
  db #10,#0F,#0F,#0F,#0F,#0F,#0F,#0F
  db #0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F
  db #0F,#10,#10,#10,#11,#11,#11,#12
  db #12,#12,#13,#13,#14,#14,#15,#15