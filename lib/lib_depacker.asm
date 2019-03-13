; *****************************************************************************
; Bitbuster v1.2 unpack (Team bomba)
; Entry
;    HL = Source address
;    DE = Dest address
; *****************************************************************************
Depacker_Bitbuster12
 
    di
    exx
    push af
    push bc
    push de
    push hl
    exx

    call Bitbuster12_Depack

    exx
    pop hl
    pop de
    pop bc
    pop af
    exx
    ei
    ret


Bitbuster12_Depack   

; Passe les 4 premiers octets

    inc hl:inc hl:inc hl:inc hl


    ld  a,128

    exx
    ld  de,1
    exx
depack_loop:
    call GET_BIT_FROM_BITSTREAM
    jr  c,output_compressed
    ldi
    jr  depack_loop

output_compressed:
    ld  c,(hl)
    inc  hl

output_match:
    ld  b,0
    bit  7,c
    jr  z,output_match1

    call GET_BIT_FROM_BITSTREAM
    rl  b
    call GET_BIT_FROM_BITSTREAM
    rl  b
    call GET_BIT_FROM_BITSTREAM
    rl  b
    call GET_BIT_FROM_BITSTREAM

    jr  c,output_match1
    res  7,c
output_match1:
    inc  bc
    exx
    ld  h,d
    ld  l,e
    ld  b,e
get_gamma_value_size:
    exx
    call GET_BIT_FROM_BITSTREAM
    exx
    jr  nc,get_gamma_value_size_end
    inc  b
    jr  get_gamma_value_size

get_gamma_value_bits:
    exx
    call GET_BIT_FROM_BITSTREAM
    exx
  
    adc  hl,hl  
get_gamma_value_size_end:
    djnz  get_gamma_value_bits

get_gamma_value_end:
    inc  hl
    exx
    ret c
    push  hl
    exx
    push  hl
    exx
    ld  h,d
    ld  l,e
    sbc  hl,bc
    pop  bc
    ldir
    pop  hl
    call GET_BIT_FROM_BITSTREAM
    jr  c,output_compressed
    ldi
    call GET_BIT_FROM_BITSTREAM
    jr  c,output_compressed
    ldi
    jr  depack_loop

GET_BIT_FROM_BITSTREAM
    add  a,a
    ret nz

    ld  a,(hl)
    inc  hl
    rla
    ret