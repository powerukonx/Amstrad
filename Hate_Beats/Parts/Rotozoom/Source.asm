; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                             (rotozoom part )                              *
; *                                                                           *
; * Code            => Power                                                  *
; * Gfxs            => Ozane / Power                                          *
; *                                                                           *
; *****************************************************************************
  org &3000
  nolist

; Page flipping.
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

; IY = video memory LUT.
video_offset
  ld iy,SCR8000

; D = sine LUT.
sineidx
  ld de,SineLUT
  inc e
  ld (sineidx+1),de

; A = sine(E).
  ld a,(de)

; HL = A*32
  ld l,a
  ld h,0
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl

; BC =   
  ld bc,(aff1+1)

; DE = cosine LUT.
cosineidx
  ld de,SineLUT+64
  inc e
  ld (cosineidx+1),de

; A = cosine(E).
  ld a,(de)

; HL' = A*128
  exx
  ld h,0
  ld l,a
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl

; BC =   
  ld bc,(aff2+1)
  
; Select shadow registers.
  exx
  ex af,af'
  
; Compute rotozoom.
  ld a,32
bcl_roto
  ex af,af'

  ld (aff4+1),hl
  exx
  ld (aff3+1),hl
  exx

; IX = (IY) = screen line.
  ld e,(iy):inc iy
  ld d,(iy):inc iy
  ld ixl,e
  ld ixh,d

; Next screen line.
  inc iy:inc iy

; DE = (IY) = screen line.
  ld e,(iy):inc iy
  ld d,(iy):inc iy

; Next screen line.
  inc iy:inc iy

  repeat 88  
  add hl,bc:ld a,h:and 31:add a,sprite/256:exx:add hl,bc:ld e,h:ld d,a:ld a,(de):exx:ld (de),a:inc de:ld (ix),a:inc ix
  rend

  exx
aff1
  ld de,0
aff3
  ld hl,0
  sbc hl,de
  exx
aff2
  ld de,0
aff4
  ld hl,0
  add hl,de

  ex af,af'
  dec a
  jp nz,bcl_roto

  ex af,af'

; flipping page.

  ld a,(UpdateCRTCVideoBlock+1)
  xor %00010000
  ld (UpdateCRTCVideoBlock+1),a

flip  ld a,0
  xor 1
  ld (flip+1),a
  jp nz,ECRC000

; SCR8000

  ld hl,SCR8000
  jp flip_suite

; SCRC000
ECRC000
  ld hl,SCRC000

flip_suite

  ld (video_offset+2),hl

; Initialisation des parametres

; Initialisation de la rotation
; B = poids fort de la table sin - cos
; C = poids faible de la table - angle

  exx
ang
  ld bc,SineLUT

; On initialise xx

  ld h,0

; On precalcul xx

  ld a,c
  add a,64
  ld c,a

  ld a,(bc)
  ld l,a

; On ajuste si la valeur est negative

  bit 7,a
  jp z,cont1

  dec h

cont1
  ld de,0
  add hl,de

  ld (aff1+1),hl

; On initialise yy

  ld h,0

; On precalcul yy

  ld a,c
  add a,64
  ld c,a

  ld a,(bc)
  ld l,a

; On ajuste si la valeur est negative

  bit 7,a
  jp z,cont2

  dec h

; BC' = yy

cont2
  ld de,0
  add hl,de

  ld b,h
  ld c,l

  ld (aff2+1),bc

  exx

; Inc.  (ou dec. ) de l'angle

  ld a,(ang+1)
rotoi
  add a,-2      ; Parametre -2,-1,0,1,2
  ld (ang+1),a

; Gestion du Zoom

  exx
  ld b,SineLUT/256
modoo
  ld c,0
  ld a,(bc)
  ld h,0
  ld l,a
  bit 7,a
  jp z,cooc
  dec h
cooc
  ld l,a
  add hl,hl
  ld (cont2+1),hl
  ld a,c
zoomi
  add a,-3  ; Parametre -3 a 3
  ld (modoo+1),a
  exx

  ret

; Padding.  
  ds 125,0

; Signed sine LUT.
SineLUT
  db #00,#03,#06,#09,#0c,#10,#13,#16,#19,#1c,#1f,#22,#25,#28,#2b,#2e
  db #31,#33,#36,#39,#3c,#3f,#41,#44,#47,#49,#4c,#4e,#51,#53,#55,#58
  db #5a,#5c,#5e,#60,#62,#64,#66,#68,#6a,#6b,#6d,#6f,#70,#71,#73,#74
  db #75,#76,#78,#79,#7a,#7a,#7b,#7c,#7d,#7d,#7e,#7e,#7e,#7f,#7f,#7f
  db #7f,#7f,#7f,#7f,#7e,#7e,#7e,#7d,#7d,#7c,#7b,#7a,#7a,#79,#78,#76
  db #75,#74,#73,#71,#70,#6f,#6d,#6b,#6a,#68,#66,#64,#62,#60,#5e,#5c
  db #5a,#58,#55,#53,#51,#4e,#4c,#49,#47,#44,#41,#3f,#3c,#39,#36,#33
  db #31,#2e,#2b,#28,#25,#22,#1f,#1c,#19,#16,#13,#10,#0c,#09,#06,#03
  db #00,#fd,#fa,#f7,#f4,#f0,#ed,#ea,#e7,#e4,#e1,#de,#db,#d8,#d5,#d2
  db #cf,#cd,#ca,#c7,#c4,#c1,#bf,#bc,#b9,#b7,#b4,#b2,#af,#ad,#ab,#a8
  db #a6,#a4,#a2,#a0,#9e,#9c,#9a,#98,#96,#95,#93,#91,#90,#8f,#8d,#8c
  db #8b,#8a,#88,#87,#86,#86,#85,#84,#83,#83,#82,#82,#82,#81,#81,#81
  db #81,#81,#81,#81,#82,#82,#82,#83,#83,#84,#85,#86,#86,#87,#88,#8a
  db #8b,#8c,#8d,#8f,#90,#91,#93,#95,#96,#98,#9a,#9c,#9e,#a0,#a2,#a4
  db #a6,#a8,#ab,#ad,#af,#b2,#b4,#b7,#b9,#bc,#bf,#c1,#c4,#c7,#ca,#cd
  db #cf,#d2,#d5,#d8,#db,#de,#e1,#e4,#e7,#ea,#ed,#f0,#f4,#f7,#fa,#fd

; Adresse du sprite.
; Sprite/Logo (each line is 256 bytes length).
sprite
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#f,#fc,#0,#0,#0,#c,#fc
  db  #fc,#cf,#f,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#f3,#c3
  db  #fc,#fc,#c0,#0,#0,#0,#fc,#3f
  db  #c,#0,#0,#0,#0,#0,#0,#fc
  db  #30,#0,#c0,#f3,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#f,#fc,#0,#0,#0,#c,#fc
  db  #fc,#cf,#f,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#f3,#c3
  db  #fc,#fc,#c0,#0,#0,#0,#fc,#3f
  db  #c,#0,#0,#0,#0,#0,#0,#fc
  db  #30,#0,#c0,#f3,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#f,#fc,#0,#0,#0,#c,#fc
  db  #fc,#cf,#f,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#f3,#c3
  db  #fc,#fc,#c0,#0,#0,#0,#fc,#3f
  db  #c,#0,#0,#0,#0,#0,#0,#fc
  db  #30,#0,#c0,#f3,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#f,#fc,#0,#0,#0,#c,#fc
  db  #fc,#cf,#f,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#f3,#c3
  db  #fc,#fc,#c0,#0,#0,#0,#fc,#3f
  db  #c,#0,#0,#0,#0,#0,#0,#fc
  db  #30,#0,#c0,#f3,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#cf,#ff,#f3,#3c,#f3,#ff,#ff
  db  #ff,#ff,#fc,#0,#0,#3c,#3f,#ff
  db  #f,#0,#0,#0,#0,#0,#cc,#cf
  db  #ff,#ff,#cf,#30,#0,#0,#f3,#ff
  db  #ff,#ff,#ff,#3,#0,#f0,#ff,#ff
  db  #3,#0,#0,#0,#0,#f0,#33,#ff
  db  #3c,#0,#c,#3f,#ff,#ff,#f0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#cf,#ff,#f3,#3c,#f3,#ff,#ff
  db  #ff,#ff,#fc,#0,#0,#3c,#3f,#ff
  db  #f,#0,#0,#0,#0,#0,#cc,#cf
  db  #ff,#ff,#cf,#30,#0,#0,#f3,#ff
  db  #ff,#ff,#ff,#3,#0,#f0,#ff,#ff
  db  #3,#0,#0,#0,#0,#f0,#33,#ff
  db  #3c,#0,#c,#3f,#ff,#ff,#f0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#cf,#ff,#f3,#3c,#f3,#ff,#ff
  db  #ff,#ff,#fc,#0,#0,#3c,#3f,#ff
  db  #f,#0,#0,#0,#0,#0,#cc,#cf
  db  #ff,#ff,#cf,#30,#0,#0,#f3,#ff
  db  #ff,#ff,#ff,#3,#0,#f0,#ff,#ff
  db  #3,#0,#0,#0,#0,#f0,#33,#ff
  db  #3c,#0,#c,#3f,#ff,#ff,#f0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#cf,#ff,#f3,#3c,#f3,#ff,#ff
  db  #ff,#ff,#fc,#0,#0,#3c,#3f,#ff
  db  #f,#0,#0,#0,#0,#0,#cc,#cf
  db  #ff,#ff,#cf,#30,#0,#0,#f3,#ff
  db  #ff,#ff,#ff,#3,#0,#f0,#ff,#ff
  db  #3,#0,#0,#0,#0,#f0,#33,#ff
  db  #3c,#0,#c,#3f,#ff,#ff,#f0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#cf,#ff,#ff,#ff,#3c,#33,#ff
  db  #ff,#ff,#f0,#0,#fc,#ff,#ff,#ff
  db  #ff,#3,#0,#0,#0,#cc,#3f,#ff
  db  #ff,#ff,#ff,#ff,#3c,#0,#0,#cf
  db  #ff,#ff,#ff,#f0,#c0,#f3,#ff,#ff
  db  #33,#0,#0,#fc,#33,#ff,#ff,#ff
  db  #fc,#0,#0,#cf,#ff,#ff,#c,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#cf,#ff,#ff,#ff,#3c,#33,#ff
  db  #ff,#ff,#f0,#0,#fc,#ff,#ff,#ff
  db  #ff,#3,#0,#0,#0,#cc,#3f,#ff
  db  #ff,#ff,#ff,#ff,#3c,#0,#0,#cf
  db  #ff,#ff,#ff,#f0,#c0,#f3,#ff,#ff
  db  #33,#0,#0,#fc,#33,#ff,#ff,#ff
  db  #fc,#0,#0,#cf,#ff,#ff,#c,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#cf,#ff,#ff,#ff,#3c,#33,#ff
  db  #ff,#ff,#f0,#0,#fc,#ff,#ff,#ff
  db  #ff,#3,#0,#0,#0,#cc,#3f,#ff
  db  #ff,#ff,#ff,#ff,#3c,#0,#0,#cf
  db  #ff,#ff,#ff,#f0,#c0,#f3,#ff,#ff
  db  #33,#0,#0,#fc,#33,#ff,#ff,#ff
  db  #fc,#0,#0,#cf,#ff,#ff,#c,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#cf,#ff,#ff,#ff,#3c,#33,#ff
  db  #ff,#ff,#f0,#0,#fc,#ff,#ff,#ff
  db  #ff,#3,#0,#0,#0,#cc,#3f,#ff
  db  #ff,#ff,#ff,#ff,#3c,#0,#0,#cf
  db  #ff,#ff,#ff,#f0,#c0,#f3,#ff,#ff
  db  #33,#0,#0,#fc,#33,#ff,#ff,#ff
  db  #fc,#0,#0,#cf,#ff,#ff,#c,#0
  db  #0,#0,#f,#ff,#ff,#ff,#ff,#fc
  db  #0,#f3,#ff,#ff,#0,#0,#3c,#ff
  db  #ff,#ff,#c,#c,#ff,#ff,#f0,#30
  db  #ff,#ff,#c0,#0,#0,#f3,#ff,#ff
  db  #ff,#ff,#ff,#ff,#3f,#c0,#0,#3c
  db  #ff,#ff,#ff,#c,#fc,#ff,#ff,#ff
  db  #3f,#0,#f3,#ff,#ff,#ff,#ff,#30
  db  #0,#0,#c0,#3f,#ff,#fc,#0,#0
  db  #0,#0,#f,#ff,#ff,#ff,#ff,#fc
  db  #0,#f3,#ff,#ff,#0,#0,#3c,#ff
  db  #ff,#ff,#c,#c,#ff,#ff,#f0,#30
  db  #ff,#ff,#c0,#0,#0,#f3,#ff,#ff
  db  #ff,#ff,#ff,#ff,#3f,#c0,#0,#3c
  db  #ff,#ff,#ff,#c,#fc,#ff,#ff,#ff
  db  #3f,#0,#f3,#ff,#ff,#ff,#ff,#30
  db  #0,#0,#c0,#3f,#ff,#fc,#0,#0
  db  #0,#0,#f,#ff,#ff,#ff,#ff,#fc
  db  #0,#f3,#ff,#ff,#0,#0,#3c,#ff
  db  #ff,#ff,#c,#c,#ff,#ff,#f0,#30
  db  #ff,#ff,#c0,#0,#0,#f3,#ff,#ff
  db  #ff,#ff,#ff,#ff,#3f,#c0,#0,#3c
  db  #ff,#ff,#ff,#c,#fc,#ff,#ff,#ff
  db  #3f,#0,#f3,#ff,#ff,#ff,#ff,#30
  db  #0,#0,#c0,#3f,#ff,#fc,#0,#0
  db  #0,#0,#f,#ff,#ff,#ff,#ff,#fc
  db  #0,#f3,#ff,#ff,#0,#0,#3c,#ff
  db  #ff,#ff,#c,#c,#ff,#ff,#f0,#30
  db  #ff,#ff,#c0,#0,#0,#f3,#ff,#ff
  db  #ff,#ff,#ff,#ff,#3f,#c0,#0,#3c
  db  #ff,#ff,#ff,#c,#fc,#ff,#ff,#ff
  db  #3f,#0,#f3,#ff,#ff,#ff,#ff,#30
  db  #0,#0,#c0,#3f,#ff,#fc,#0,#0
  db  #0,#0,#3f,#ff,#ff,#ff,#ff,#c0
  db  #0,#f3,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#ff,#0,#3,#ff,#3c,#3c,#ff
  db  #ff,#ff,#f0,#0,#3c,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#fc,#0,#3c
  db  #ff,#ff,#3f,#0,#f3,#ff,#ff,#ff
  db  #ff,#0,#30,#c,#3f,#ff,#ff,#3
  db  #0,#0,#3c,#ff,#3f,#c0,#0,#0
  db  #0,#0,#3f,#ff,#ff,#ff,#ff,#c0
  db  #0,#f3,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#ff,#0,#3,#ff,#3c,#3c,#ff
  db  #ff,#ff,#f0,#0,#3c,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#fc,#0,#3c
  db  #ff,#ff,#3f,#0,#f3,#ff,#ff,#ff
  db  #ff,#0,#30,#c,#3f,#ff,#ff,#3
  db  #0,#0,#3c,#ff,#3f,#c0,#0,#0
  db  #0,#0,#3f,#ff,#ff,#ff,#ff,#c0
  db  #0,#f3,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#ff,#0,#3,#ff,#3c,#3c,#ff
  db  #ff,#ff,#f0,#0,#3c,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#fc,#0,#3c
  db  #ff,#ff,#3f,#0,#f3,#ff,#ff,#ff
  db  #ff,#0,#30,#c,#3f,#ff,#ff,#3
  db  #0,#0,#3c,#ff,#3f,#c0,#0,#0
  db  #0,#0,#3f,#ff,#ff,#ff,#ff,#c0
  db  #0,#f3,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#ff,#0,#3,#ff,#3c,#3c,#ff
  db  #ff,#ff,#f0,#0,#3c,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#fc,#0,#3c
  db  #ff,#ff,#3f,#0,#f3,#ff,#ff,#ff
  db  #ff,#0,#30,#c,#3f,#ff,#ff,#3
  db  #0,#0,#3c,#ff,#3f,#c0,#0,#0
  db  #0,#0,#0,#0,#c3,#ff,#33,#0
  db  #0,#f3,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#f3,#0,#3f,#cf,#c0,#3f,#ff
  db  #ff,#ff,#3,#0,#33,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#c3,#0,#3c
  db  #ff,#ff,#33,#cc,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#fc,#ff,#ff,#3f
  db  #0,#0,#f3,#ff,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#c3,#ff,#33,#0
  db  #0,#f3,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#f3,#0,#3f,#cf,#c0,#3f,#ff
  db  #ff,#ff,#3,#0,#33,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#c3,#0,#3c
  db  #ff,#ff,#33,#cc,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#fc,#ff,#ff,#3f
  db  #0,#0,#f3,#ff,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#c3,#ff,#33,#0
  db  #0,#f3,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#f3,#0,#3f,#cf,#c0,#3f,#ff
  db  #ff,#ff,#3,#0,#33,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#c3,#0,#3c
  db  #ff,#ff,#33,#cc,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#fc,#ff,#ff,#3f
  db  #0,#0,#f3,#ff,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#c3,#ff,#33,#0
  db  #0,#f3,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#f3,#0,#3f,#cf,#c0,#3f,#ff
  db  #ff,#ff,#3,#0,#33,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#c3,#0,#3c
  db  #ff,#ff,#33,#cc,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#fc,#ff,#ff,#3f
  db  #0,#0,#f3,#ff,#fc,#0,#0,#0
  db  #0,#0,#0,#c,#ff,#ff,#fc,#0
  db  #0,#ff,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#33,#cc,#ff,#f0,#3c,#ff,#ff
  db  #ff,#ff,#c3,#cc,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#cf,#0,#3c
  db  #ff,#ff,#cf,#3,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#c0,#3f,#ff,#ff
  db  #f0,#30,#ff,#f3,#0,#0,#0,#0
  db  #0,#0,#0,#c,#ff,#ff,#fc,#0
  db  #0,#ff,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#33,#cc,#ff,#f0,#3c,#ff,#ff
  db  #ff,#ff,#c3,#cc,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#cf,#0,#3c
  db  #ff,#ff,#cf,#3,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#c0,#3f,#ff,#ff
  db  #f0,#30,#ff,#f3,#0,#0,#0,#0
  db  #0,#0,#0,#c,#ff,#ff,#fc,#0
  db  #0,#ff,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#33,#cc,#ff,#f0,#3c,#ff,#ff
  db  #ff,#ff,#c3,#cc,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#cf,#0,#3c
  db  #ff,#ff,#cf,#3,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#c0,#3f,#ff,#ff
  db  #f0,#30,#ff,#f3,#0,#0,#0,#0
  db  #0,#0,#0,#c,#ff,#ff,#fc,#0
  db  #0,#ff,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#33,#cc,#ff,#f0,#3c,#ff,#ff
  db  #ff,#ff,#c3,#cc,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#ff,#cf,#0,#3c
  db  #ff,#ff,#cf,#3,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#c0,#3f,#ff,#ff
  db  #f0,#30,#ff,#f3,#0,#0,#0,#0
  db  #0,#0,#0,#fc,#ff,#ff,#cc,#0
  db  #c0,#ff,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#cf,#3,#3f,#0,#fc,#ff,#ff
  db  #ff,#ff,#fc,#fc,#ff,#ff,#cf,#cc
  db  #0,#cc,#33,#ff,#ff,#f3,#0,#3c
  db  #ff,#ff,#f,#33,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#0,#3,#ff,#ff
  db  #3,#cf,#ff,#3c,#0,#0,#0,#0
  db  #0,#0,#0,#fc,#ff,#ff,#cc,#0
  db  #c0,#ff,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#cf,#3,#3f,#0,#fc,#ff,#ff
  db  #ff,#ff,#fc,#fc,#ff,#ff,#cf,#cc
  db  #0,#cc,#33,#ff,#ff,#f3,#0,#3c
  db  #ff,#ff,#f,#33,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#0,#3,#ff,#ff
  db  #3,#cf,#ff,#3c,#0,#0,#0,#0
  db  #0,#0,#0,#fc,#ff,#ff,#cc,#0
  db  #c0,#ff,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#cf,#3,#3f,#0,#fc,#ff,#ff
  db  #ff,#ff,#fc,#fc,#ff,#ff,#cf,#cc
  db  #0,#cc,#33,#ff,#ff,#f3,#0,#3c
  db  #ff,#ff,#f,#33,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#0,#3,#ff,#ff
  db  #3,#cf,#ff,#3c,#0,#0,#0,#0
  db  #0,#0,#0,#fc,#ff,#ff,#cc,#0
  db  #c0,#ff,#ff,#f3,#0,#0,#3c,#ff
  db  #ff,#cf,#3,#3f,#0,#fc,#ff,#ff
  db  #ff,#ff,#fc,#fc,#ff,#ff,#cf,#cc
  db  #0,#cc,#33,#ff,#ff,#f3,#0,#3c
  db  #ff,#ff,#f,#33,#ff,#ff,#ff,#ff
  db  #ff,#c,#0,#0,#0,#3,#ff,#ff
  db  #3,#cf,#ff,#3c,#0,#0,#0,#0
  db  #0,#0,#0,#f3,#ff,#3f,#0,#0
  db  #cc,#ff,#ff,#f3,#0,#0,#30,#ff
  db  #ff,#cf,#33,#3,#0,#fc,#ff,#ff
  db  #ff,#f3,#c0,#c3,#ff,#33,#0,#0
  db  #0,#0,#c0,#f3,#ff,#f3,#0,#3c
  db  #ff,#ff,#c3,#ff,#3,#fc,#ff,#ff
  db  #ff,#c,#0,#0,#0,#30,#ff,#ff
  db  #ff,#ff,#f3,#0,#0,#0,#0,#0
  db  #0,#0,#0,#f3,#ff,#3f,#0,#0
  db  #cc,#ff,#ff,#f3,#0,#0,#30,#ff
  db  #ff,#cf,#33,#3,#0,#fc,#ff,#ff
  db  #ff,#f3,#c0,#c3,#ff,#33,#0,#0
  db  #0,#0,#c0,#f3,#ff,#f3,#0,#3c
  db  #ff,#ff,#c3,#ff,#3,#fc,#ff,#ff
  db  #ff,#c,#0,#0,#0,#30,#ff,#ff
  db  #ff,#ff,#f3,#0,#0,#0,#0,#0
  db  #0,#0,#0,#f3,#ff,#3f,#0,#0
  db  #cc,#ff,#ff,#f3,#0,#0,#30,#ff
  db  #ff,#cf,#33,#3,#0,#fc,#ff,#ff
  db  #ff,#f3,#c0,#c3,#ff,#33,#0,#0
  db  #0,#0,#c0,#f3,#ff,#f3,#0,#3c
  db  #ff,#ff,#c3,#ff,#3,#fc,#ff,#ff
  db  #ff,#c,#0,#0,#0,#30,#ff,#ff
  db  #ff,#ff,#f3,#0,#0,#0,#0,#0
  db  #0,#0,#0,#f3,#ff,#3f,#0,#0
  db  #cc,#ff,#ff,#f3,#0,#0,#30,#ff
  db  #ff,#cf,#33,#3,#0,#fc,#ff,#ff
  db  #ff,#f3,#c0,#c3,#ff,#33,#0,#0
  db  #0,#0,#c0,#f3,#ff,#f3,#0,#3c
  db  #ff,#ff,#c3,#ff,#3,#fc,#ff,#ff
  db  #ff,#c,#0,#0,#0,#30,#ff,#ff
  db  #ff,#ff,#f3,#0,#0,#0,#0,#0
  db  #0,#0,#cc,#ff,#ff,#f,#0,#0
  db  #30,#ff,#ff,#33,#0,#0,#30,#ff
  db  #ff,#cf,#3f,#f0,#0,#c,#f3,#ff
  db  #f,#c,#0,#cf,#ff,#c,#0,#0
  db  #0,#0,#0,#f0,#ff,#cf,#0,#3c
  db  #ff,#ff,#33,#ff,#c0,#30,#ff,#ff
  db  #ff,#c,#0,#0,#0,#0,#3f,#ff
  db  #ff,#ff,#3c,#0,#0,#0,#0,#0
  db  #0,#0,#cc,#ff,#ff,#f,#0,#0
  db  #30,#ff,#ff,#33,#0,#0,#30,#ff
  db  #ff,#cf,#3f,#f0,#0,#c,#f3,#ff
  db  #f,#c,#0,#cf,#ff,#c,#0,#0
  db  #0,#0,#0,#f0,#ff,#cf,#0,#3c
  db  #ff,#ff,#33,#ff,#c0,#30,#ff,#ff
  db  #ff,#c,#0,#0,#0,#0,#3f,#ff
  db  #ff,#ff,#3c,#0,#0,#0,#0,#0
  db  #0,#0,#cc,#ff,#ff,#f,#0,#0
  db  #30,#ff,#ff,#33,#0,#0,#30,#ff
  db  #ff,#cf,#3f,#f0,#0,#c,#f3,#ff
  db  #f,#c,#0,#cf,#ff,#c,#0,#0
  db  #0,#0,#0,#f0,#ff,#cf,#0,#3c
  db  #ff,#ff,#33,#ff,#c0,#30,#ff,#ff
  db  #ff,#c,#0,#0,#0,#0,#3f,#ff
  db  #ff,#ff,#3c,#0,#0,#0,#0,#0
  db  #0,#0,#cc,#ff,#ff,#f,#0,#0
  db  #30,#ff,#ff,#33,#0,#0,#30,#ff
  db  #ff,#cf,#3f,#f0,#0,#c,#f3,#ff
  db  #f,#c,#0,#cf,#ff,#c,#0,#0
  db  #0,#0,#0,#f0,#ff,#cf,#0,#3c
  db  #ff,#ff,#33,#ff,#c0,#30,#ff,#ff
  db  #ff,#c,#0,#0,#0,#0,#3f,#ff
  db  #ff,#ff,#3c,#0,#0,#0,#0,#0
  db  #0,#0,#3,#ff,#ff,#3,#0,#0
  db  #3c,#ff,#ff,#cf,#0,#0,#cc,#ff
  db  #ff,#3f,#ff,#c0,#0,#0,#0,#0
  db  #0,#0,#0,#f3,#f,#0,#0,#0
  db  #0,#0,#0,#c0,#ff,#f,#0,#3c
  db  #ff,#ff,#3f,#f,#0,#c,#ff,#ff
  db  #ff,#0,#0,#0,#0,#0,#3,#ff
  db  #ff,#3f,#0,#0,#0,#0,#0,#0
  db  #0,#0,#3,#ff,#ff,#3,#0,#0
  db  #3c,#ff,#ff,#cf,#0,#0,#cc,#ff
  db  #ff,#3f,#ff,#c0,#0,#0,#0,#0
  db  #0,#0,#0,#f3,#f,#0,#0,#0
  db  #0,#0,#0,#c0,#ff,#f,#0,#3c
  db  #ff,#ff,#3f,#f,#0,#c,#ff,#ff
  db  #ff,#0,#0,#0,#0,#0,#3,#ff
  db  #ff,#3f,#0,#0,#0,#0,#0,#0
  db  #0,#0,#3,#ff,#ff,#3,#0,#0
  db  #3c,#ff,#ff,#cf,#0,#0,#cc,#ff
  db  #ff,#3f,#ff,#c0,#0,#0,#0,#0
  db  #0,#0,#0,#f3,#f,#0,#0,#0
  db  #0,#0,#0,#c0,#ff,#f,#0,#3c
  db  #ff,#ff,#3f,#f,#0,#c,#ff,#ff
  db  #ff,#0,#0,#0,#0,#0,#3,#ff
  db  #ff,#3f,#0,#0,#0,#0,#0,#0
  db  #0,#0,#3,#ff,#ff,#3,#0,#0
  db  #3c,#ff,#ff,#cf,#0,#0,#cc,#ff
  db  #ff,#3f,#ff,#c0,#0,#0,#0,#0
  db  #0,#0,#0,#f3,#f,#0,#0,#0
  db  #0,#0,#0,#c0,#ff,#f,#0,#3c
  db  #ff,#ff,#3f,#f,#0,#c,#ff,#ff
  db  #ff,#0,#0,#0,#0,#0,#3,#ff
  db  #ff,#3f,#0,#0,#0,#0,#0,#0
  db  #0,#0,#33,#ff,#ff,#f0,#0,#0
  db  #3,#ff,#ff,#cf,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#ff,#3f,#3c,#0,#0
  db  #0,#0,#0,#3f,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#f3,#3,#0,#3c
  db  #ff,#ff,#ff,#fc,#0,#0,#ff,#ff
  db  #3f,#0,#0,#0,#0,#0,#30,#ff
  db  #ff,#ff,#cc,#0,#0,#0,#0,#0
  db  #0,#0,#33,#ff,#ff,#f0,#0,#0
  db  #3,#ff,#ff,#cf,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#ff,#3f,#3c,#0,#0
  db  #0,#0,#0,#3f,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#f3,#3,#0,#3c
  db  #ff,#ff,#ff,#fc,#0,#0,#ff,#ff
  db  #3f,#0,#0,#0,#0,#0,#30,#ff
  db  #ff,#ff,#cc,#0,#0,#0,#0,#0
  db  #0,#0,#33,#ff,#ff,#f0,#0,#0
  db  #3,#ff,#ff,#cf,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#ff,#3f,#3c,#0,#0
  db  #0,#0,#0,#3f,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#f3,#3,#0,#3c
  db  #ff,#ff,#ff,#fc,#0,#0,#ff,#ff
  db  #3f,#0,#0,#0,#0,#0,#30,#ff
  db  #ff,#ff,#cc,#0,#0,#0,#0,#0
  db  #0,#0,#33,#ff,#ff,#f0,#0,#0
  db  #3,#ff,#ff,#cf,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#ff,#3f,#3c,#0,#0
  db  #0,#0,#0,#3f,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#f3,#3,#0,#3c
  db  #ff,#ff,#ff,#fc,#0,#0,#ff,#ff
  db  #3f,#0,#0,#0,#0,#0,#30,#ff
  db  #ff,#ff,#cc,#0,#0,#0,#0,#0
  db  #0,#0,#ff,#ff,#ff,#cc,#0,#0
  db  #f,#ff,#ff,#cf,#0,#0,#c0,#ff
  db  #ff,#ff,#ff,#ff,#ff,#ff,#cf,#0
  db  #0,#0,#0,#ff,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#ff,#fc,#0,#30
  db  #ff,#ff,#ff,#cc,#0,#0,#ff,#ff
  db  #f3,#0,#0,#0,#0,#0,#3c,#ff
  db  #ff,#ff,#c3,#0,#0,#0,#0,#0
  db  #0,#0,#ff,#ff,#ff,#cc,#0,#0
  db  #f,#ff,#ff,#cf,#0,#0,#c0,#ff
  db  #ff,#ff,#ff,#ff,#ff,#ff,#cf,#0
  db  #0,#0,#0,#ff,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#ff,#fc,#0,#30
  db  #ff,#ff,#ff,#cc,#0,#0,#ff,#ff
  db  #f3,#0,#0,#0,#0,#0,#3c,#ff
  db  #ff,#ff,#c3,#0,#0,#0,#0,#0
  db  #0,#0,#ff,#ff,#ff,#cc,#0,#0
  db  #f,#ff,#ff,#cf,#0,#0,#c0,#ff
  db  #ff,#ff,#ff,#ff,#ff,#ff,#cf,#0
  db  #0,#0,#0,#ff,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#ff,#fc,#0,#30
  db  #ff,#ff,#ff,#cc,#0,#0,#ff,#ff
  db  #f3,#0,#0,#0,#0,#0,#3c,#ff
  db  #ff,#ff,#c3,#0,#0,#0,#0,#0
  db  #0,#0,#ff,#ff,#ff,#cc,#0,#0
  db  #f,#ff,#ff,#cf,#0,#0,#c0,#ff
  db  #ff,#ff,#ff,#ff,#ff,#ff,#cf,#0
  db  #0,#0,#0,#ff,#fc,#0,#0,#0
  db  #0,#0,#0,#0,#ff,#fc,#0,#30
  db  #ff,#ff,#ff,#cc,#0,#0,#ff,#ff
  db  #f3,#0,#0,#0,#0,#0,#3c,#ff
  db  #ff,#ff,#c3,#0,#0,#0,#0,#0
  db  #0,#cc,#ff,#ff,#ff,#c,#0,#0
  db  #3f,#ff,#ff,#c3,#0,#0,#0,#ff
  db  #ff,#ff,#ff,#ff,#ff,#ff,#ff,#cf
  db  #0,#0,#0,#3f,#3,#0,#0,#0
  db  #0,#0,#0,#30,#ff,#f0,#0,#30
  db  #ff,#ff,#ff,#c0,#0,#0,#ff,#ff
  db  #cf,#0,#0,#0,#0,#c0,#f3,#ff
  db  #ff,#ff,#3f,#c0,#0,#0,#0,#0
  db  #0,#cc,#ff,#ff,#ff,#c,#0,#0
  db  #3f,#ff,#ff,#c3,#0,#0,#0,#ff
  db  #ff,#ff,#ff,#ff,#ff,#ff,#ff,#cf
  db  #0,#0,#0,#3f,#3,#0,#0,#0
  db  #0,#0,#0,#30,#ff,#f0,#0,#30
  db  #ff,#ff,#ff,#c0,#0,#0,#ff,#ff
  db  #cf,#0,#0,#0,#0,#c0,#f3,#ff
  db  #ff,#ff,#3f,#c0,#0,#0,#0,#0
  db  #0,#cc,#ff,#ff,#ff,#c,#0,#0
  db  #3f,#ff,#ff,#c3,#0,#0,#0,#ff
  db  #ff,#ff,#ff,#ff,#ff,#ff,#ff,#cf
  db  #0,#0,#0,#3f,#3,#0,#0,#0
  db  #0,#0,#0,#30,#ff,#f0,#0,#30
  db  #ff,#ff,#ff,#c0,#0,#0,#ff,#ff
  db  #cf,#0,#0,#0,#0,#c0,#f3,#ff
  db  #ff,#ff,#3f,#c0,#0,#0,#0,#0
  db  #0,#cc,#ff,#ff,#ff,#c,#0,#0
  db  #3f,#ff,#ff,#c3,#0,#0,#0,#ff
  db  #ff,#ff,#ff,#ff,#ff,#ff,#ff,#cf
  db  #0,#0,#0,#3f,#3,#0,#0,#0
  db  #0,#0,#0,#30,#ff,#f0,#0,#30
  db  #ff,#ff,#ff,#c0,#0,#0,#ff,#ff
  db  #cf,#0,#0,#0,#0,#c0,#f3,#ff
  db  #ff,#ff,#3f,#c0,#0,#0,#0,#0
  db  #0,#30,#ff,#ff,#ff,#0,#0,#c0
  db  #ff,#ff,#ff,#c3,#0,#0,#0,#f3
  db  #ff,#ff,#c,#f0,#3f,#ff,#ff,#ff
  db  #fc,#0,#0,#f3,#f3,#0,#0,#0
  db  #0,#0,#0,#cf,#ff,#c0,#0,#c
  db  #ff,#ff,#f3,#0,#0,#0,#ff,#ff
  db  #f,#0,#0,#0,#0,#fc,#ff,#3f
  db  #ff,#ff,#ff,#3c,#0,#0,#0,#0
  db  #0,#30,#ff,#ff,#ff,#0,#0,#c0
  db  #ff,#ff,#ff,#c3,#0,#0,#0,#f3
  db  #ff,#ff,#c,#f0,#3f,#ff,#ff,#ff
  db  #fc,#0,#0,#f3,#f3,#0,#0,#0
  db  #0,#0,#0,#cf,#ff,#c0,#0,#c
  db  #ff,#ff,#f3,#0,#0,#0,#ff,#ff
  db  #f,#0,#0,#0,#0,#fc,#ff,#3f
  db  #ff,#ff,#ff,#3c,#0,#0,#0,#0
  db  #0,#30,#ff,#ff,#ff,#0,#0,#c0
  db  #ff,#ff,#ff,#c3,#0,#0,#0,#f3
  db  #ff,#ff,#c,#f0,#3f,#ff,#ff,#ff
  db  #fc,#0,#0,#f3,#f3,#0,#0,#0
  db  #0,#0,#0,#cf,#ff,#c0,#0,#c
  db  #ff,#ff,#f3,#0,#0,#0,#ff,#ff
  db  #f,#0,#0,#0,#0,#fc,#ff,#3f
  db  #ff,#ff,#ff,#3c,#0,#0,#0,#0
  db  #0,#30,#ff,#ff,#ff,#0,#0,#c0
  db  #ff,#ff,#ff,#c3,#0,#0,#0,#f3
  db  #ff,#ff,#c,#f0,#3f,#ff,#ff,#ff
  db  #fc,#0,#0,#f3,#f3,#0,#0,#0
  db  #0,#0,#0,#cf,#ff,#c0,#0,#c
  db  #ff,#ff,#f3,#0,#0,#0,#ff,#ff
  db  #f,#0,#0,#0,#0,#fc,#ff,#3f
  db  #ff,#ff,#ff,#3c,#0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#0,#0,#3c
  db  #ff,#ff,#ff,#3,#0,#0,#0,#33
  db  #ff,#ff,#cc,#0,#cc,#ff,#ff,#ff
  db  #3f,#c0,#0,#33,#ff,#fc,#0,#0
  db  #0,#0,#fc,#ff,#f3,#0,#0,#c0
  db  #ff,#ff,#f3,#0,#0,#0,#ff,#ff
  db  #3,#0,#0,#0,#c0,#3f,#ff,#fc
  db  #f,#ff,#ff,#cf,#0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#0,#0,#3c
  db  #ff,#ff,#ff,#3,#0,#0,#0,#33
  db  #ff,#ff,#cc,#0,#cc,#ff,#ff,#ff
  db  #3f,#c0,#0,#33,#ff,#fc,#0,#0
  db  #0,#0,#fc,#ff,#f3,#0,#0,#c0
  db  #ff,#ff,#f3,#0,#0,#0,#ff,#ff
  db  #3,#0,#0,#0,#c0,#3f,#ff,#fc
  db  #f,#ff,#ff,#cf,#0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#0,#0,#3c
  db  #ff,#ff,#ff,#3,#0,#0,#0,#33
  db  #ff,#ff,#cc,#0,#cc,#ff,#ff,#ff
  db  #3f,#c0,#0,#33,#ff,#fc,#0,#0
  db  #0,#0,#fc,#ff,#f3,#0,#0,#c0
  db  #ff,#ff,#f3,#0,#0,#0,#ff,#ff
  db  #3,#0,#0,#0,#c0,#3f,#ff,#fc
  db  #f,#ff,#ff,#cf,#0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#0,#0,#3c
  db  #ff,#ff,#ff,#3,#0,#0,#0,#33
  db  #ff,#ff,#cc,#0,#cc,#ff,#ff,#ff
  db  #3f,#c0,#0,#33,#ff,#fc,#0,#0
  db  #0,#0,#fc,#ff,#f3,#0,#0,#c0
  db  #ff,#ff,#f3,#0,#0,#0,#ff,#ff
  db  #3,#0,#0,#0,#c0,#3f,#ff,#fc
  db  #f,#ff,#ff,#cf,#0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#c,#0,#cf
  db  #ff,#ff,#ff,#fc,#0,#0,#0,#f
  db  #ff,#ff,#f0,#0,#0,#c3,#ff,#ff
  db  #ff,#3c,#0,#f,#ff,#ff,#fc,#0
  db  #0,#fc,#ff,#ff,#f,#0,#0,#0
  db  #ff,#ff,#3f,#0,#0,#0,#ff,#ff
  db  #fc,#0,#0,#0,#3,#ff,#3f,#c0
  db  #f0,#ff,#ff,#ff,#c0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#c,#0,#cf
  db  #ff,#ff,#ff,#fc,#0,#0,#0,#f
  db  #ff,#ff,#f0,#0,#0,#c3,#ff,#ff
  db  #ff,#3c,#0,#f,#ff,#ff,#fc,#0
  db  #0,#fc,#ff,#ff,#f,#0,#0,#0
  db  #ff,#ff,#3f,#0,#0,#0,#ff,#ff
  db  #fc,#0,#0,#0,#3,#ff,#3f,#c0
  db  #f0,#ff,#ff,#ff,#c0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#c,#0,#cf
  db  #ff,#ff,#ff,#fc,#0,#0,#0,#f
  db  #ff,#ff,#f0,#0,#0,#c3,#ff,#ff
  db  #ff,#3c,#0,#f,#ff,#ff,#fc,#0
  db  #0,#fc,#ff,#ff,#f,#0,#0,#0
  db  #ff,#ff,#3f,#0,#0,#0,#ff,#ff
  db  #fc,#0,#0,#0,#3,#ff,#3f,#c0
  db  #f0,#ff,#ff,#ff,#c0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#c,#0,#cf
  db  #ff,#ff,#ff,#fc,#0,#0,#0,#f
  db  #ff,#ff,#f0,#0,#0,#c3,#ff,#ff
  db  #ff,#3c,#0,#f,#ff,#ff,#fc,#0
  db  #0,#fc,#ff,#ff,#f,#0,#0,#0
  db  #ff,#ff,#3f,#0,#0,#0,#ff,#ff
  db  #fc,#0,#0,#0,#3,#ff,#3f,#c0
  db  #f0,#ff,#ff,#ff,#c0,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#fc,#30,#ff
  db  #f3,#ff,#ff,#fc,#0,#0,#0,#3
  db  #ff,#ff,#fc,#0,#0,#30,#ff,#ff
  db  #ff,#f,#0,#fc,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#3c,#0,#0,#0
  db  #f3,#ff,#ff,#0,#0,#c,#ff,#ff
  db  #3c,#0,#0,#c,#ff,#ff,#3,#0
  db  #c0,#ff,#ff,#ff,#3c,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#fc,#30,#ff
  db  #f3,#ff,#ff,#fc,#0,#0,#0,#3
  db  #ff,#ff,#fc,#0,#0,#30,#ff,#ff
  db  #ff,#f,#0,#fc,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#3c,#0,#0,#0
  db  #f3,#ff,#ff,#0,#0,#c,#ff,#ff
  db  #3c,#0,#0,#c,#ff,#ff,#3,#0
  db  #c0,#ff,#ff,#ff,#3c,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#fc,#30,#ff
  db  #f3,#ff,#ff,#fc,#0,#0,#0,#3
  db  #ff,#ff,#fc,#0,#0,#30,#ff,#ff
  db  #ff,#f,#0,#fc,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#3c,#0,#0,#0
  db  #f3,#ff,#ff,#0,#0,#c,#ff,#ff
  db  #3c,#0,#0,#c,#ff,#ff,#3,#0
  db  #c0,#ff,#ff,#ff,#3c,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#fc,#30,#ff
  db  #f3,#ff,#ff,#fc,#0,#0,#0,#3
  db  #ff,#ff,#fc,#0,#0,#30,#ff,#ff
  db  #ff,#f,#0,#fc,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#3c,#0,#0,#0
  db  #f3,#ff,#ff,#0,#0,#c,#ff,#ff
  db  #3c,#0,#0,#c,#ff,#ff,#3,#0
  db  #c0,#ff,#ff,#ff,#3c,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#ff,#ff,#c3
  db  #cf,#ff,#ff,#33,#ff,#c,#ff,#f
  db  #ff,#ff,#3,#0,#0,#0,#ff,#ff
  db  #ff,#f3,#0,#f0,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#c0,#0,#0,#0
  db  #f,#ff,#ff,#c,#0,#cc,#ff,#ff
  db  #f0,#0,#0,#f,#ff,#ff,#c,#0
  db  #0,#33,#ff,#ff,#f,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#ff,#ff,#c3
  db  #cf,#ff,#ff,#33,#ff,#c,#ff,#f
  db  #ff,#ff,#3,#0,#0,#0,#ff,#ff
  db  #ff,#f3,#0,#f0,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#c0,#0,#0,#0
  db  #f,#ff,#ff,#c,#0,#cc,#ff,#ff
  db  #f0,#0,#0,#f,#ff,#ff,#c,#0
  db  #0,#33,#ff,#ff,#f,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#ff,#ff,#c3
  db  #cf,#ff,#ff,#33,#ff,#c,#ff,#f
  db  #ff,#ff,#3,#0,#0,#0,#ff,#ff
  db  #ff,#f3,#0,#f0,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#c0,#0,#0,#0
  db  #f,#ff,#ff,#c,#0,#cc,#ff,#ff
  db  #f0,#0,#0,#f,#ff,#ff,#c,#0
  db  #0,#33,#ff,#ff,#f,#0,#0,#0
  db  #0,#3c,#ff,#ff,#ff,#ff,#ff,#c3
  db  #cf,#ff,#ff,#33,#ff,#c,#ff,#f
  db  #ff,#ff,#3,#0,#0,#0,#ff,#ff
  db  #ff,#f3,#0,#f0,#ff,#ff,#ff,#ff
  db  #ff,#ff,#ff,#ff,#c0,#0,#0,#0
  db  #f,#ff,#ff,#c,#0,#cc,#ff,#ff
  db  #f0,#0,#0,#f,#ff,#ff,#c,#0
  db  #0,#33,#ff,#ff,#f,#0,#0,#0
  db  #0,#cc,#ff,#ff,#ff,#ff,#ff,#c
  db  #33,#ff,#ff,#ff,#ff,#c,#ff,#ff
  db  #ff,#ff,#cf,#0,#0,#0,#ff,#ff
  db  #ff,#ff,#0,#0,#3f,#ff,#ff,#ff
  db  #ff,#ff,#ff,#cf,#0,#0,#c,#ff
  db  #3f,#ff,#ff,#cc,#0,#30,#ff,#ff
  db  #30,#0,#30,#ff,#ff,#f,#0,#0
  db  #0,#cf,#ff,#ff,#3f,#c0,#c0,#0
  db  #0,#cc,#ff,#ff,#ff,#ff,#ff,#c
  db  #33,#ff,#ff,#ff,#ff,#c,#ff,#ff
  db  #ff,#ff,#cf,#0,#0,#0,#ff,#ff
  db  #ff,#ff,#0,#0,#3f,#ff,#ff,#ff
  db  #ff,#ff,#ff,#cf,#0,#0,#c,#ff
  db  #3f,#ff,#ff,#cc,#0,#30,#ff,#ff
  db  #30,#0,#30,#ff,#ff,#f,#0,#0
  db  #0,#cf,#ff,#ff,#3f,#c0,#c0,#0
  db  #0,#cc,#ff,#ff,#ff,#ff,#ff,#c
  db  #33,#ff,#ff,#ff,#ff,#c,#ff,#ff
  db  #ff,#ff,#cf,#0,#0,#0,#ff,#ff
  db  #ff,#ff,#0,#0,#3f,#ff,#ff,#ff
  db  #ff,#ff,#ff,#cf,#0,#0,#c,#ff
  db  #3f,#ff,#ff,#cc,#0,#30,#ff,#ff
  db  #30,#0,#30,#ff,#ff,#f,#0,#0
  db  #0,#cf,#ff,#ff,#3f,#c0,#c0,#0
  db  #0,#cc,#ff,#ff,#ff,#ff,#ff,#c
  db  #33,#ff,#ff,#ff,#ff,#c,#ff,#ff
  db  #ff,#ff,#cf,#0,#0,#0,#ff,#ff
  db  #ff,#ff,#0,#0,#3f,#ff,#ff,#ff
  db  #ff,#ff,#ff,#cf,#0,#0,#c,#ff
  db  #3f,#ff,#ff,#cc,#0,#30,#ff,#ff
  db  #30,#0,#30,#ff,#ff,#f,#0,#0
  db  #0,#cf,#ff,#ff,#3f,#c0,#c0,#0
  db  #0,#0,#f3,#ff,#ff,#ff,#fc,#0
  db  #f3,#ff,#ff,#ff,#ff,#c,#ff,#ff
  db  #ff,#ff,#3f,#0,#0,#3,#ff,#ff
  db  #ff,#ff,#c,#0,#c3,#ff,#ff,#ff
  db  #ff,#ff,#ff,#f0,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#f0,#0,#fc,#ff,#ff
  db  #30,#0,#cf,#ff,#ff,#fc,#0,#0
  db  #c0,#f3,#ff,#ff,#ff,#ff,#f,#0
  db  #0,#0,#f3,#ff,#ff,#ff,#fc,#0
  db  #f3,#ff,#ff,#ff,#ff,#c,#ff,#ff
  db  #ff,#ff,#3f,#0,#0,#3,#ff,#ff
  db  #ff,#ff,#c,#0,#c3,#ff,#ff,#ff
  db  #ff,#ff,#ff,#f0,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#f0,#0,#fc,#ff,#ff
  db  #30,#0,#cf,#ff,#ff,#fc,#0,#0
  db  #c0,#f3,#ff,#ff,#ff,#ff,#f,#0
  db  #0,#0,#f3,#ff,#ff,#ff,#fc,#0
  db  #f3,#ff,#ff,#ff,#ff,#c,#ff,#ff
  db  #ff,#ff,#3f,#0,#0,#3,#ff,#ff
  db  #ff,#ff,#c,#0,#c3,#ff,#ff,#ff
  db  #ff,#ff,#ff,#f0,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#f0,#0,#fc,#ff,#ff
  db  #30,#0,#cf,#ff,#ff,#fc,#0,#0
  db  #c0,#f3,#ff,#ff,#ff,#ff,#f,#0
  db  #0,#0,#f3,#ff,#ff,#ff,#fc,#0
  db  #f3,#ff,#ff,#ff,#ff,#c,#ff,#ff
  db  #ff,#ff,#3f,#0,#0,#3,#ff,#ff
  db  #ff,#ff,#c,#0,#c3,#ff,#ff,#ff
  db  #ff,#ff,#ff,#f0,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#f0,#0,#fc,#ff,#ff
  db  #30,#0,#cf,#ff,#ff,#fc,#0,#0
  db  #c0,#f3,#ff,#ff,#ff,#ff,#f,#0
  db  #0,#0,#cc,#3f,#ff,#3c,#0,#0
  db  #3f,#ff,#33,#f0,#0,#0,#0,#0
  db  #3c,#cf,#ff,#c0,#3c,#ff,#ff,#ff
  db  #ff,#ff,#c,#0,#c,#ff,#ff,#ff
  db  #ff,#ff,#33,#0,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#3c,#0,#3,#ff,#ff
  db  #30,#c,#ff,#ff,#ff,#3,#0,#0
  db  #3f,#ff,#ff,#ff,#ff,#ff,#33,#0
  db  #0,#0,#cc,#3f,#ff,#3c,#0,#0
  db  #3f,#ff,#33,#f0,#0,#0,#0,#0
  db  #3c,#cf,#ff,#c0,#3c,#ff,#ff,#ff
  db  #ff,#ff,#c,#0,#c,#ff,#ff,#ff
  db  #ff,#ff,#33,#0,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#3c,#0,#3,#ff,#ff
  db  #30,#c,#ff,#ff,#ff,#3,#0,#0
  db  #3f,#ff,#ff,#ff,#ff,#ff,#33,#0
  db  #0,#0,#cc,#3f,#ff,#3c,#0,#0
  db  #3f,#ff,#33,#f0,#0,#0,#0,#0
  db  #3c,#cf,#ff,#c0,#3c,#ff,#ff,#ff
  db  #ff,#ff,#c,#0,#c,#ff,#ff,#ff
  db  #ff,#ff,#33,#0,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#3c,#0,#3,#ff,#ff
  db  #30,#c,#ff,#ff,#ff,#3,#0,#0
  db  #3f,#ff,#ff,#ff,#ff,#ff,#33,#0
  db  #0,#0,#cc,#3f,#ff,#3c,#0,#0
  db  #3f,#ff,#33,#f0,#0,#0,#0,#0
  db  #3c,#cf,#ff,#c0,#3c,#ff,#ff,#ff
  db  #ff,#ff,#c,#0,#c,#ff,#ff,#ff
  db  #ff,#ff,#33,#0,#0,#0,#c,#ff
  db  #ff,#ff,#ff,#3c,#0,#3,#ff,#ff
  db  #30,#c,#ff,#ff,#ff,#3,#0,#0
  db  #3f,#ff,#ff,#ff,#ff,#ff,#33,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #ff,#3,#0,#0,#0,#0,#0,#0
  db  #0,#0,#f0,#30,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#3,#ff,#ff
  db  #ff,#ff,#cc,#0,#0,#0,#c,#30
  db  #0,#0,#fc,#fc,#0,#cf,#ff,#ff
  db  #cf,#c0,#c0,#c3,#ff,#f3,#0,#0
  db  #cf,#ff,#ff,#ff,#fc,#3c,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #ff,#3,#0,#0,#0,#0,#0,#0
  db  #0,#0,#f0,#30,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#3,#ff,#ff
  db  #ff,#ff,#cc,#0,#0,#0,#c,#30
  db  #0,#0,#fc,#fc,#0,#cf,#ff,#ff
  db  #cf,#c0,#c0,#c3,#ff,#f3,#0,#0
  db  #cf,#ff,#ff,#ff,#fc,#3c,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #ff,#3,#0,#0,#0,#0,#0,#0
  db  #0,#0,#f0,#30,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#3,#ff,#ff
  db  #ff,#ff,#cc,#0,#0,#0,#c,#30
  db  #0,#0,#fc,#fc,#0,#cf,#ff,#ff
  db  #cf,#c0,#c0,#c3,#ff,#f3,#0,#0
  db  #cf,#ff,#ff,#ff,#fc,#3c,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #ff,#3,#0,#0,#0,#0,#0,#0
  db  #0,#0,#f0,#30,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#3,#ff,#ff
  db  #ff,#ff,#cc,#0,#0,#0,#c,#30
  db  #0,#0,#fc,#fc,#0,#cf,#ff,#ff
  db  #cf,#c0,#c0,#c3,#ff,#f3,#0,#0
  db  #cf,#ff,#ff,#ff,#fc,#3c,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#c
  db  #fc,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#c3,#ff
  db  #f3,#30,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#fc,#fc
  db  #3f,#fc,#0,#0,#30,#cf,#0,#0
  db  #3,#3,#30,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#c
  db  #fc,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#c3,#ff
  db  #f3,#30,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#fc,#fc
  db  #3f,#fc,#0,#0,#30,#cf,#0,#0
  db  #3,#3,#30,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#c
  db  #fc,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#c3,#ff
  db  #f3,#30,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#fc,#fc
  db  #3f,#fc,#0,#0,#30,#cf,#0,#0
  db  #3,#3,#30,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#c
  db  #fc,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#c3,#ff
  db  #f3,#30,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#fc,#fc
  db  #3f,#fc,#0,#0,#30,#cf,#0,#0
  db  #3,#3,#30,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0
  db  #0,#0,#0,#0,#0,#0,#0,#0