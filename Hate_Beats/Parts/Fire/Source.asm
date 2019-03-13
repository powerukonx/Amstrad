; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                             (Fire part)                                   *
; *                                                                           *
; * Code            => Power                                                  *
; *                                                                           *
; *****************************************************************************

  org &3000
  ; write direct "feu.ukx"
  nolist

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

; Genere des lignes aleatoires sur les 3 dernieres lignes du tableau.
  ld hl,table_feu
  ld de,32*67
  add hl,de
  ld bc,32*3-1
  sbc hl,bc
  ld b,32*3
bouc0  
  ld a,1
  and &B8
  scf
  jp po,no_clr
  ccf
no_clr
  ld a,(bouc0+1)
  rla
  ld (bouc0+1),a
  or 7
  and 63
  ld (hl),a
  inc hl
  djnz bouc0

; Calcul du feu dans le tableau
  ld bc,table_feu+32+32+1
  ld de,table_feu+32+1
  ld hl,table_feu
  exx
  ld b,64
bcl_feu  
  exx
  inc c:inc l:inc e
  
  repeat 29
    ld a,(bc):inc c:ex de,hl:add a,(hl):inc l:ex de,hl:add a,(hl):inc l:inc l:add a,(hl):srl a:srl a:dec l:ld (hl),a
  rend

  ld a,(bc):inc bc:ex de,hl:add a,(hl):inc hl:ex de,hl:add a,(hl):inc l:inc hl:add a,(hl):srl a:srl a:dec hl:ld (hl),a
  inc c:inc hl:inc e
  exx
  dec b
  jp nz,bcl_feu
  exx

; Affichage du feu a l'ecran
; IX pointe sur la table d'adresse video
reg_ixp  
  ld ix,SCR8000
  exx
  ld hl,table_feu + &400 + 1
  ld bc,pixel_g
  exx
  ld a,32
  ld (tot+1),a
bcl0_feu
  ld e,(ix):inc ix:ld d,(ix):inc ix
  ld c,(ix):inc ix:ld b,(ix):inc ix
  ld l,(ix):inc ix:ld h,(ix):inc ix
  ld a,h:ld iyh,a
  ld a,l:ld iyl,a
  ld l,(ix):inc ix:ld h,(ix):inc ix
  
  repeat 26
    exx:ld c,(hl):ld a,(bc):inc hl:exx:ld (de),a:ld (hl),a:ld (bc),a:ld (iy),a:inc iyl:inc l:inc e:inc c
  rend
  
  exx:ld c,(hl):ld a,(bc):inc hl:exx:ld (de),a:ld (hl),a:ld (bc),a:ld (iy),a:inc iy:inc hl:inc de:inc bc
  
  repeat 5
    exx:ld c,(hl):ld a,(bc):inc hl:exx:ld (de),a:ld (hl),a:ld (bc),a:ld (iy),a:inc iyl:inc l:inc e:inc c
  rend
tot  
  ld a,0
  dec a
  ld (tot+1),a
  jp nz,bcl0_feu

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
list
  ret
nolist

; *****************************************************************************
; Padding
; *****************************************************************************
  align 256,0

; *****************************************************************************
; Table de calcul du feu = Fenetre d'affichage (64 * 32 Octets)
; *****************************************************************************
table_feu
  ds 67*32,0


; *****************************************************************************
; Padding
; *****************************************************************************
  align 256,0

; *****************************************************************************
; Table de conversion octet vers pixel
; *****************************************************************************
pixel_g
  db #00,#00,#00,#00
  db #00,#00,#00,#00
  db #00,#00,#00,#00
  db #00,#00,#00,#00
  db #C0,#C0,#0C,#0C
  db #CC,#CC,#30,#30
  db #F0,#F0,#3C,#3C
  db #FC,#FC,#03,#03
  db #C3,#C3,#0F,#0F
  db #CF,#CF,#33,#33
  db #F3,#F3,#3F,#3F
  db #FF,#FF,#FF,#FF
  db #FF,#FF,#FF,#FF
  db #FF,#FF,#FF,#FF
  db #FF,#FF,#FF,#FF
  db #FF,#FF,#FF,#FF
  db #FF,#FF,#FF,#FF
