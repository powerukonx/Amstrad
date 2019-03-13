; *****************************************************************************
; * PAL library
; * Code => POWER/UKONX
; *****************************************************************************
IM1_ISR_ADDR              equ &0038


PERIPHERAL_SOFT_RESET_PORT      equ &F8FF


macro mMISC_WAIT us
  ds us, 0
mend

; *****************************************************************************
;
; *****************************************************************************
macro mCOPYSPRITE src,dst,heigth,width,bc26addr
    ld hl,src
    ld de,dst
    ld b,heigth
    push bc
    push de
    ld bc,width
    ldir
    pop de
    ex de,hl
    call bc26addr
    ex de,hl
    pop bc
    djnz $-14
mend


; *****************************************************************************
;
; *****************************************************************************
macro mMEMCPY src,dst,len
    ld hl,src
    ld de,dst
    ld bc,len
    ldir
mend

; *****************************************************************************
;
; *****************************************************************************
macro mMEMCLR startaddr,len  
    ld hl,startaddr
    ld de,startaddr + 1
    ld bc,len - 1
    ld (hl),l
    ldir
mend


; *****************************************************************************
; Save system from &8000 to &FFFF area in C4 bank
; *****************************************************************************
macro mSAVEUPPERSYS adr,bk,cfg
    mPAL_RAM_SELECT bk,cfg
    ld hl,UPPERSYS_BEGINADDR
    ld de,adr
    ld bc,SCREEN_INIT_MEMORYADDR - UPPERSYS_BEGINADDR
    ldir
  mend


; *****************************************************************************
; Save system from &8000 to &FFFF area in C4 bank
; *****************************************************************************
macro mRESTOREEUPPERSYS adr,bk,cfg
    mPAL_RAM_SELECT bk,cfg
    ld hl,adr
    ld de,UPPERSYS_BEGINADDR
    ld bc,SCREEN_INIT_MEMORYADDR - UPPERSYS_BEGINADDR
    ldir
mend


; *****************************************************************************
;
; *****************************************************************************
macro mISR_REMAP remap, save
    ld hl,(IM1_ISR_ADDR)
    ld (save),hl
    ld hl,remap
    ld (IM1_ISR_ADDR),hl
mend


; *****************************************************************************
;
; *****************************************************************************
macro mSP_REMAP remap, save
    ld (save),sp
    ld sp,remap
mend


; *****************************************************************************
; Initialize ST128 song at address addr in bank bk.
; *****************************************************************************
macro mST128_INITSONG adr,bk,cfg
    mPAL_RAM_SELECT bk,cfg
    call adr
mend


; *****************************************************************************
; Play ST128 song at address addr in bank bk.
; *****************************************************************************
macro ST128_PLAY adr,bk,cfg
    mPAL_RAM_SELECT bk,cfg
    call adr
mend


; *****************************************************************************
; Stop ST128 song at address addr in bank bk.
; *****************************************************************************
macro ST128_STOP adr,bk,cfg
    mPAL_RAM_SELECT bk,cfg
    call adr
mend


