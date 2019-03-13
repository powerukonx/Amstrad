; *****************************************************************************
; Firmware library (only 6128)
; Code => POWER/UKONX
;
; All firmwares infos take from 
;            www.cantrell.org.uk/david/tech/cpc/cpc-firmware/
;
; *****************************************************************************
    nolist

; The System Variables.
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
ROM_LOWER_FOREGROUND_AREA equ &0040
BASIC_WORKING_AREA        equ &0170

AMSDOS_CHAINING_BLOCK     equ &A6FC
ADDR_NEXT_BLOCK_CHAIN     equ &A6FC
ROM_SELECT_ADDR           equ &A6FE

CURRENT_DRIVE_NUMBER      equ &A700 ; 0 = A, 1 = B
CURRENT_USER_NUMBER       equ &A701

OPENIN_FLAG               equ &A708 ; FF = closed, <> FF = opened
OPENOUT_FLAG              equ &A72C ; FF = closed, <> FF = opened

PTR_CURRENT_DRIVER_NUMBER equ &BE7D

; High Kernel Jump-block

;  -----------------------------------------------------------------------------
; | Action | Enables the current upper ROM                                      |
;  -----------------------------------------------------------------------------
; | Entry   | No entry conditions                                                |
;  -----------------------------------------------------------------------------
; | Exit   | A contains the previous state of the ROM, the flags are corrupt,   |
; |        | and all other registers are preserved.                             |
;  -----------------------------------------------------------------------------
; | Notes   | After this routine has been called, all reading from addresses     |
; |        | between &C000 and &FFFF refers to the upper ROM, and not the top   |
; |        | 16K of RAM which is usually the screen memory; any writing to these|
; |        | addresses still affects the RAM as, by its nature, ROM cannot be   |
; |        | written to.                                                        |
;  -----------------------------------------------------------------------------
KL_U_ROM_ENABLE           equ &B900

;  -----------------------------------------------------------------------------
; | Action | |
;  -----------------------------------------------------------------------------
; | Entry   |  |
;  -----------------------------------------------------------------------------
; | Exit   |  |
;  -----------------------------------------------------------------------------
; | Notes   |  |
;  -----------------------------------------------------------------------------
KL_U_ROM_DISABLE          equ &B903

;  -----------------------------------------------------------------------------
; | Action | |
;  -----------------------------------------------------------------------------
; | Entry   |  |
;  -----------------------------------------------------------------------------
; | Exit   |  |
;  -----------------------------------------------------------------------------
; | Notes   |  |
;  -----------------------------------------------------------------------------
KL_L_ROM_ENABLE           equ &B906

;  -----------------------------------------------------------------------------
; | Action | |
;  -----------------------------------------------------------------------------
; | Entry   |  |
;  -----------------------------------------------------------------------------
; | Exit   |  |
;  -----------------------------------------------------------------------------
; | Notes   |  |
;  -----------------------------------------------------------------------------
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
KM_INITIALISE             equ &BB00
KM_RESET                  equ &BB03
KM_WAIT_CHAR              equ &BB06
KM_READ_CHAR              equ &BB09
KM_CHAR_RETURN            equ &BB0C
KM_SET_EXPAND             equ &BB0F
KM_GET_EXPAND             equ &BB12
KM_EXP_BUFFER             equ &BB15
KM_WAIT_KEY               equ &BB18
KM_READ_KEY               equ &BB1B
KM_TEST_KEY               equ &BB1E
KM_GET_STATE              equ &BB21
KM_GET_JOYSTICK           equ &BB24
KM_SET_TRANSLATE          equ &BB27
KM_GET_TRANSLATE          equ &BB2A
KM_SET_SHIFT              equ &BB2D
KM_GET_SHIFT              equ &BB30
KM_SET_CONTROL            equ &BB33
KM_GET_CONTROL            equ &BB36
KM_SET_REPEAT             equ &BB39
KM_GET_REPEAT             equ &BB3C
KM_SET_DELAY              equ &BB3F
KM_GET_DELAY              equ &BB42
KM_ARM_BREAK              equ &BB45
KM_DISARM_BREAK           equ &BB48
KM_BREAK_EVENT            equ &BB4B

; The Text VDU
TXT_INITIALISE            equ &BB4E
TXT_RESET                 equ &BB51
TXT_VDU_ENABLE            equ &BB54
TXT_VDU_DISABLE           equ &BB57 ;Prevents characters from being printed to the current stream
TXT_OUTPUT                equ &BB5A
TXT_WR_CHAR               equ &BB5D
TXT_RD_CHAR               equ &BB60
TXT_SET_GRAPHIC           equ &BB63
TXT_WIN_ENABLE            equ &BB66
TXT_GET_WINDOW            equ &BB69
TXT_CLEAR_WINDOW          equ &BB6C
TXT_SET_COLUMN            equ &BB6F
TXT_SET_ROW               equ &BB72
TXT_SET_CURSOR            equ &BB75
TXT_GET_CURSOR            equ &BB78
TXT_CUR_ENABLE            equ &BB7B
TXT_CUR_DISABLE           equ &BB7E
TXT_CUR_ON                equ &BB81
TXT_CUR_OFF               equ &BB84
TXT_VALIDATE              equ &BB87
TXT_PLACE_CURSOR          equ &BB8A
TXT_REMOVE_CURSOR         equ &BB8D
TXT_SET_PEN               equ &BB90
TXT_GET_PEN               equ &BB93
TXT_SET_PAPER             equ &BB96
TXT_GET_PAPER             equ &BB99
TXT_INVERSE               equ &BB9C
TXT_SET_BACK              equ &BB9F
TXT_GET_BACK              equ &BBA2
TXT_GET_MATRIX            equ &BBA5
TXT_SET_MATRIX            equ &BBA8
TXT_SET_M_TABLE           equ &BBAB
TXT_GET_M_TABLE           equ &BBAE
TXT_GET_CONTROLS          equ &BBB1
TXT_STR_SELECT            equ &BBB4
TXT_SWAP_STREAMS          equ &BBB7

; The Graphics VDU
GRA_INITIALISE            equ &BBBA
GRA_RESET                 equ &BBBD
GRA_MOVE_ABSOLUTE         equ &BBC0
GRA_MOVE_RELATIVE         equ &BBC3
GRA_ASK_CURSOR            equ &BBC6
GRA_SET_ORIGIN            equ &BBC9
GRA_GET_ORIGIN            equ &BBCC
GRA_WIN_WIDTH             equ &BBCF
GRA_WIN_HEIGHT            equ &BBD2
GRA_GET_W_WIDTH           equ &BBD5
GRA_GET_W_HEIGHT          equ &BBD8
GRA_CLEAR_WINDOW          equ &BBDB
GRA_SET_PEN               equ &BBDE
GRA_GET_PEN               equ &BBE1
GRA_SET_PAPER             equ &BBE4
GRA_GET_PAPER             equ &BBE7
GRA_PLOT_ABSOLUTE         equ &BBEA
GRA_PLOT_RELATIVE         equ &BBED
GRA_TEST_ABSOLUTE         equ &BBF0
GRA_TEST_RELATIVE         equ &BBF3
GRA_LINE_ABSOLUTE         equ &BBF6
GRA_LINE_RELATIVE         equ &BBF9
GRA_WR_CHAR               equ &BBFC

; The Screen Pack
SCR_INITIALIZE            equ &BBFF
SCR_RESET                 equ &BC02
SCR_SET_OFFSET            equ &BC05
SCR_SET_BASE              equ &BC08
SCR_GET_LOCATION          equ &BC0B
SCR_SET_MODE              equ &BC0E
SCR_GET_MODE              equ &BC11
SCR_CLEAR                 equ &BC14
SCR_CHAR_LIMITS           equ &BC17
SCR_CHAR_POSITION         equ &BC1A
SCR_DOT_POSITION          equ &BC1D
SCR_NEXT_BYTE             equ &BC20
SCR_PREV_BYTE             equ &BC23
SCR_NEXT_LINE             equ &BC26
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

;  ----------------------------------------------------------------------------
; | Action | Initializes the cassette manager.                                 |
;  ----------------------------------------------------------------------------
; | Entry  |  No entry conditions.                                             |
;  ----------------------------------------------------------------------------
; | Exit   |  AF, BC, DE and HL are corrupt, and all the other registers are   |
; |        | preserved.                                                        |
;  ----------------------------------------------------------------------------
; | Notes  |  Both read and write streams are closed; tape messages are        |
; |        |  switched on; the default speed is reselected.                    |
;  ----------------------------------------------------------------------------


CAS_INITIALISE            equ &BC65


;  ----------------------------------------------------------------------------
; | Action | Sets the speed at which the cassette manager saves programs       |
;  ----------------------------------------------------------------------------
; | Entry  | HL holds the length of `half a zero' bit, and A contains the      |
; |        | amount of precompensation.                                        |
;  ----------------------------------------------------------------------------
; | Exit   | AF and HL are corrupt.                                            |
;  ----------------------------------------------------------------------------
; | Notes  | The value in HL is the length of time that half a zero bit is     |
; |        | written as; a one bit is twice the length of a zero bit; the      |
; |        | default values (ie SPEED WRITE 0) are 333 microseconds (HL) and   | 
; |        | 25 microseconds (A) for SPEED WRITE 1, the values are given as    | 
; |        | 107 microseconds and 50 microseconds respectiveIy                 |
;  ----------------------------------------------------------------------------


CAS_SET_SPEED             equ &BC68


;  ----------------------------------------------------------------------------
; | Action | Enables or disables the display of cassette handling messages.    |
;  ----------------------------------------------------------------------------
; | Entry  | To enable the messages then A must be 0, otherwise the messages   |
; |        | are disabled.                                                     |
;  ----------------------------------------------------------------------------
; | Exit   |  AF is corrupt, and all other registers are preserved.            |
;  ----------------------------------------------------------------------------


CAS_NOISY                 equ &BC6B


;  ----------------------------------------------------------------------------
; | Action | Switches on the tape motor.                                       |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   | If the motor operates properly then Carry is true; if ESC was     |
; |        | pressed then Carry is false; in either case, A contains the       |
; |        | motor's previous state, tbe flags are corrupt, and all others are |
; |        | preserved.                                                        |
;  ----------------------------------------------------------------------------


CAS_START_MOTOR           equ &BC6E


;  ----------------------------------------------------------------------------
; | Action | Switches off the tape motor.                                      |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   | If the motor turns off then Carry is true; if ESC was pressed then|
; |        | Carry is false; in both cases, A holds tbe motor's previous state,|
; |        | the other flags are corrupt, all others are preserved.            |
;  ----------------------------------------------------------------------------


CAS_STOP_MOTOR            equ &BC71


;  ----------------------------------------------------------------------------
; | Action | Resets the tape motor to its previous state.                      |
;  ----------------------------------------------------------------------------
; | Entry  | A contains the previous state of the motor (eg from CAS START     |
; |        | MOTOR or CAS STOP MOTOR).                                         |
;  ----------------------------------------------------------------------------
; | Exit   | If the motor operates properly then Carry is true; if ESC was     |
; |        | pressed then Carry is false; in all cases, A and the other flags  |
; |        | are corrupt and all others are preserved.                         |
;  ----------------------------------------------------------------------------


CAS_RESTORE_MOTOR         equ &BC74


;  ----------------------------------------------------------------------------
; | Action | Opens an input buffer and reads the first block of the file.      |
;  ----------------------------------------------------------------------------
; | Entry  | B contains the length of the filename, HL contains the filename's |
; |        | address, and DE contains the address of the 2K buffer to use for  |
; |        | reading the file.                                                 |
;  ----------------------------------------------------------------------------
; | Exit   | If the file was opened successfully, then Carry is true, Zero is  |
; |        | false, HL holds the address of a buffer containing the file header|
; |        | data, DE holds the address of the destination for the file, BC    |
; |        | holds the file length, and A holds the file type; if the read     |
; |        | stream is already open then Carry and Zero are false, A contains  |
; |        | an error number and BC, DE and HL are corrupt; if ESC was pressed |
; |        | by the user, then Carry is false, Zero is true, A holds an error  |
; |        |  number and BC, DE and HL are corrupt; in all cases, IX and the   |
; |        | other flags are corrupt, and the others are preserved.            |
;  ----------------------------------------------------------------------------
; | Notes  | A filename of zero length means `read the next file on the tape'; |
; |        | the stream remains open until it is closed by either CAS IN CLOSE |
; |        | or CAS IN ABANDON.                                                |
;  ----------------------------------------------------------------------------
; | Disc   | Similar to tape except that if there is no header on the file,    |
; |        | then a fake header is put into memory by this routine.            |
;  ----------------------------------------------------------------------------


CAS_IN_OPEN               equ &BC77


;  ----------------------------------------------------------------------------
; | Action | Closes an input file.                                             |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   | If the file was closed successfully, then Carry is true and A is  |
; |        | corrupt; if the read stream was not open, then Carry is false, and|
; |        | A holds an error code; in both cases, BC, DE, HL and the other    |
; |        | flags are all corrupt.                                            |
;  ----------------------------------------------------------------------------
; | Disc   | All the above applies, but also if the file failed to close for   |
; |        | any other reason, then Carry is false, Zero is true and A contains|
; |        | an error number; in all cases the drive motor is turned off       |
; |        | immediately.                                                      |
;  ----------------------------------------------------------------------------


CAS_IN_CLOSE              equ &BC7A


;  ----------------------------------------------------------------------------
; | Action | Abandons an input file.                                           |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   | AF, BC, DE and HL are corrupt, and all others are preserved.      |
;  ----------------------------------------------------------------------------
; | Disc   |All the above applies for the disc routine.                        |
;  ----------------------------------------------------------------------------


CAS_IN_ABANDON            equ &BC7D


;  ----------------------------------------------------------------------------
; | Action | Reads in a single byte from a file.                               |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   | If a byte was read, then Carry is true, Zero is false, and A      |
; |        | contains the byte read from the file; if the end of file was      |
; |        | reached, then Carry and Zero are false, A contains an error number|
; |        | if ESC was pressed, then Carry is false, Zero is true, and A holds|
; |        | an error number; in all cases, IX and the other flags are corrupt,|
; |        | and all others are preserved.                                     |
;  ----------------------------------------------------------------------------
; | Disc   | All the above applies for the disc routine.                       |
;  ----------------------------------------------------------------------------


CAS_IN_CHAR               equ &BC80


;  ----------------------------------------------------------------------------
; | Action | Reads an entire file directly into memory.                        |
;  ----------------------------------------------------------------------------
; | Entry  |  HL contains the address where the file is to be placed in RAM.   |
;  ----------------------------------------------------------------------------
; | Exit   | If the operation was successful, then Carry is true, Zero is false|
; |        | , HL contains the entry address and A is corrupt; if it was not   |
; |        | open, then Carry and Zero are both false, HL is corrupt, and A    |
; |        | holds an error code; if ESC was pressed, Carry is false, Zero is  |
; |        | true, HL is corrupt, and A holds an error code; in all cases, BC, |
; |        | DE and IX and the other flags are corrupt, and the others are     |
; |        | preserved.                                                        |
;  ----------------------------------------------------------------------------
; | Notes  | This routine cannot be used once CAS IN CHAR has been used.       |
;  ----------------------------------------------------------------------------
; | Disc   | All the above applies to the disc routine.                        |
;  ----------------------------------------------------------------------------


CAS_IN_DIRECT             equ &BC83


;  ----------------------------------------------------------------------------
; | Action | Puts the last byte read back into the input buffer so that it can |
; |        | be read again at a later time.                                    |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   | All registers are preserved.                                      |
;  ----------------------------------------------------------------------------
; | Notes  | The routine can only return the last byte read and at least one   |
; |        | byte must have been read.                                         |
;  ----------------------------------------------------------------------------
; | Disc   | All the above applies to the disc routine.                        |
;  ----------------------------------------------------------------------------


CAS_RETURN                equ &BC86


;  ----------------------------------------------------------------------------
; | Action | Tests whether the end of file has been encountered.               |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   | If the end of file has been reached, then Carry and Zero are false|
; |        | , and A is corrupt; if the end of file has not been encountered,  |
; |        | then Carry is true, Zero is false, and A is corrupt; if ESC was   |
; |        | pressed then Carry is false, Zero is true and A contains an error |
; |        | number; in all cases, IX and the other flags are corrupt, and all |
; |        | others are preserved.                                             |
;  ----------------------------------------------------------------------------
; | Disc   | All the above applies to the disc routine.                        |
;  ----------------------------------------------------------------------------


CAS_TEST_EOF              equ &BC89


;  ----------------------------------------------------------------------------
; | Action | Opens an output file.                                             |
;  ----------------------------------------------------------------------------
; | Entry  | B contains the length of the filename, HL contains the address of |
; |        | the filename, and DE holds the address of the 2K buffer to be     |
; |        | used.                                                             |
;  ----------------------------------------------------------------------------
; | Exit   | If the file was opened correctly, then Carry is true, Zero is     |
; |        | false, HL holds the address of the buffer containing the file     |
; |        | header data that will be written to each block, and A is corrupt; |
; |        | if the write stream is already open, then Carry and Zero are      |
; |        | false, A holds an error number  and HL is corrupt; if ESC was     |
; |        | pressed then Carry is false, Zero is true, A holds an error number|
; |        | and HL is corrupt; in all cases, BC, DE, IX and the other flags   |
; |        | are corrupt, and the others are preserved.                        |
;  ----------------------------------------------------------------------------
; | Notes  | The buffer is used to store the contents of a file block before it|
; |        | is actually written to tape.                                      |
;  ----------------------------------------------------------------------------
; | Disc   | The same as for tape except that the filename must be present in  |
; |        |  its usual AMSDOS format.                                         |
;  ----------------------------------------------------------------------------


CAS_OUT_OPEN              equ &BC8C


;  ----------------------------------------------------------------------------
; | Action | Closes an output file.                                            |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   | If the file was closed successfully, then Carry is true, Zero is  |
; |        | false, and A is corrupt; if the write stream was not open, then   |
; |        | Carry and Zero are false and A holds an error code; if ESC was    |
; |        | pressed then Carry is false, Zero is true, and A contains an error|
; |        | code; in all cases, BC, DE, HL, IX and the other flags are all    |
; |        | corrupt.                                                          |
;  ----------------------------------------------------------------------------
; | Notes  | The last block of a file is written only when this routine is     |
; |        | called; if writing the file is to be abandoned, then CAS OUT      |
; |        | ABANDON should be used instead.                                   |
;  ----------------------------------------------------------------------------
; | Disc   |All the above applies to the disc routine.                         |
;  ----------------------------------------------------------------------------


CAS_OUT_CLOSE             equ &BC8F


;  ----------------------------------------------------------------------------
; | Action | Abandons an output file.                                          |
;  ----------------------------------------------------------------------------
; | Entry  | No entry conditions.                                              |
;  ----------------------------------------------------------------------------
; | Exit   |  AF, BC, DE and HL are corrupt, and all others are preserved.     |
;  ----------------------------------------------------------------------------
; | Notes  | When using this routine, the current last block of the file is not|
; |        | written to the tape.                                              |
;  ----------------------------------------------------------------------------
; | Disc   | Similar to the tape routine; if more than 16K of a file has been  |
; |        | written to the disc, then the first 16K of the file will exist on |
; |        | the disc with a file extension of .$$$ because each 16K section of|
; |        | the file requires a separate directory entry.                     |
;  ----------------------------------------------------------------------------


CAS_OUT_ABANDON           equ &BC92


;  ----------------------------------------------------------------------------
; | Action |Writes a single byte to a file.                                    |
;  ----------------------------------------------------------------------------
; | Entry  |  A contains the byte to be written to the file output buffer.     |
;  ----------------------------------------------------------------------------
; | Exit   | If a byte was written to the buffer, then Carry is true, Zero is  |
; |        | false, and A is corrupt; if the file was not open, then Carry and |
; |        | Zero are false, and A contains an error number ; if ESC was       |
; |        | pressed, then Carry is false, Zero is true, and A contains an     |
; |        | error number; in all cases, IX and the other flags are corrupt,   |
; |        | and all others are preserved.                                     |
;  ----------------------------------------------------------------------------
; | Notes  | If the 2K buffer is full of data then it is written to the tape   |
; |        | before the new character is placed in the buffer; it is important |
; |        | to call CAS OUT CLOSE when all the data has been sent to the file |
; |        | so that the last block is written to the tape.                    |
;  ----------------------------------------------------------------------------
; | Disc   | All the above applies to the disc routine.                        |
;  ----------------------------------------------------------------------------


CAS_OUT_CHAR              equ &BC95


;  ----------------------------------------------------------------------------
; | Action | Writes an entire file directly to tape.                           |
;  ----------------------------------------------------------------------------
; | Entry  | HL contains the address of the data which is to be written to tape|
; |        | , DE contains the length of this data, BC contains the execution  |
; |        | address, and A contains the file type.                            |
;  ----------------------------------------------------------------------------
; | Exit   | If the operation was successful, then Carry is true, Zero is false|
; |        | , and A is corrupt; if the file was not open, Carry and Zero are  |
; |        | false, A holds an error number; if ESC was pressed, then Carry is |
; |        | false, Zero is true, and A holds an error code; in all cases BC,  |
; |        | DE, HL, IX and the other flags are corrupt, and the others are    |
; |        | preserved.                                                        |
;  ----------------------------------------------------------------------------
; | Notes  |  This routine cannot be used once CAS OUT CHAR has been used.     |
;  ----------------------------------------------------------------------------
; | Disc   | All the above applies to the disc routine.                        |
;  ----------------------------------------------------------------------------


CAS_OUT_DIRECT            equ &BC98


;  ----------------------------------------------------------------------------
; | Action | Creates a catalogue of all the files on the tape.                 |
;  ----------------------------------------------------------------------------
; | Entry  | DE contains the address of the 2K buffer to be used to store the  |
; |        | information.                                                      |
;  ----------------------------------------------------------------------------
; | Exit   | If the operation was successful, then Carry is true, Zero is false|
; |        | , and A is corrupt; if the read stream is already being used, then|
; |        | Carry and Zero are false, and A holds an error code; in all cases,|
; |        | BC, DE, HL, IX and the other flags are corrupt and all others are |
; |        | preserved.                                                        |
;  ----------------------------------------------------------------------------
; | Notes  | This routine is only left when the ESC key is pressed (cassette   |
; |        | only) and is identical to BASIC's CAT command.                    |
;  ----------------------------------------------------------------------------
; | Disc   | All the above applies, except that a sorted list of files is      |
; |        | displayed; system files are not listed by this routine.           |
;  ----------------------------------------------------------------------------


CAS_CATALOG               equ &BC9B


;  ----------------------------------------------------------------------------
; | Action | Writes data to the tape in one long file (ie not in 2K blocks).   |
;  ----------------------------------------------------------------------------
; | Entry  | HL contains the address of the data to be written to tape, DE     |
; |        | contains the length of the data to be written, and A contains the |
; |        | sync character.                                                   |
;  ----------------------------------------------------------------------------
; | Exit   | If the operation was successful, then Carry is true and A is      |
; |        | corrupt; if an error occurred then Carry is false and A contains  |
; |        | an error code; in both cases, BC, DE, HL and lX are corrupt, and  |
; |        | all other registers are preserved.                                |
;  ----------------------------------------------------------------------------
; | Notes  | For header records the sync character is &2C, and for data it is  |
; |        | &16; this routine starts and stops the cassette motor and also    |
; |        | tums off interrupts whilst writing data.                          |
;  ----------------------------------------------------------------------------


CAS_WRITE                 equ &BC9E


;  ----------------------------------------------------------------------------
; | Action | Reads data from the tape in one long file (ie as originally       |
; |        | written by CAS WRITE only).                                       |
;  ----------------------------------------------------------------------------
; | Entry  |  HL holds the address to place the file, DE holds the length of   |
; |        | the data, and A holds the expected sync character.                |
;  ----------------------------------------------------------------------------
; | Exit   | If the operation was successful, then Carry is true and A is      |
; |        | corrupt; if an error occurred then Carry is false and A contains  |
; |        | an error code; in both cases, BC, DE, HL and IX are corrupt, and  |
; |        | all other registers are preserved.                                |
;  ----------------------------------------------------------------------------
; | Notes  | For header records the sync character is &2C, and for data it is  |
; |        | &16; this routine starts and stops the cassette motor and turns   |
; |        | off interrupts whilst reading data.                               |
;  ----------------------------------------------------------------------------


CAS_READ                  equ &BCA1


;  ----------------------------------------------------------------------------
; | Action | Compares the contents of memory with a file record (ie header or  |
; |        | data) on tape.                                                    |
;  ----------------------------------------------------------------------------
; | Entry  | HL contains the address of the data to check, DE contains the     |
; |        | length of the data and A holds the sync character that was used   |
; |        | when the file was originally written to the tape.                 |
;  ----------------------------------------------------------------------------
; | Exit   | If the two are identical, then Carry is true and A is corrupt;    |
; |        | an error occurred then Carry is false and A holds an error code;  |
; |        | in all cases, BC, DE, HL, IX and other flags are corrupt, and all |
; |        | other registers are preserved.                                    |
;  ----------------------------------------------------------------------------
; | Notes  | For header records the sync character is &2C, and for data it is  |
; |        | &16; this routine starts and stops the cassette motor and turns   |
; |        | off interrupts whilst reading data; does not have to read the     |
; |        | whole of a record, but must start at the beginning.               |
;  ----------------------------------------------------------------------------


CAS_CHECK                 equ &BCA4


; The Sound Manager
SOUND_RESET               equ &BCA7
SOUND_QUEUE               equ &BCAA
SOUND_CHECK               equ &BCAD
SOUND_ARM_EVENT           equ &BCB0
SOUND_RELEASE             equ &BCB3
SOUND_HOLD                equ &BCB6
SOUND_CONTINUE            equ &BCB9
SOUND_AMPL_ENVELOPE       equ &BCBC
SOUND_TONE_ENVELOPE       equ &BCBF
SOUND_A_ADDRESS           equ &BCC2
SOUND_T_ADDRESS           equ &BCC5

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

; The Machine Pack
MC_BOOT_PROGRAM           equ &BD13
MC_START_PROGRAM          equ &BD16
MC_WAIT_FLYBACK           equ &BD19
MC_SET_MODE               equ &BD1C
MC_SCREEN_OFFSET          equ &BD1F
MC_CLEAR_INKS             equ &BD22
MC_SET_INKS               equ &BD25
MC_RESET_PRINTER          equ &BD28
MC_PRINT_CHAR             equ &BD2B
MC_BUSY_PRINTER           equ &BD2E
MC_SEND_PRINTER           equ &BD31
MC_SOUND_REGISTER         equ &BD34
JUMP_RESTORE              equ &BD37

; 664 and 6128 only
KM_SET_LOCKS              equ &BD3A
KM_FLUSH                  equ &BD3D
TXT_ASK_STATE             equ &BD40
GRA_DEFAULT               equ &BD43
GRA_SET_BACK              equ &BD46
GRA_SET_FIRST             equ &BD49
GRA_SET_LINE_MASK         equ &BD4C
GRA_FROM_USER             equ &BD4F
GRA_FILL                  equ &BD52
SCR_SET_POSITION          equ &BD55
MC_PRINT_TRANSLATION      equ &BD58
KL_BANK_SWITCH            equ &BD5B

; The Maths Firmware
MOVE_REAL                 equ &BDC1
TEXT_INPUT                equ &BD5E
INTEGER_TO_REAL           equ &BD64
BINARY_TO_REAL            equ &BD67
REAL_TO_INTEGER           equ &BD6A
REAL_TO_BINARY            equ &BD6D
REAL_FIX                  equ &BD70
REAL_INT                  equ &BD73
REAL_X_10_POW_A           equ &BD79
REAL_ADDITION             equ &BD7C
REAL_RND                  equ &BD7F
REAL_REVERSE_SUBTRACTION  equ &BD82
REAL_MULTIPLICATION       equ &BD85
REAL_DIVISION             equ &BD88
REAL_RND_0                equ &BD8B
REAL_COMPARISON           equ &BD8E
REAL_UNARY_MINUS          equ &BD91
REAL_SIGNUM_SGN           equ &BD94
SET_ANGLE_MODE            equ &BD97
REAL_PI                   equ &BD9A
REAL_SQR                  equ &BD9D
REAL_POWER                equ &BDA0
REAL_LOG                  equ &BDA3
REAL_LOG_10               equ &BDA6
REAL_EXP                  equ &BDA9
REAL_SINE                 equ &BDAC
REAL_COSINE               equ &BDAF
REAL_TANGENT              equ &BDB2
REAL_ARCTANGENT           equ &BDB5

; The Firmware Indirections
TXT_DRAW_CURSOR           equ &BDCD
TXT_UNDRAW_CURSOR         equ &BDD0
TXT_WRITE_CHAR            equ &BDD3
TXT_UNWRITE               equ &BDD6
TXT_OUT_ACTION            equ &BDD9
GRA_PLOT                  equ &BDDC
GRA_TEST                  equ &BDDF
GRA_LINE                  equ &BDE2
SCR_READ                  equ &BDE5
SCR_WRITE                 equ &BDE8
SCR_MODE_CLEAR            equ &BDEB
KM_TEST_BREAK             equ &BDEE
MC_WAIT_PRINTER           equ &BDF1
KM_SCAN_KEYS              equ &BDF4


; **************************************
;
; **************************************
macro mFW_PEN_INK_SET pen,ink1,ink2
    ld a,pen
    ld bc,ink1*256 + ink2
    call SCR_SET_INK
mend


; **************************************
;
; **************************************
macro mFW_BORDER_INK_SET ink1,ink2
    ld bc,ink1*256 + ink2
    call SCR_SET_BORDER
mend


; **************************************
;
; **************************************
FW_MODE_0 equ 0
FW_MODE_1 equ FW_MODE_0 + 1
FW_MODE_2 equ FW_MODE_1 + 1
FW_MODE_3 equ FW_MODE_2 + 1
macro mFW_MODE_SET mode
    ld a,mode
    call SCR_SET_MODE
mend


; **************************************
; Disable event bloc that refresh
; ink (RESET when mode change !!!)
;
; **************************************
macro mFW_REFRESH_OFF
  ld hl,&b7f9
  call KL_DEL_FRAME_FLY
mend


; **************************************
; Reinitialize ROM7.
;
; **************************************
FIRST_USABLE_BYTE_OF_MEM equ &0040
LAST_USABLE_BYTE_OF_MEM  equ &ABFF
ROM_AMSDOS               equ &07
macro mFW_REINIT_ROM7
  ld de,FIRST_USABLE_BYTE_OF_MEM
  ld hl,LAST_USABLE_BYTE_OF_MEM
  ld c,ROM_AMSDOS
  call KL_INIT_BACK
mend


; **************************************
; * Set all pen and border ink black.  *
; **************************************
macro mFW_BLACK_INKS
  ld b,16
  xor a
  push af
  push bc
  ld bc,0
  call SCR_SET_INK
  pop bc
  pop af
  inc a
  djnz $-11
  ld bc,0
  call SCR_SET_BORDER  
mend





















