; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                            (plasma part)                                  *
; *                                                                           *
; * Code            => Power                                                  *
; *                                                                           *
; *****************************************************************************
  org &3000
  ; write direct "plasma.ukx"
  nolist
  
FX_HEIGHT equ 64

; Page flipping
  ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
  out (c),c
  inc b
reg12p  
  ld a,%00110000
  out (c),a
  dec b
  inc c
  out (c),c
  inc b
  xor a
  out (c),a

; Reinitialise la position dans les tables sin et cos
mod1a  
  ld a,0
  dec a
  dec a
  dec a
  ld (mod1a+1),a
  ld hl,cosp
  ld l,a
  ld e,(hl)
  ld hl,cosp
  ld l,a
  ld a,(hl)
  add a,e
  rra
  ld (reg_bcb+1),a
mod2a  
  ld a,0
  inc a
  inc a
  ld (mod2a+1),a
  ld (reg_deb+2),a
mod3 
  ld a,0
  inc a
  ld (mod3+1),a
  ld h,cosp/256
  ld l,a
  ld e,(hl)
  ld d,sinp1/256
  ld a,(de)
  ld (reg_deb+1),a

; Ix pointe sur la table d'adresse ecran
reg_ixp  
  ld ix,SCR8000

; Pointeur sur la table de conversion pixel - octet
  ld hl,pixelG

; Pointeur sur les tables
  exx
reg_deb 
  ld de,0
reg_hlb  
  ld hl,cosp
reg_bcb 
  ld bc,0
  exx

; Taille de l'effet
  ld a,FX_HEIGHT
bcl_pls_1  
  ld (sauve_a_pls_1+1),a
  ld e,(ix):inc ix:ld d,(ix):inc ix:ld c,(ix):inc ix:ld b,(ix):inc ix
  
repeat 26
  exx:ld l,b:inc b:ld a,(hl):ld l,e:add a,(hl):ld l,d:add a,(hl):exx:ld l,a:ld a,(hl):ld (de),a:ld (bc),a:inc e:inc c
rend
  
  exx:ld l,b:inc b:ld a,(hl):ld l,e:add a,(hl):ld l,d:add a,(hl):exx:ld l,a:ld a,(hl):ld (de),a:ld (bc),a:inc de:inc bc
  
repeat 5 
  exx:ld l,b:inc b:ld a,(hl):ld l,e:add a,(hl):ld l,d:add a,(hl):exx:ld l,a:ld a,(hl):ld (de),a:ld (bc),a:inc e:inc c
rend
  
  exx:ld b,c:inc e:exx
sauve_a_pls_1 
  ld a,0
  dec a
  jp nz,bcl_pls_1

; Flipping page affiché
  ld a,(reg12p+1)
  xor %00010000
  ld (reg12p+1),a

; Flipping page calcul courant
flipp  
  ld a,0
  xor 1
  ld (flipp+1),a
  jp nz,ECRC000p

; SCR8000
  ld hl,SCR8000
  jp flip_suitep

; SCRC000
ECRC000p
  ld hl,SCRC000
flip_suitep
  ld (reg_ixp+2),hl
    
  ret

; *****************************************************************************
; Padding
; *****************************************************************************
  align 256,0

; *****************************************************************************
; Table de conversion GDGDGDGD en GGGGDDDD
; *****************************************************************************
pixelg
  db &00,&00,&00,&00,&00,&00,&00,&00
  db &C0,&C0,&C0,&C0,&C0,&C0,&C0,&C0
  db &0C,&0C,&0C,&0C,&0C,&0C,&0C,&0C
  db &CC,&CC,&CC,&CC,&CC,&CC,&CC,&CC
  db &30,&30,&30,&30,&30,&30,&30,&30
  db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0
  db &3C,&3C,&3C,&3C,&3C,&3C,&3C,&3C
  db &FC,&FC,&FC,&FC,&FC,&FC,&FC,&FC
  db &FC,&FC,&FC,&FC,&FC,&FC,&FC,&FC
  db &3C,&3C,&3C,&3C,&3C,&3C,&3C,&3C
  db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0
  db &30,&30,&30,&30,&30,&30,&30,&30
  db &CC,&CC,&CC,&CC,&CC,&CC,&CC,&CC
  db &0C,&0C,&0C,&0C,&0C,&0C,&0C,&0C
  db &C0,&C0,&C0,&C0,&C0,&C0,&C0,&C0
  db &00,&00,&00,&00,&00,&00,&00,&00
  db &00,&00,&00,&00,&00,&00,&00,&00
  db &C0,&C0,&C0,&C0,&C0,&C0,&C0,&C0
  db &0C,&0C,&0C,&0C,&0C,&0C,&0C,&0C
  db &CC,&CC,&CC,&CC,&CC,&CC,&CC,&CC
  db &30,&30,&30,&30,&30,&30,&30,&30
  db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0
  db &3C,&3C,&3C,&3C,&3C,&3C,&3C,&3C
  db &FC,&FC,&FC,&FC,&FC,&FC,&FC,&FC
  db &FC,&FC,&FC,&FC,&FC,&FC,&FC,&FC
  db &3C,&3C,&3C,&3C,&3C,&3C,&3C,&3C
  db &F0,&F0,&F0,&F0,&F0,&F0,&F0,&F0
  db &30,&30,&30,&30,&30,&30,&30,&30
  db &CC,&CC,&CC,&CC,&CC,&CC,&CC,&CC
  db &0C,&0C,&0C,&0C,&0C,&0C,&0C,&0C
  db &C0,&C0,&C0,&C0,&C0,&C0,&C0,&C0
  db &00,&00,&00,&00,&00,&00,&00,&00
sinp1
  db #80,#84,#89,#8d,#92,#97,#9b,#9f
  db #a4,#a8,#ad,#b1,#b5,#b9,#bd,#c0
  db #c4,#c8,#cb,#ce,#d2,#d5,#d7,#da
  db #dd,#df,#e1,#e3,#e5,#e7,#e9,#ea
  db #eb,#ec,#ed,#ee,#ee,#ee,#ee,#ee
  db #ee,#ee,#ed,#ec,#eb,#ea,#e9,#e8
  db #e6,#e5,#e3,#e1,#df,#dd,#da,#d8
  db #d5,#d3,#d0,#cd,#ca,#c8,#c5,#c2
  db #bf,#bb,#b8,#b5,#b2,#af,#ac,#a8
  db #a5,#a2,#9f,#9c,#99,#96,#93,#90
  db #8d,#8a,#88,#85,#83,#80,#7e,#7c
  db #7a,#78,#76,#74,#72,#71,#6f,#6e
  db #6d,#6c,#6b,#6a,#6a,#69,#69,#68
  db #68,#68,#68,#69,#69,#69,#6a,#6a
  db #6b,#6c,#6d,#6e,#6f,#70,#71,#72
  db #74,#75,#76,#78,#79,#7b,#7c,#7e
  db #80,#81,#83,#84,#86,#87,#89,#8a
  db #8b,#8d,#8e,#8f,#90,#91,#92,#93
  db #94,#95,#95,#96,#96,#96,#97,#97
  db #97,#97,#96,#96,#95,#95,#94,#93
  db #92,#91,#90,#8e,#8d,#8b,#89,#87
  db #85,#83,#81,#7f,#7c,#7a,#77,#75
  db #72,#6f,#6c,#69,#66,#63,#60,#5d
  db #5a,#57,#53,#50,#4d,#4a,#47,#44
  db #41,#3d,#3a,#37,#35,#32,#2f,#2c
  db #2a,#27,#25,#22,#20,#1e,#1c,#1a
  db #19,#17,#16,#15,#14,#13,#12,#11
  db #11,#11,#11,#11,#11,#11,#12,#13
  db #14,#15,#16,#18,#1a,#1c,#1e,#20
  db #22,#25,#28,#2a,#2d,#31,#34,#37
  db #3b,#3f,#42,#46,#4a,#4e,#52,#57
  db #5b,#60,#64,#68,#6d,#72,#76,#7b
sinp2
  db #80,#83,#86,#89,#8c,#8f,#92,#95
  db #98,#9b,#9e,#a1,#a4,#a7,#aa,#ad
  db #b0,#b3,#b6,#b9,#bb,#be,#c1,#c3
  db #c6,#c9,#cb,#ce,#d0,#d2,#d5,#d7
  db #d9,#db,#de,#e0,#e2,#e4,#e6,#e7
  db #e9,#eb,#ec,#ee,#f0,#f1,#f2,#f4
  db #f5,#f6,#f7,#f8,#f9,#fa,#fb,#fb
  db #fc,#fd,#fd,#fe,#fe,#fe,#fe,#fe
  db #ff,#fe,#fe,#fe,#fe,#fe,#fd,#fd
  db #fc,#fb,#fb,#fa,#f9,#f8,#f7,#f6
  db #f5,#f4,#f2,#f1,#f0,#ee,#ec,#eb
  db #e9,#e7,#e6,#e4,#e2,#e0,#de,#db
  db #d9,#d7,#d5,#d2,#d0,#ce,#cb,#c9
  db #c6,#c3,#c1,#be,#bb,#b9,#b6,#b3
  db #b0,#ad,#aa,#a7,#a4,#a1,#9e,#9b
  db #98,#95,#92,#8f,#8c,#89,#86,#83
  db #80,#7c,#79,#76,#73,#70,#6d,#6a
  db #67,#64,#61,#5e,#5b,#58,#55,#52
  db #4f,#4c,#49,#46,#44,#41,#3e,#3c
  db #39,#36,#34,#31,#2f,#2d,#2a,#28
  db #26,#24,#21,#1f,#1d,#1b,#19,#18
  db #16,#14,#13,#11,#f,#e,#d,#b
  db #a,#9,#8,#7,#6,#5,#4,#4
  db #3,#2,#2,#1,#1,#1,#1,#1
  db #1,#1,#1,#1,#1,#1,#2,#2
  db #3,#4,#4,#5,#6,#7,#8,#9
  db #a,#b,#d,#e,#f,#11,#13,#14
  db #16,#18,#19,#1b,#1d,#1f,#21,#24
  db #26,#28,#2a,#2d,#2f,#31,#34,#36
  db #39,#3c,#3e,#41,#44,#46,#49,#4c
  db #4f,#52,#55,#58,#5b,#5e,#61,#64
  db #67,#6a,#6d,#70,#73,#76,#79,#7c
cosp
  db #ff,#fe,#fe,#fe,#fe,#fe,#fd,#fd
  db #fc,#fb,#fb,#fa,#f9,#f8,#f7,#f6
  db #f5,#f4,#f2,#f1,#f0,#ee,#ec,#eb
  db #e9,#e7,#e6,#e4,#e2,#e0,#de,#db
  db #d9,#d7,#d5,#d2,#d0,#ce,#cb,#c9
  db #c6,#c3,#c1,#be,#bb,#b9,#b6,#b3
  db #b0,#ad,#aa,#a7,#a4,#a1,#9e,#9b
  db #98,#95,#92,#8f,#8c,#89,#86,#83
  db #80,#7c,#79,#76,#73,#70,#6d,#6a
  db #67,#64,#61,#5e,#5b,#58,#55,#52
  db #4f,#4c,#49,#46,#44,#41,#3e,#3c
  db #39,#36,#34,#31,#2f,#2d,#2a,#28
  db #26,#24,#21,#1f,#1d,#1b,#19,#18
  db #16,#14,#13,#11,#f,#e,#d,#b
  db #a,#9,#8,#7,#6,#5,#4,#4
  db #3,#2,#2,#1,#1,#1,#1,#1
  db #1,#1,#1,#1,#1,#1,#2,#2
  db #3,#4,#4,#5,#6,#7,#8,#9
  db #a,#b,#d,#e,#f,#11,#13,#14
  db #16,#18,#19,#1b,#1d,#1f,#21,#24
  db #26,#28,#2a,#2d,#2f,#31,#34,#36
  db #39,#3c,#3e,#41,#44,#46,#49,#4c
  db #4f,#52,#55,#58,#5b,#5e,#61,#64
  db #67,#6a,#6d,#70,#73,#76,#79,#7c
  db #80,#83,#86,#89,#8c,#8f,#92,#95
  db #98,#9b,#9e,#a1,#a4,#a7,#aa,#ad
  db #b0,#b3,#b6,#b9,#bb,#be,#c1,#c3
  db #c6,#c9,#cb,#ce,#d0,#d2,#d5,#d7
  db #d9,#db,#de,#e0,#e2,#e4,#e6,#e7
  db #e9,#eb,#ec,#ee,#f0,#f1,#f2,#f4
  db #f5,#f6,#f7,#f8,#f9,#fa,#fb,#fb
  db #fc,#fd,#fd,#fe,#fe,#fe,#fe,#fe