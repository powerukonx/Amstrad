; *****************************************************************************
; *                      Hate Beats, CPC demo by UKONX                        *
; *                           (2D metaball FX)                                *
; *                                                                           *
; * Code            => Power                                                  *
; * Gfxs            => Power                                                  *
; *                                                                           *
; *****************************************************************************
  org &3000
;  write  "metaball.ukx"
  nolist

; Page flipping
  ld bc,PORT_CRTC_SELECT_REG + CRTC_START_ADDRESS_H
  out (c),c
  inc b
reg12_meta  
  ld a,%00110000
  out (c),a
  dec b
  inc c
  out (c),c
  inc b
  xor a
  out (c),a

; Clear alls metaballs at old position.
  ld ix,(ancien1y)
  ld de,(ancien1x)
  call clear_meta

  ld ix,(ancien2y)
  ld de,(ancien2x)
  call clear_meta

  ld ix,(ancien3y)
  ld de,(ancien3x)
  call clear_meta

  ld ix,(ancien4y)
  ld de,(ancien4x)
  call clear_meta

  ld ix,(ancien5y)
  ld de,(ancien5x)
  call clear_meta

  ld ix,(ancien6y)
  ld de,(ancien6x)
  call clear_meta

  ld ix,(ancien7y)
  ld de,(ancien7x)
  call clear_meta

  ld ix,(ancien8y)
  ld de,(ancien8x)
  call clear_meta

  ld ix,(ancien9y)
  ld de,(ancien9x)
  call clear_meta

  ld ix,(ancien10y)
  ld de,(ancien10x)
  call clear_meta

; Compute and display at new position.  
; Fait glisser les valeurs de nouveau vers ancien
aff_meta
  ld hl,nouveau1x
  ld de,ancien1x
  
  repeat 16*3
    ldi
  rend

cur_met_y
  ld de,SCR8000
; Metaball 1
  ld a,5
met1y    
  ld hl,meta_y1
  dec l
  add a,l
  ld l,a
  ld (met1y+1),hl
  ld l,(hl)
  ld h,0
  ld b,h
  ld c,l
met1yb    
  ld hl,meta_y1+32
  inc l
  ld (met1yb+1),hl
  ld l,(hl)
  ld h,0
  add hl,bc
  rr h 
  rr l
  add hl,hl
  add hl,de
  push hl
  pop ix
  ld (nouveau1y),ix
  ld a,6
met1x    
  ld hl,meta_x1
  inc l
  add a,l
  ld l,a
  ld (met1x+1),hl
  ld c,(hl)
  ld b,0
  ld (nouveau1x),bc
  call play_meta

; Metaball 2
  ld a,5
  ld de,(cur_met_y+1)
met2y    
  ld hl,meta_y1:dec l:add a,l:ld l,a:ld (met2y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau2y),ix
  ld a,5
met2x   
  ld hl,meta_x1:add a,l:ld l,a:inc l:ld (met2x+1),hl
  ld c,(hl):ld b,0:ld (nouveau2x),bc
  call play_meta

; Metaball 3
  ld de,(cur_met_y+1)
met3y   
  ld hl,meta_y1:dec l:dec l:ld (met3y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau3y),ix
met3x    
  ld hl,meta_x1:dec l:dec l:ld (met3x+1),hl
  ld c,(hl):ld b,0:ld (nouveau3x),bc
  call play_meta

; Metaball 4
  ld a,5
  ld de,(cur_met_y+1)
met4y   
  ld hl,meta_y1:add a,l:ld l,a:inc l:ld (met4y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau4y),ix
  ld a,3
met4x    
  ld hl,meta_x1:add a,l:ld l,a:inc l:ld (met4x+1),hl
  ld e,(hl):ld d,0
  ld a,7
met4xb   
  ld hl,meta_x1:add a,l:ld l,a:ld (met4xb+1),hl
  ld l,(hl):ld h,0
  add hl,de:rr h:rr l:ld c,l:ld b,h:ld (nouveau4x),bc
  call play_meta

; Metaball 5
  ld de,(cur_met_y+1)
  ld a,3
met5y   
  ld hl,meta_y1:dec l:add a,l:ld l,a:ld (met5y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau5y),ix
  ld a,4
met5x    
  ld hl,meta_x1+32:add a,l:ld l,a:inc l:ld (met5x+1),hl
  ld c,(hl):ld b,0:ld (nouveau5x),bc
  call play_meta

; Metaball 6
  ld de,(cur_met_y+1)
  ld a,5
met6y   
  ld hl,meta_y1:add a,l:ld l,a:inc l:ld (met6y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau6y),ix
  ld a,9
met6x    
  ld hl,meta_y1:add a,l:ld l,a:inc l:ld (met6x+1),hl
  ld a,(hl):ld b,0:rra:rra:and 31:ld c,a:ld (nouveau6x),bc
  call play_meta

; Metaball 7
  ld de,(cur_met_y+1)
met7y   
  ld hl,meta_y1:inc l:ld (met7y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau7y),ix
met7x    
  ld hl,meta_x1:inc l:inc l:ld (met7x+1),hl
  ld c,(hl):ld b,0:dec c:ld (nouveau7x),bc
  call play_meta

; Metaball 8
  ld de,(cur_met_y+1)
  ld a,-5
met8y   
  ld hl,meta_y1:add a,l:ld l,a:dec l:ld (met8y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau8y),ix
  ld a,-6
met8x   
  ld hl,meta_x1:add a,l:ld l,a:inc l:ld (met8x+1),hl
  ld c,(hl):ld b,0:ld (nouveau8x),bc
  call play_meta

; Metaball 9
  ld de,(cur_met_y+1)
  ld a,-1
met9y   
  ld hl,meta_y1:add a,l:ld l,a:dec l:ld (met9y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau9y),ix
  ld a,6
met9x    
  ld hl,meta_x1:add a,l:ld l,a:inc l:ld (met9x+1),hl
  ld c,(hl):ld b,0:ld (nouveau9x),bc
  call play_meta

; Metaball 10
  ld de,(cur_met_y+1)
  ld a,-5
met10y   
  ld hl,meta_y1:add a,l:ld l,a:inc l:ld (met10y+1),hl
  ld l,(hl):ld h,0
  add hl,hl:add hl,de
  push hl:pop ix
  ld (nouveau10y),ix
  ld a,-6
met10x    
  ld hl,meta_x1:add a,l:ld l,a:dec l:ld (met10x+1),hl
  ld c,(hl):ld b,0:ld (nouveau10x),bc
  call play_meta

; Flipping page
flip_meta  
  ld a,(reg12_meta+1)
  xor %00010000
  ld (reg12_meta+1),a
flip    
  ld a,0
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
  ld (cur_met_y+1),hl

  ret

; *****************************************************************************
; Routine d'affichage d'une metaball
; en Entrée  IX = table d'adresse ecran
;            BC = position en x
; *****************************************************************************
play_meta
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl:inc hl:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#44:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#44:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl:inc hl
  ld d,#44:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4a:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4a:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4D:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4A:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4D:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4E:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4D:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4D:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#52:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4C:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4E:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#51:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#53:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4C:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4E:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#53:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#55:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#52:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4C:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4E:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#54:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#52:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4C:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#54:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#52:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#51:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#51:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#51:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#51:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#51:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#54:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#52:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4E:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#54:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#56:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#52:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4C:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4E:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#53:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#55:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#52:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4C:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4E:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#51:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#53:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4C:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4D:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#52:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4F:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4A:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4E:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#50:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4D:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#49:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4D:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4B:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4D:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4A:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4A:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#46:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#48:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#4A:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl:inc hl
  ld d,#44:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld e,(hl):ld a,(de):ld (hl),a:inc hl
  dec d:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#43:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#45:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#47:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#44:ld e,(hl):ld a,(de):ld (hl),a
  ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,bc:inc hl:inc hl:inc hl:inc hl
  ld d,#42:ld e,(hl):ld a,(de):ld (hl),a:inc hl
  ld d,#44:ld e,(hl):ld a,(de):ld (hl),a
tyty
  ret
  
; *****************************************************************************
; Efface une metaball
; En entrée IX = adresse Y
;           DE = adresse X
; *****************************************************************************
clear_meta
  xor a
  repeat 35
    ld l,(ix):inc ix:ld h,(ix):inc ix:add hl,de:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a:inc hl:ld (hl),a
  rend
  ret

; *****************************************************************************
; *****************************************************************************
ancien1x  dw 0
ancien1y  dw SCR8000
ancien2x  dw 0
ancien2y  dw SCR8000
ancien3x  dw 0
ancien3y  dw SCR8000
ancien4x  dw 0
ancien4y  dw SCR8000
ancien5x  dw 0      
ancien5y  dw SCR8000
ancien6x  dw 0      
ancien6y  dw SCR8000
ancien7x  dw 0
ancien7y  dw SCR8000
ancien8x  dw 0      
ancien8y  dw SCR8000
ancien9x  dw 0      
ancien9y  dw SCR8000
ancien10x  dw 0
ancien10y  dw SCR8000
ancien11x  dw 0      
ancien11y  dw SCR8000
ancien12x  dw 0      
ancien12y  dw SCR8000
nouveau1x  dw 0      
nouveau1y  dw SCR8000
nouveau2x  dw 0      
nouveau2y  dw SCR8000
nouveau3x  dw 0      
nouveau3y  dw SCR8000
nouveau4x  dw 0      
nouveau4y  dw SCR8000
nouveau5x  dw 0      
nouveau5y  dw SCR8000
nouveau6x  dw 0      
nouveau6y  dw SCR8000
nouveau7x  dw 0      
nouveau7y  dw SCR8000
nouveau8x  dw 0      
nouveau8y  dw SCR8000
nouveau9x  dw 0      
nouveau9y  dw SCR8000
nouveau10x  dw 0
nouveau10y  dw SCR8000
nouveau11x  dw 0      
nouveau11y  dw SCR8000
nouveau12x  dw 0      
nouveau12y  dw SCR8000

; *****************************************************************************
; Padding
; *****************************************************************************
  align 4096,0

; *****************************************************************************
; Table de deplacement XY
; *****************************************************************************
meta_x1
  db #16,#16,#16,#16,#16,#16,#16,#16
  db #16,#16,#16,#16,#16,#16,#16,#16
  db #16,#16,#15,#15,#15,#15,#15,#15
  db #15,#14,#14,#14,#14,#14,#14,#13
  db #13,#13,#13,#13,#12,#12,#12,#12
  db #12,#11,#11,#11,#11,#10,#10,#10
  db #10,#0f,#0f,#0f,#0f,#0e,#0e,#0e
  db #0e,#0d,#0d,#0d,#0d,#0c,#0c,#0c
  db #0c,#0b,#0b,#0b,#0a,#0a,#0a,#0a
  db #09,#09,#09,#09,#08,#08,#08,#08
  db #07,#07,#07,#07,#06,#06,#06,#06
  db #05,#05,#05,#05,#05,#04,#04,#04
  db #04,#04,#03,#03,#03,#03,#03,#03
  db #02,#02,#02,#02,#02,#02,#02,#01
  db #01,#01,#01,#01,#01,#01,#01,#01
  db #01,#01,#01,#01,#01,#01,#01,#01
  db #01,#01,#01,#01,#01,#01,#01,#01
  db #01,#01,#01,#01,#01,#01,#01,#01
  db #01,#01,#02,#02,#02,#02,#02,#02
  db #02,#03,#03,#03,#03,#03,#03,#04
  db #04,#04,#04,#04,#05,#05,#05,#05
  db #05,#06,#06,#06,#06,#07,#07,#07
  db #07,#08,#08,#08,#08,#09,#09,#09
  db #09,#0a,#0a,#0a,#0a,#0b,#0b,#0b
  db #0c,#0c,#0c,#0c,#0d,#0d,#0d,#0d
  db #0e,#0e,#0e,#0e,#0f,#0f,#0f,#0f
  db #10,#10,#10,#10,#11,#11,#11,#11
  db #12,#12,#12,#12,#12,#13,#13,#13
  db #13,#13,#14,#14,#14,#14,#14,#14
  db #15,#15,#15,#15,#15,#15,#15,#16
  db #16,#16,#16,#16,#16,#16,#16,#16
  db #16,#16,#16,#16,#16,#16,#16,#16

meta_y1
  db #2f,#30,#31,#32,#33,#34,#35,#36
  db #37,#38,#39,#3b,#3c,#3d,#3e,#3f
  db #40,#41,#42,#43,#44,#45,#46,#47
  db #48,#48,#49,#4a,#4b,#4c,#4d,#4e
  db #4e,#4f,#50,#51,#51,#52,#53,#53
  db #54,#55,#55,#56,#56,#57,#57,#58
  db #58,#58,#59,#59,#5a,#5a,#5a,#5b
  db #5b,#5b,#5b,#5b,#5b,#5b,#5b,#5b
  db #5b,#5b,#5b,#5b,#5b,#5b,#5b,#5b
  db #5b,#5a,#5a,#5a,#5a,#59,#59,#58
  db #58,#58,#57,#57,#56,#56,#55,#55
  db #54,#53,#53,#52,#51,#51,#50,#4f
  db #4e,#4e,#4d,#4c,#4b,#4a,#49,#48
  db #48,#47,#46,#45,#44,#43,#42,#41
  db #40,#3f,#3e,#3d,#3c,#3b,#39,#38
  db #37,#36,#35,#34,#33,#32,#31,#30
  db #2f,#2d,#2c,#2b,#2a,#29,#28,#27
  db #26,#25,#24,#22,#21,#20,#1f,#1e
  db #1d,#1c,#1b,#1a,#19,#18,#17,#16
  db #15,#15,#14,#13,#12,#11,#10,#0f
  db #0f,#0e,#0d,#0c,#0c,#0b,#0a,#0a
  db #09,#08,#08,#07,#07,#06,#06,#05
  db #05,#05,#04,#04,#03,#03,#03,#03
  db #02,#02,#02,#02,#02,#02,#02,#02
  db #02,#02,#02,#02,#02,#02,#02,#02
  db #02,#03,#03,#03,#03,#04,#04,#05
  db #05,#05,#06,#06,#07,#07,#08,#08
  db #09,#0a,#0a,#0b,#0c,#0c,#0d,#0e
  db #0f,#0f,#10,#11,#12,#13,#14,#15
  db #15,#16,#17,#18,#19,#1a,#1b,#1c
  db #1d,#1e,#1f,#20,#21,#22,#24,#25
  db #26,#27,#28,#29,#2a,#2b,#2c,#2d

; *****************************************************************************
; Table de calcul metaball
; *****************************************************************************
calc_meta
  db #40,#41,#42,#43,#44,#45,#46,#47
  db #48,#49,#4a,#4b,#4c,#4d,#4e,#4f
  db #50,#51,#52,#53,#54,#55,#56,#57
  db #58,#59,#5a,#5b,#5c,#5d,#5e,#5f
  db #60,#61,#62,#63,#64,#65,#66,#67
  db #68,#69,#6a,#6b,#6c,#6d,#6e,#6f
  db #70,#71,#72,#73,#74,#75,#76,#77
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #04,#05,#06,#07,#10,#11,#12,#13
  db #0c,#0d,#0e,#0f,#18,#19,#1a,#1b
  db #14,#15,#16,#17,#01,#55,#03,#57
  db #1c,#1d,#1e,#1f,#09,#5d,#0b,#5f
  db #24,#25,#26,#27,#30,#31,#32,#33
  db #2c,#2d,#2e,#2f,#38,#39,#3a,#3b
  db #34,#35,#36,#37,#21,#75,#23,#77
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #c0,#c1,#c2,#c3,#c4,#c5,#c6,#c7
  db #c8,#c9,#ca,#cb,#cc,#cd,#ce,#cf
  db #d0,#d1,#d2,#d3,#d4,#d5,#d6,#d7
  db #d8,#d9,#da,#db,#dc,#dd,#de,#df
  db #e0,#e1,#e2,#e3,#e4,#e5,#e6,#e7
  db #e8,#e9,#ea,#eb,#ec,#ed,#ee,#ef
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #84,#85,#86,#87,#90,#91,#92,#93
  db #8c,#8d,#8e,#8f,#98,#99,#9a,#9b
  db #94,#95,#96,#97,#81,#d5,#83,#d7
  db #9c,#9d,#9e,#9f,#89,#dd,#8b,#df
  db #a4,#a5,#a6,#a7,#b0,#b1,#b2,#b3
  db #ac,#ad,#ae,#af,#b8,#b9,#ba,#bb
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #80,#81,#82,#83,#84,#85,#86,#87
  db #88,#89,#8a,#8b,#8c,#8d,#8e,#8f
  db #90,#91,#92,#93,#94,#95,#96,#97
  db #98,#99,#9a,#9b,#9c,#9d,#9e,#9f
  db #a0,#a1,#a2,#a3,#a4,#a5,#a6,#a7
  db #a8,#a9,#aa,#ab,#ac,#ad,#ae,#af
  db #b0,#b1,#b2,#b3,#b4,#b5,#b6,#b7
  db #b8,#b9,#ba,#bb,#bc,#bd,#be,#bf
  db #c0,#c1,#c2,#c3,#c4,#c5,#c6,#c7
  db #c8,#c9,#ca,#cb,#cc,#cd,#ce,#cf
  db #d0,#d1,#d2,#d3,#d4,#d5,#d6,#d7
  db #d8,#d9,#da,#db,#dc,#dd,#de,#df
  db #e0,#e1,#e2,#e3,#e4,#e5,#e6,#e7
  db #e8,#e9,#ea,#eb,#ec,#ed,#ee,#ef
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #08,#09,#0a,#0b,#0c,#0d,#0e,#0f
  db #20,#21,#22,#23,#24,#25,#26,#27
  db #18,#19,#1a,#1b,#1c,#1d,#1e,#1f
  db #30,#31,#32,#33,#34,#35,#36,#37
  db #28,#29,#2a,#2b,#2c,#2d,#2e,#2f
  db #02,#03,#aa,#ab,#06,#07,#ae,#af
  db #38,#39,#3a,#3b,#3c,#3d,#3e,#3f
  db #12,#13,#ba,#bb,#16,#17,#be,#bf
  db #48,#49,#4a,#4b,#4c,#4d,#4e,#4f
  db #60,#61,#62,#63,#64,#65,#66,#67
  db #58,#59,#5a,#5b,#5c,#5d,#5e,#5f
  db #70,#71,#72,#73,#74,#75,#76,#77
  db #68,#69,#6a,#6b,#6c,#6d,#6e,#6f
  db #42,#43,#ea,#eb,#46,#47,#ee,#ef
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #c0,#c1,#c2,#c3,#c4,#c5,#c6,#c7
  db #c8,#c9,#ca,#cb,#cc,#cd,#ce,#cf
  db #d0,#d1,#d2,#d3,#d4,#d5,#d6,#d7
  db #d8,#d9,#da,#db,#dc,#dd,#de,#df
  db #e0,#e1,#e2,#e3,#e4,#e5,#e6,#e7
  db #e8,#e9,#ea,#eb,#ec,#ed,#ee,#ef
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #84,#85,#86,#87,#90,#91,#92,#93
  db #8c,#8d,#8e,#8f,#98,#99,#9a,#9b
  db #94,#95,#96,#97,#81,#d5,#83,#d7
  db #9c,#9d,#9e,#9f,#89,#dd,#8b,#df
  db #a4,#a5,#a6,#a7,#b0,#b1,#b2,#b3
  db #ac,#ad,#ae,#af,#b8,#b9,#ba,#bb
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #48,#49,#4a,#4b,#4c,#4d,#4e,#4f
  db #60,#61,#62,#63,#64,#65,#66,#67
  db #58,#59,#5a,#5b,#5c,#5d,#5e,#5f
  db #70,#71,#72,#73,#74,#75,#76,#77
  db #68,#69,#6a,#6b,#6c,#6d,#6e,#6f
  db #42,#43,#ea,#eb,#46,#47,#ee,#ef
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #0c,#0d,#0e,#0f,#18,#19,#1a,#1b
  db #24,#25,#26,#27,#30,#31,#32,#33
  db #1c,#1d,#1e,#1f,#09,#5d,#0b,#5f
  db #34,#35,#36,#37,#21,#75,#23,#77
  db #2c,#2d,#2e,#2f,#38,#39,#3a,#3b
  db #06,#07,#ae,#af,#12,#13,#ba,#bb
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #84,#85,#86,#87,#90,#91,#92,#93
  db #8c,#8d,#8e,#8f,#98,#99,#9a,#9b
  db #94,#95,#96,#97,#81,#d5,#83,#d7
  db #9c,#9d,#9e,#9f,#89,#dd,#8b,#df
  db #a4,#a5,#a6,#a7,#b0,#b1,#b2,#b3
  db #ac,#ad,#ae,#af,#b8,#b9,#ba,#bb
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #c4,#c5,#c6,#c7,#d0,#d1,#d2,#d3
  db #cc,#cd,#ce,#cf,#d8,#d9,#da,#db
  db #d4,#d5,#d6,#d7,#c1,#d5,#c3,#d7
  db #dc,#dd,#de,#df,#c9,#dd,#cb,#df
  db #e4,#e5,#e6,#e7,#f0,#f1,#f2,#f3
  db #ec,#ed,#ee,#ef,#f8,#f9,#fa,#fb
  db #f4,#f5,#f6,#f7,#e1,#f5,#e3,#f7
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #0c,#0d,#0e,#0f,#18,#19,#1a,#1b
  db #24,#25,#26,#27,#30,#31,#32,#33
  db #1c,#1d,#1e,#1f,#09,#5d,#0b,#5f
  db #34,#35,#36,#37,#21,#75,#23,#77
  db #2c,#2d,#2e,#2f,#38,#39,#3a,#3b
  db #06,#07,#ae,#af,#12,#13,#ba,#bb
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #4c,#4d,#4e,#4f,#58,#59,#5a,#5b
  db #64,#65,#66,#67,#70,#71,#72,#73
  db #5c,#5d,#5e,#5f,#49,#5d,#4b,#5f
  db #74,#75,#76,#77,#61,#75,#63,#77
  db #6c,#6d,#6e,#6f,#78,#79,#7a,#7b
  db #46,#47,#ee,#ef,#52,#53,#fa,#fb
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #48,#49,#4a,#4b,#4c,#4d,#4e,#4f
  db #60,#61,#62,#63,#64,#65,#66,#67
  db #58,#59,#5a,#5b,#5c,#5d,#5e,#5f
  db #70,#71,#72,#73,#74,#75,#76,#77
  db #68,#69,#6a,#6b,#6c,#6d,#6e,#6f
  db #42,#43,#ea,#eb,#46,#47,#ee,#ef
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #0c,#0d,#0e,#0f,#18,#19,#1a,#1b
  db #24,#25,#26,#27,#30,#31,#32,#33
  db #1c,#1d,#1e,#1f,#09,#5d,#0b,#5f
  db #34,#35,#36,#37,#21,#75,#23,#77
  db #2c,#2d,#2e,#2f,#38,#39,#3a,#3b
  db #06,#07,#ae,#af,#12,#13,#ba,#bb
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #c8,#c9,#ca,#cb,#cc,#cd,#ce,#cf
  db #e0,#e1,#e2,#e3,#e4,#e5,#e6,#e7
  db #d8,#d9,#da,#db,#dc,#dd,#de,#df
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #e8,#e9,#ea,#eb,#ec,#ed,#ee,#ef
  db #c2,#c3,#ea,#eb,#c6,#c7,#ee,#ef
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #d2,#d3,#fa,#fb,#d6,#d7,#fe,#ff
  db #8c,#8d,#8e,#8f,#98,#99,#9a,#9b
  db #a4,#a5,#a6,#a7,#b0,#b1,#b2,#b3
  db #9c,#9d,#9e,#9f,#89,#dd,#8b,#df
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #ac,#ad,#ae,#af,#b8,#b9,#ba,#bb
  db #86,#87,#ae,#af,#92,#93,#ba,#bb
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #0c,#0d,#0e,#0f,#18,#19,#1a,#1b
  db #24,#25,#26,#27,#30,#31,#32,#33
  db #1c,#1d,#1e,#1f,#09,#5d,#0b,#5f
  db #34,#35,#36,#37,#21,#75,#23,#77
  db #2c,#2d,#2e,#2f,#38,#39,#3a,#3b
  db #06,#07,#ae,#af,#12,#13,#ba,#bb
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #4c,#4d,#4e,#4f,#58,#59,#5a,#5b
  db #64,#65,#66,#67,#70,#71,#72,#73
  db #5c,#5d,#5e,#5f,#49,#5d,#4b,#5f
  db #74,#75,#76,#77,#61,#75,#63,#77
  db #6c,#6d,#6e,#6f,#78,#79,#7a,#7b
  db #46,#47,#ee,#ef,#52,#53,#fa,#fb
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #8c,#8d,#8e,#8f,#98,#99,#9a,#9b
  db #a4,#a5,#a6,#a7,#b0,#b1,#b2,#b3
  db #9c,#9d,#9e,#9f,#89,#dd,#8b,#df
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #ac,#ad,#ae,#af,#b8,#b9,#ba,#bb
  db #86,#87,#ae,#af,#92,#93,#ba,#bb
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #cc,#cd,#ce,#cf,#d8,#d9,#da,#db
  db #e4,#e5,#e6,#e7,#f0,#f1,#f2,#f3
  db #dc,#dd,#de,#df,#c9,#dd,#cb,#df
  db #f4,#f5,#f6,#f7,#e1,#f5,#e3,#f7
  db #ec,#ed,#ee,#ef,#f8,#f9,#fa,#fb
  db #c6,#c7,#ee,#ef,#d2,#d3,#fa,#fb
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #4c,#4d,#4e,#4f,#58,#59,#5a,#5b
  db #64,#65,#66,#67,#70,#71,#72,#73
  db #5c,#5d,#5e,#5f,#49,#5d,#4b,#5f
  db #74,#75,#76,#77,#61,#75,#63,#77
  db #6c,#6d,#6e,#6f,#78,#79,#7a,#7b
  db #46,#47,#ee,#ef,#52,#53,#fa,#fb
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #18,#19,#1a,#1b,#1c,#1d,#1e,#1f
  db #30,#31,#32,#33,#34,#35,#36,#37
  db #09,#5d,#0b,#5f,#0d,#5d,#0f,#5f
  db #21,#75,#23,#77,#25,#75,#27,#77
  db #38,#39,#3a,#3b,#3c,#3d,#3e,#3f
  db #12,#13,#ba,#bb,#16,#17,#be,#bf
  db #29,#7d,#2b,#7f,#2d,#7d,#2f,#7f
  db #03,#57,#ab,#ff,#07,#57,#af,#ff
  db #cc,#cd,#ce,#cf,#d8,#d9,#da,#db
  db #e4,#e5,#e6,#e7,#f0,#f1,#f2,#f3
  db #dc,#dd,#de,#df,#c9,#dd,#cb,#df
  db #f4,#f5,#f6,#f7,#e1,#f5,#e3,#f7
  db #ec,#ed,#ee,#ef,#f8,#f9,#fa,#fb
  db #c6,#c7,#ee,#ef,#d2,#d3,#fa,#fb
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #98,#99,#9a,#9b,#9c,#9d,#9e,#9f
  db #b0,#b1,#b2,#b3,#b4,#b5,#b6,#b7
  db #89,#dd,#8b,#df,#8d,#dd,#8f,#df
  db #a1,#f5,#a3,#f7,#a5,#f5,#a7,#f7
  db #b8,#b9,#ba,#bb,#bc,#bd,#be,#bf
  db #92,#93,#ba,#bb,#96,#97,#be,#bf
  db #a9,#fd,#ab,#ff,#ad,#fd,#af,#ff
  db #83,#d7,#ab,#ff,#87,#d7,#af,#ff
  db #8c,#8d,#8e,#8f,#98,#99,#9a,#9b
  db #a4,#a5,#a6,#a7,#b0,#b1,#b2,#b3
  db #9c,#9d,#9e,#9f,#89,#dd,#8b,#df
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #ac,#ad,#ae,#af,#b8,#b9,#ba,#bb
  db #86,#87,#ae,#af,#92,#93,#ba,#bb
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #cc,#cd,#ce,#cf,#d8,#d9,#da,#db
  db #e4,#e5,#e6,#e7,#f0,#f1,#f2,#f3
  db #dc,#dd,#de,#df,#c9,#dd,#cb,#df
  db #f4,#f5,#f6,#f7,#e1,#f5,#e3,#f7
  db #ec,#ed,#ee,#ef,#f8,#f9,#fa,#fb
  db #c6,#c7,#ee,#ef,#d2,#d3,#fa,#fb
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #24,#25,#26,#27,#30,#31,#32,#33
  db #2c,#2d,#2e,#2f,#38,#39,#3a,#3b
  db #34,#35,#36,#37,#21,#75,#23,#77
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #06,#07,#ae,#af,#12,#13,#ba,#bb
  db #0e,#0f,#ae,#af,#1a,#1b,#ba,#bb
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #1e,#1f,#be,#bf,#0b,#5f,#ab,#ff
  db #64,#65,#66,#67,#70,#71,#72,#73
  db #6c,#6d,#6e,#6f,#78,#79,#7a,#7b
  db #74,#75,#76,#77,#61,#75,#63,#77
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #46,#47,#ee,#ef,#52,#53,#fa,#fb
  db #4e,#4f,#ee,#ef,#5a,#5b,#fa,#fb
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #5e,#5f,#fe,#ff,#4b,#5f,#eb,#ff
  db #cc,#cd,#ce,#cf,#d8,#d9,#da,#db
  db #e4,#e5,#e6,#e7,#f0,#f1,#f2,#f3
  db #dc,#dd,#de,#df,#c9,#dd,#cb,#df
  db #f4,#f5,#f6,#f7,#e1,#f5,#e3,#f7
  db #ec,#ed,#ee,#ef,#f8,#f9,#fa,#fb
  db #c6,#c7,#ee,#ef,#d2,#d3,#fa,#fb
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #98,#99,#9a,#9b,#9c,#9d,#9e,#9f
  db #b0,#b1,#b2,#b3,#b4,#b5,#b6,#b7
  db #89,#dd,#8b,#df,#8d,#dd,#8f,#df
  db #a1,#f5,#a3,#f7,#a5,#f5,#a7,#f7
  db #b8,#b9,#ba,#bb,#bc,#bd,#be,#bf
  db #92,#93,#ba,#bb,#96,#97,#be,#bf
  db #a9,#fd,#ab,#ff,#ad,#fd,#af,#ff
  db #83,#d7,#ab,#ff,#87,#d7,#af,#ff
  db #64,#65,#66,#67,#70,#71,#72,#73
  db #6c,#6d,#6e,#6f,#78,#79,#7a,#7b
  db #74,#75,#76,#77,#61,#75,#63,#77
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #46,#47,#ee,#ef,#52,#53,#fa,#fb
  db #4e,#4f,#ee,#ef,#5a,#5b,#fa,#fb
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #5e,#5f,#fe,#ff,#4b,#5f,#eb,#ff
  db #30,#31,#32,#33,#34,#35,#36,#37
  db #38,#39,#3a,#3b,#3c,#3d,#3e,#3f
  db #21,#75,#23,#77,#25,#75,#27,#77
  db #29,#7d,#2b,#7f,#2d,#7d,#2f,#7f
  db #12,#13,#ba,#bb,#16,#17,#be,#bf
  db #1a,#1b,#ba,#bb,#1e,#1f,#be,#bf
  db #03,#57,#ab,#ff,#07,#57,#af,#ff
  db #0b,#5f,#ab,#ff,#0f,#5f,#af,#ff
  db #98,#99,#9a,#9b,#9c,#9d,#9e,#9f
  db #b0,#b1,#b2,#b3,#b4,#b5,#b6,#b7
  db #89,#dd,#8b,#df,#8d,#dd,#8f,#df
  db #a1,#f5,#a3,#f7,#a5,#f5,#a7,#f7
  db #b8,#b9,#ba,#bb,#bc,#bd,#be,#bf
  db #92,#93,#ba,#bb,#96,#97,#be,#bf
  db #a9,#fd,#ab,#ff,#ad,#fd,#af,#ff
  db #83,#d7,#ab,#ff,#87,#d7,#af,#ff
  db #d8,#d9,#da,#db,#dc,#dd,#de,#df
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #c9,#dd,#cb,#df,#cd,#dd,#cf,#df
  db #e1,#f5,#e3,#f7,#e5,#f5,#e7,#f7
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #d2,#d3,#fa,#fb,#d6,#d7,#fe,#ff
  db #e9,#fd,#eb,#ff,#ed,#fd,#ef,#ff
  db #c3,#d7,#eb,#ff,#c7,#d7,#ef,#ff
  db #30,#31,#32,#33,#34,#35,#36,#37
  db #38,#39,#3a,#3b,#3c,#3d,#3e,#3f
  db #21,#75,#23,#77,#25,#75,#27,#77
  db #29,#7d,#2b,#7f,#2d,#7d,#2f,#7f
  db #12,#13,#ba,#bb,#16,#17,#be,#bf
  db #1a,#1b,#ba,#bb,#1e,#1f,#be,#bf
  db #03,#57,#ab,#ff,#07,#57,#af,#ff
  db #0b,#5f,#ab,#ff,#0f,#5f,#af,#ff
  db #70,#71,#72,#73,#74,#75,#76,#77
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #61,#75,#63,#77,#65,#75,#67,#77
  db #69,#7d,#6b,#7f,#6d,#7d,#6f,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #5a,#5b,#fa,#fb,#5e,#5f,#fe,#ff
  db #43,#57,#eb,#ff,#47,#57,#ef,#ff
  db #4b,#5f,#eb,#ff,#4f,#5f,#ef,#ff
  db #64,#65,#66,#67,#70,#71,#72,#73
  db #6c,#6d,#6e,#6f,#78,#79,#7a,#7b
  db #74,#75,#76,#77,#61,#75,#63,#77
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #46,#47,#ee,#ef,#52,#53,#fa,#fb
  db #4e,#4f,#ee,#ef,#5a,#5b,#fa,#fb
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #5e,#5f,#fe,#ff,#4b,#5f,#eb,#ff
  db #30,#31,#32,#33,#34,#35,#36,#37
  db #38,#39,#3a,#3b,#3c,#3d,#3e,#3f
  db #21,#75,#23,#77,#25,#75,#27,#77
  db #29,#7d,#2b,#7f,#2d,#7d,#2f,#7f
  db #12,#13,#ba,#bb,#16,#17,#be,#bf
  db #1a,#1b,#ba,#bb,#1e,#1f,#be,#bf
  db #03,#57,#ab,#ff,#07,#57,#af,#ff
  db #0b,#5f,#ab,#ff,#0f,#5f,#af,#ff
  db #e4,#e5,#e6,#e7,#f0,#f1,#f2,#f3
  db #ec,#ed,#ee,#ef,#f8,#f9,#fa,#fb
  db #f4,#f5,#f6,#f7,#e1,#f5,#e3,#f7
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #c6,#c7,#ee,#ef,#d2,#d3,#fa,#fb
  db #ce,#cf,#ee,#ef,#da,#db,#fa,#fb
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #de,#df,#fe,#ff,#cb,#df,#eb,#ff
  db #b0,#b1,#b2,#b3,#b4,#b5,#b6,#b7
  db #b8,#b9,#ba,#bb,#bc,#bd,#be,#bf
  db #a1,#f5,#a3,#f7,#a5,#f5,#a7,#f7
  db #a9,#fd,#ab,#ff,#ad,#fd,#af,#ff
  db #92,#93,#ba,#bb,#96,#97,#be,#bf
  db #9a,#9b,#ba,#bb,#9e,#9f,#be,#bf
  db #83,#d7,#ab,#ff,#87,#d7,#af,#ff
  db #8b,#df,#ab,#ff,#8f,#df,#af,#ff
  db #30,#31,#32,#33,#34,#35,#36,#37
  db #38,#39,#3a,#3b,#3c,#3d,#3e,#3f
  db #21,#75,#23,#77,#25,#75,#27,#77
  db #29,#7d,#2b,#7f,#2d,#7d,#2f,#7f
  db #12,#13,#ba,#bb,#16,#17,#be,#bf
  db #1a,#1b,#ba,#bb,#1e,#1f,#be,#bf
  db #03,#57,#ab,#ff,#07,#57,#af,#ff
  db #0b,#5f,#ab,#ff,#0f,#5f,#af,#ff
  db #70,#71,#72,#73,#74,#75,#76,#77
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #61,#75,#63,#77,#65,#75,#67,#77
  db #69,#7d,#6b,#7f,#6d,#7d,#6f,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #5a,#5b,#fa,#fb,#5e,#5f,#fe,#ff
  db #43,#57,#eb,#ff,#47,#57,#ef,#ff
  db #4b,#5f,#eb,#ff,#4f,#5f,#ef,#ff
  db #b0,#b1,#b2,#b3,#b4,#b5,#b6,#b7
  db #b8,#b9,#ba,#bb,#bc,#bd,#be,#bf
  db #a1,#f5,#a3,#f7,#a5,#f5,#a7,#f7
  db #a9,#fd,#ab,#ff,#ad,#fd,#af,#ff
  db #92,#93,#ba,#bb,#96,#97,#be,#bf
  db #9a,#9b,#ba,#bb,#9e,#9f,#be,#bf
  db #83,#d7,#ab,#ff,#87,#d7,#af,#ff
  db #8b,#df,#ab,#ff,#8f,#df,#af,#ff
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #e1,#f5,#e3,#f7,#e5,#f5,#e7,#f7
  db #e9,#fd,#eb,#ff,#ed,#fd,#ef,#ff
  db #d2,#d3,#fa,#fb,#d6,#d7,#fe,#ff
  db #da,#db,#fa,#fb,#de,#df,#fe,#ff
  db #c3,#d7,#eb,#ff,#c7,#d7,#ef,#ff
  db #cb,#df,#eb,#ff,#cf,#df,#ef,#ff
  db #70,#71,#72,#73,#74,#75,#76,#77
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #61,#75,#63,#77,#65,#75,#67,#77
  db #69,#7d,#6b,#7f,#6d,#7d,#6f,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #5a,#5b,#fa,#fb,#5e,#5f,#fe,#ff
  db #43,#57,#eb,#ff,#47,#57,#ef,#ff
  db #4b,#5f,#eb,#ff,#4f,#5f,#ef,#ff
  db #34,#35,#36,#37,#21,#75,#23,#77
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #25,#75,#27,#77,#31,#75,#33,#77
  db #2d,#7d,#2f,#7f,#39,#7d,#3b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #1e,#1f,#be,#bf,#0b,#5f,#ab,#ff
  db #07,#57,#af,#ff,#13,#57,#bb,#ff
  db #0f,#5f,#af,#ff,#1b,#5f,#bb,#ff
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #e1,#f5,#e3,#f7,#e5,#f5,#e7,#f7
  db #e9,#fd,#eb,#ff,#ed,#fd,#ef,#ff
  db #d2,#d3,#fa,#fb,#d6,#d7,#fe,#ff
  db #da,#db,#fa,#fb,#de,#df,#fe,#ff
  db #c3,#d7,#eb,#ff,#c7,#d7,#ef,#ff
  db #cb,#df,#eb,#ff,#cf,#df,#ef,#ff
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #a5,#f5,#a7,#f7,#b1,#f5,#b3,#f7
  db #ad,#fd,#af,#ff,#b9,#fd,#bb,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #9e,#9f,#be,#bf,#8b,#df,#ab,#ff
  db #87,#d7,#af,#ff,#93,#d7,#bb,#ff
  db #8f,#df,#af,#ff,#9b,#df,#bb,#ff
  db #b0,#b1,#b2,#b3,#b4,#b5,#b6,#b7
  db #b8,#b9,#ba,#bb,#bc,#bd,#be,#bf
  db #a1,#f5,#a3,#f7,#a5,#f5,#a7,#f7
  db #a9,#fd,#ab,#ff,#ad,#fd,#af,#ff
  db #92,#93,#ba,#bb,#96,#97,#be,#bf
  db #9a,#9b,#ba,#bb,#9e,#9f,#be,#bf
  db #83,#d7,#ab,#ff,#87,#d7,#af,#ff
  db #8b,#df,#ab,#ff,#8f,#df,#af,#ff
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #e1,#f5,#e3,#f7,#e5,#f5,#e7,#f7
  db #e9,#fd,#eb,#ff,#ed,#fd,#ef,#ff
  db #d2,#d3,#fa,#fb,#d6,#d7,#fe,#ff
  db #da,#db,#fa,#fb,#de,#df,#fe,#ff
  db #c3,#d7,#eb,#ff,#c7,#d7,#ef,#ff
  db #cb,#df,#eb,#ff,#cf,#df,#ef,#ff
  db #38,#39,#3a,#3b,#3c,#3d,#3e,#3f
  db #12,#13,#ba,#bb,#16,#17,#be,#bf
  db #29,#7d,#2b,#7f,#2d,#7d,#2f,#7f
  db #03,#57,#ab,#ff,#07,#57,#af,#ff
  db #1a,#1b,#ba,#bb,#1e,#1f,#be,#bf
  db #32,#33,#ba,#bb,#36,#37,#be,#bf
  db #0b,#5f,#ab,#ff,#0f,#5f,#af,#ff
  db #23,#77,#ab,#ff,#27,#77,#af,#ff
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #69,#7d,#6b,#7f,#6d,#7d,#6f,#7f
  db #43,#57,#eb,#ff,#47,#57,#ef,#ff
  db #5a,#5b,#fa,#fb,#5e,#5f,#fe,#ff
  db #72,#73,#fa,#fb,#76,#77,#fe,#ff
  db #4b,#5f,#eb,#ff,#4f,#5f,#ef,#ff
  db #63,#77,#eb,#ff,#67,#77,#ef,#ff
  db #f0,#f1,#f2,#f3,#f4,#f5,#f6,#f7
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #e1,#f5,#e3,#f7,#e5,#f5,#e7,#f7
  db #e9,#fd,#eb,#ff,#ed,#fd,#ef,#ff
  db #d2,#d3,#fa,#fb,#d6,#d7,#fe,#ff
  db #da,#db,#fa,#fb,#de,#df,#fe,#ff
  db #c3,#d7,#eb,#ff,#c7,#d7,#ef,#ff
  db #cb,#df,#eb,#ff,#cf,#df,#ef,#ff
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #a5,#f5,#a7,#f7,#b1,#f5,#b3,#f7
  db #ad,#fd,#af,#ff,#b9,#fd,#bb,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #9e,#9f,#be,#bf,#8b,#df,#ab,#ff
  db #87,#d7,#af,#ff,#93,#d7,#bb,#ff
  db #8f,#df,#af,#ff,#9b,#df,#bb,#ff
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #69,#7d,#6b,#7f,#6d,#7d,#6f,#7f
  db #43,#57,#eb,#ff,#47,#57,#ef,#ff
  db #5a,#5b,#fa,#fb,#5e,#5f,#fe,#ff
  db #72,#73,#fa,#fb,#76,#77,#fe,#ff
  db #4b,#5f,#eb,#ff,#4f,#5f,#ef,#ff
  db #63,#77,#eb,#ff,#67,#77,#ef,#ff
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #2d,#7d,#2f,#7f,#39,#7d,#3b,#7f
  db #07,#57,#af,#ff,#13,#57,#bb,#ff
  db #1e,#1f,#be,#bf,#0b,#5f,#ab,#ff
  db #36,#37,#be,#bf,#23,#77,#ab,#ff
  db #0f,#5f,#af,#ff,#1b,#5f,#bb,#ff
  db #27,#77,#af,#ff,#33,#77,#bb,#ff
  db #b4,#b5,#b6,#b7,#a1,#f5,#a3,#f7
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #a5,#f5,#a7,#f7,#b1,#f5,#b3,#f7
  db #ad,#fd,#af,#ff,#b9,#fd,#bb,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #9e,#9f,#be,#bf,#8b,#df,#ab,#ff
  db #87,#d7,#af,#ff,#93,#d7,#bb,#ff
  db #8f,#df,#af,#ff,#9b,#df,#bb,#ff
  db #f4,#f5,#f6,#f7,#e1,#f5,#e3,#f7
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #e5,#f5,#e7,#f7,#f1,#f5,#f3,#f7
  db #ed,#fd,#ef,#ff,#f9,#fd,#fb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #de,#df,#fe,#ff,#cb,#df,#eb,#ff
  db #c7,#d7,#ef,#ff,#d3,#d7,#fb,#ff
  db #cf,#df,#ef,#ff,#db,#df,#fb,#ff
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #2d,#7d,#2f,#7f,#39,#7d,#3b,#7f
  db #07,#57,#af,#ff,#13,#57,#bb,#ff
  db #1e,#1f,#be,#bf,#0b,#5f,#ab,#ff
  db #36,#37,#be,#bf,#23,#77,#ab,#ff
  db #0f,#5f,#af,#ff,#1b,#5f,#bb,#ff
  db #27,#77,#af,#ff,#33,#77,#bb,#ff
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #6d,#7d,#6f,#7f,#79,#7d,#7b,#7f
  db #47,#57,#ef,#ff,#53,#57,#fb,#ff
  db #5e,#5f,#fe,#ff,#4b,#5f,#eb,#ff
  db #76,#77,#fe,#ff,#63,#77,#eb,#ff
  db #4f,#5f,#ef,#ff,#5b,#5f,#fb,#ff
  db #67,#77,#ef,#ff,#73,#77,#fb,#ff
  db #78,#79,#7a,#7b,#7c,#7d,#7e,#7f
  db #52,#53,#fa,#fb,#56,#57,#fe,#ff
  db #69,#7d,#6b,#7f,#6d,#7d,#6f,#7f
  db #43,#57,#eb,#ff,#47,#57,#ef,#ff
  db #5a,#5b,#fa,#fb,#5e,#5f,#fe,#ff
  db #72,#73,#fa,#fb,#76,#77,#fe,#ff
  db #4b,#5f,#eb,#ff,#4f,#5f,#ef,#ff
  db #63,#77,#eb,#ff,#67,#77,#ef,#ff
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #2d,#7d,#2f,#7f,#39,#7d,#3b,#7f
  db #07,#57,#af,#ff,#13,#57,#bb,#ff
  db #1e,#1f,#be,#bf,#0b,#5f,#ab,#ff
  db #36,#37,#be,#bf,#23,#77,#ab,#ff
  db #0f,#5f,#af,#ff,#1b,#5f,#bb,#ff
  db #27,#77,#af,#ff,#33,#77,#bb,#ff
  db #f8,#f9,#fa,#fb,#fc,#fd,#fe,#ff
  db #d2,#d3,#fa,#fb,#d6,#d7,#fe,#ff
  db #e9,#fd,#eb,#ff,#ed,#fd,#ef,#ff
  db #c3,#d7,#eb,#ff,#c7,#d7,#ef,#ff
  db #da,#db,#fa,#fb,#de,#df,#fe,#ff
  db #f2,#f3,#fa,#fb,#f6,#f7,#fe,#ff
  db #cb,#df,#eb,#ff,#cf,#df,#ef,#ff
  db #e3,#f7,#eb,#ff,#e7,#f7,#ef,#ff
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #ad,#fd,#af,#ff,#b9,#fd,#bb,#ff
  db #87,#d7,#af,#ff,#93,#d7,#bb,#ff
  db #9e,#9f,#be,#bf,#8b,#df,#ab,#ff
  db #b6,#b7,#be,#bf,#a3,#f7,#ab,#ff
  db #8f,#df,#af,#ff,#9b,#df,#bb,#ff
  db #a7,#f7,#af,#ff,#b3,#f7,#bb,#ff
  db #3c,#3d,#3e,#3f,#29,#7d,#2b,#7f
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #2d,#7d,#2f,#7f,#39,#7d,#3b,#7f
  db #07,#57,#af,#ff,#13,#57,#bb,#ff
  db #1e,#1f,#be,#bf,#0b,#5f,#ab,#ff
  db #36,#37,#be,#bf,#23,#77,#ab,#ff
  db #0f,#5f,#af,#ff,#1b,#5f,#bb,#ff
  db #27,#77,#af,#ff,#33,#77,#bb,#ff
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #6d,#7d,#6f,#7f,#79,#7d,#7b,#7f
  db #47,#57,#ef,#ff,#53,#57,#fb,#ff
  db #5e,#5f,#fe,#ff,#4b,#5f,#eb,#ff
  db #76,#77,#fe,#ff,#63,#77,#eb,#ff
  db #4f,#5f,#ef,#ff,#5b,#5f,#fb,#ff
  db #67,#77,#ef,#ff,#73,#77,#fb,#ff
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #ad,#fd,#af,#ff,#b9,#fd,#bb,#ff
  db #87,#d7,#af,#ff,#93,#d7,#bb,#ff
  db #9e,#9f,#be,#bf,#8b,#df,#ab,#ff
  db #b6,#b7,#be,#bf,#a3,#f7,#ab,#ff
  db #8f,#df,#af,#ff,#9b,#df,#bb,#ff
  db #a7,#f7,#af,#ff,#b3,#f7,#bb,#ff
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #ed,#fd,#ef,#ff,#f9,#fd,#fb,#ff
  db #c7,#d7,#ef,#ff,#d3,#d7,#fb,#ff
  db #de,#df,#fe,#ff,#cb,#df,#eb,#ff
  db #f6,#f7,#fe,#ff,#e3,#f7,#eb,#ff
  db #cf,#df,#ef,#ff,#db,#df,#fb,#ff
  db #e7,#f7,#ef,#ff,#f3,#f7,#fb,#ff
  db #7c,#7d,#7e,#7f,#69,#7d,#6b,#7f
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #6d,#7d,#6f,#7f,#79,#7d,#7b,#7f
  db #47,#57,#ef,#ff,#53,#57,#fb,#ff
  db #5e,#5f,#fe,#ff,#4b,#5f,#eb,#ff
  db #76,#77,#fe,#ff,#63,#77,#eb,#ff
  db #4f,#5f,#ef,#ff,#5b,#5f,#fb,#ff
  db #67,#77,#ef,#ff,#73,#77,#fb,#ff
  db #29,#7d,#2b,#7f,#2d,#7d,#2f,#7f
  db #03,#57,#ab,#ff,#07,#57,#af,#ff
  db #39,#7d,#3b,#7f,#3d,#7d,#3f,#7f
  db #13,#57,#bb,#ff,#17,#57,#bf,#ff
  db #0b,#5f,#ab,#ff,#0f,#5f,#af,#ff
  db #23,#77,#ab,#ff,#27,#77,#af,#ff
  db #1b,#5f,#bb,#ff,#1f,#5f,#bf,#ff
  db #33,#77,#bb,#ff,#37,#77,#bf,#ff
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #ed,#fd,#ef,#ff,#f9,#fd,#fb,#ff
  db #c7,#d7,#ef,#ff,#d3,#d7,#fb,#ff
  db #de,#df,#fe,#ff,#cb,#df,#eb,#ff
  db #f6,#f7,#fe,#ff,#e3,#f7,#eb,#ff
  db #cf,#df,#ef,#ff,#db,#df,#fb,#ff
  db #e7,#f7,#ef,#ff,#f3,#f7,#fb,#ff
  db #a9,#fd,#ab,#ff,#ad,#fd,#af,#ff
  db #83,#d7,#ab,#ff,#87,#d7,#af,#ff
  db #b9,#fd,#bb,#ff,#bd,#fd,#bf,#ff
  db #93,#d7,#bb,#ff,#97,#d7,#bf,#ff
  db #8b,#df,#ab,#ff,#8f,#df,#af,#ff
  db #a3,#f7,#ab,#ff,#a7,#f7,#af,#ff
  db #9b,#df,#bb,#ff,#9f,#df,#bf,#ff
  db #b3,#f7,#bb,#ff,#b7,#f7,#bf,#ff
  db #bc,#bd,#be,#bf,#a9,#fd,#ab,#ff
  db #96,#97,#be,#bf,#83,#d7,#ab,#ff
  db #ad,#fd,#af,#ff,#b9,#fd,#bb,#ff
  db #87,#d7,#af,#ff,#93,#d7,#bb,#ff
  db #9e,#9f,#be,#bf,#8b,#df,#ab,#ff
  db #b6,#b7,#be,#bf,#a3,#f7,#ab,#ff
  db #8f,#df,#af,#ff,#9b,#df,#bb,#ff
  db #a7,#f7,#af,#ff,#b3,#f7,#bb,#ff
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #ed,#fd,#ef,#ff,#f9,#fd,#fb,#ff
  db #c7,#d7,#ef,#ff,#d3,#d7,#fb,#ff
  db #de,#df,#fe,#ff,#cb,#df,#eb,#ff
  db #f6,#f7,#fe,#ff,#e3,#f7,#eb,#ff
  db #cf,#df,#ef,#ff,#db,#df,#fb,#ff
  db #e7,#f7,#ef,#ff,#f3,#f7,#fb,#ff
  db #16,#17,#be,#bf,#03,#57,#ab,#ff
  db #1e,#1f,#be,#bf,#0b,#5f,#ab,#ff
  db #07,#57,#af,#ff,#13,#57,#bb,#ff
  db #0f,#5f,#af,#ff,#1b,#5f,#bb,#ff
  db #36,#37,#be,#bf,#23,#77,#ab,#ff
  db #3e,#3f,#be,#bf,#2b,#7f,#ab,#ff
  db #27,#77,#af,#ff,#33,#77,#bb,#ff
  db #2f,#7f,#af,#ff,#3b,#7f,#bb,#ff
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #5e,#5f,#fe,#ff,#4b,#5f,#eb,#ff
  db #47,#57,#ef,#ff,#53,#57,#fb,#ff
  db #4f,#5f,#ef,#ff,#5b,#5f,#fb,#ff
  db #76,#77,#fe,#ff,#63,#77,#eb,#ff
  db #7e,#7f,#fe,#ff,#6b,#7f,#eb,#ff
  db #67,#77,#ef,#ff,#73,#77,#fb,#ff
  db #6f,#7f,#ef,#ff,#7b,#7f,#fb,#ff
  db #fc,#fd,#fe,#ff,#e9,#fd,#eb,#ff
  db #d6,#d7,#fe,#ff,#c3,#d7,#eb,#ff
  db #ed,#fd,#ef,#ff,#f9,#fd,#fb,#ff
  db #c7,#d7,#ef,#ff,#d3,#d7,#fb,#ff
  db #de,#df,#fe,#ff,#cb,#df,#eb,#ff
  db #f6,#f7,#fe,#ff,#e3,#f7,#eb,#ff
  db #cf,#df,#ef,#ff,#db,#df,#fb,#ff
  db #e7,#f7,#ef,#ff,#f3,#f7,#fb,#ff
  db #a9,#fd,#ab,#ff,#ad,#fd,#af,#ff
  db #83,#d7,#ab,#ff,#87,#d7,#af,#ff
  db #b9,#fd,#bb,#ff,#bd,#fd,#bf,#ff
  db #93,#d7,#bb,#ff,#97,#d7,#bf,#ff
  db #8b,#df,#ab,#ff,#8f,#df,#af,#ff
  db #a3,#f7,#ab,#ff,#a7,#f7,#af,#ff
  db #9b,#df,#bb,#ff,#9f,#df,#bf,#ff
  db #b3,#f7,#bb,#ff,#b7,#f7,#bf,#ff
  db #56,#57,#fe,#ff,#43,#57,#eb,#ff
  db #5e,#5f,#fe,#ff,#4b,#5f,#eb,#ff
  db #47,#57,#ef,#ff,#53,#57,#fb,#ff
  db #4f,#5f,#ef,#ff,#5b,#5f,#fb,#ff
  db #76,#77,#fe,#ff,#63,#77,#eb,#ff
  db #7e,#7f,#fe,#ff,#6b,#7f,#eb,#ff
  db #67,#77,#ef,#ff,#73,#77,#fb,#ff
  db #6f,#7f,#ef,#ff,#7b,#7f,#fb,#ff
  db #03,#57,#ab,#ff,#07,#57,#af,#ff
  db #0b,#5f,#ab,#ff,#0f,#5f,#af,#ff
  db #13,#57,#bb,#ff,#17,#57,#bf,#ff
  db #1b,#5f,#bb,#ff,#1f,#5f,#bf,#ff
  db #23,#77,#ab,#ff,#27,#77,#af,#ff
  db #2b,#7f,#ab,#ff,#2f,#7f,#af,#ff
  db #33,#77,#bb,#ff,#37,#77,#bf,#ff
  db #3b,#7f,#bb,#ff,#3f,#7f,#bf,#ff