; The System Variables (6128 only)
CURRENT_DRIVE_NUMBER      equ &A700
CURRENT_USER_NUMBER       equ &A701

PTR_CURRENT_DRIVER_NUMBER equ &BE7D

; The KERNEL
KL_CHOKE_OFF              equ &BCC8
KL_ROM_WALK               equ &BCCB ; Finds and initializes all background ROMs
KL_INIT_BACK              equ &BCCE ; Finds and initializes a specific background ROM
KL_LOG_EXT                equ &BCD1
KL_FIND_COMMAND           equ &BCD4
KL_NEW_FRAME_FLY          equ &BCD7
KL_ADD_FRAME_FLY          equ &BCDA
KL_DEL_FRAME_FLY          equ &BCDD
KL_NEW_FAST_TICKER        equ &BCE0
KL_ADD_FAST_TICKER        equ &BCE3
KL_DEL_FAST_TICKER        equ &BCE6
KL_ADD_TICKER             equ &BCE9
KL_DEL_TICKER             equ &BCEC
KL_INIT_EVENT             equ &BCEF
KL_EVENT                  equ &BCF2
KL_SYNC_RESET             equ &BCF5
KL_DEL_SYNCHRONOUS        equ &BCF8
KL_NEXT_SYNC              equ &BCFB
KL_DO_SYNC                equ &BCFE
KL_DONE_SYNC              equ &BD01
KL_EVENT_DISABLE          equ &BD04
KL_EVENT_ENABLE           equ &BD07
KL_DISARM_EVENT           equ &BC0A
KL_TIME_PLEASE            equ &BD0D
KL_TIME_SET               equ &BD10

; Low Kernel Jump-block
RESET_ENTRY               equ &0000
LOW_JUMP                  equ &0008
KL_LOW_PCHL               equ &000B
PCBC_INSTRUCTION          equ &000E
SIDE_CALL                 equ &0010
KL_SIDE_PCHL              equ &0013
PCDE_INSTRUCTION          equ &0016
FAR_CALL                  equ &0018
KL_FAR_PCHL               equ &001B
PCHL_INSTRUCTION          equ &001E
RAM_LAM                   equ &0020
KL_FAR_CALL               equ &0023
FIRM_JUMP                 equ &0028
USER_RESTART              equ &0030
INTERRUPT_ENTRY           equ &0038
EXT_INTERRUPT             equ &003B

; High Kernel Jump-block
KL_U_ROM_ENABLE           equ &B900
KL_U_ROM_DISABLE          equ &B903
KL_L_ROM_ENABLE           equ &B906
KL_L_ROM_DISABLE          equ &B909
KL_ROM_RESTORE            equ &B90C
KL_ROM_SELECT             equ &B90F
KL_CURR_SELECTION         equ &B912
KL_PROBE_ROM              equ &B915
KL_ROM_DESELECT           equ &B918
KL_LDIR                   equ &B91B
KL_LDDR                   equ &B91E
KL_POLL_SYNCHRONOUS       equ &B921
KL_SCAN_NEEDED            equ &B92A

; The Key Manager

; The Text VDU
TXT_VDU_DISABLE           equ &BB57 ;Prevents characters from being printed to the current stream
TXT_OUTPUT	              equ &BB5A

; The Graphics VDU

; The Screen Pack

SCR_INITIALIZE	          equ &BBFF
SCR_RESET	                equ &BC02
SCR_SET_OFFSET	          equ &BC05
SCR_SET_BASE	            equ &BC08
SCR_GET_LOCATION          equ &BC0B
SCR_SET_MODE              equ &BC0E
SCR_GET_MODE              equ &BC11
SCR_CLEAR                 equ &BC14
SCR_CHAR_LIMITS           equ &BC17
SCR_CHAR_POSITION         equ &BC1A
SCR_DOT_POSITION          equ &BC1D
SCR_NEXT_BYTE             equ &BC20
SCR_PREV_BYTE             equ &BC23
SCR_NEXT_LINE	            equ &BC26
SCR_PREV_LINE             equ &BC29
SCR_INK_ENCODE            equ &BC2C
SCR_INK_DECODE            equ &BC2F
SCR_SET_INK               equ &BC32
SCR_GET_INK               equ &BC35
SCR_SET_BORDER            equ &BC38
SCR_GET_BORDER            equ &BC3B
SCR_SET_FLASHING          equ &BC3E
SCR_GET_FLASHING          equ &BC41
SCR_FIL_BOX               equ &BC44
SCR_FLOOD_BOX             equ &BC47
SCR_CHAR_INVERT           equ &BC4A
SCR_HW_ROLL               equ &BC4D
SCR_SW_ROLL               equ &BC50
SCR_UNPACK                equ &BC53
SCR_REPACK                equ &BC56
SCR_ACCESS                equ &BC59
SCR_PIXELS                equ &BC5C
SCR_HORIZONTAL            equ &BC5F
SCR_VERTICAL              equ &BC62

; The Cassette/AMSDOS manager

; AMSDOS and BIOS Firmware
CAS_INITIALISE            equ &BC65
CAS_SET_SPEED             equ &BC68
CAS_NOISY                 equ &BC6B
CAS_START_MOTOR           equ &BC6E
CAS_STOP_MOTOR            equ &BC71
CAS_RESTORE_MOTOR         equ &BC74
CAS_IN_OPEN               equ &BC77
CAS_IN_CLOSE              equ &BC7A
CAS_IN_ABANDON            equ &BC7D
CAS_IN_CHAR               equ &BC80
CAS_IN_DIRECT             equ &BC83
CAS_RETURN                equ &BC86
CAS_TEST_EOF              equ &BC89
CAS_OUT_OPEN              equ &BC8C
CAS_OUT_CLOSE             equ &BC8F
CAS_OUT_ABANDON           equ &BC92
CAS_OUT_CHAR              equ &BC95
CAS_OUT_DIRECT            equ &BC98
CAS_CATALOG               equ &BC9B
CAS_WRITE                 equ &BC9E
CAS_READ                  equ &BCA1
CAS_CHECK                 equ &BCA4

; The Sound Manager

; The Machine Pack
MC_BOOT_PROGRAM           equ &BD13
MC_START_PROGRAM          equ &BD16
MC_WAIT_FLYBACK           equ &BD19
MC_SET_MODE               equ &BD1C
MC_SCREEN_OFFSET          equ &BD1F

; 664 and 6128 only

; The Firmware Indirections

; The Maths Firmware

; Maths Subroutines for the 464 only





























