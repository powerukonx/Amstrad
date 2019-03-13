; *****************************************************************************
; * FDC library
; * Code => POWER/UKONX
; *****************************************************************************

; *****************************************************************************
; Floppy Disk Controller
; definition.
; *****************************************************************************
; Ports.
FDC_PORT_STATUS                 equ &FB7E
FDC_PORT_DATA                   equ &FB7F
FLOPPY_MOTOR_PORT               equ &FA7E

; Main Status Register bit mask (FDC_PORT_STATUS).
FDC_MSR_D0B                     equ %00000001 ; FDD 0 Busy
FDC_MSR_D1B                     equ %00000010 ; FDD 1 Busy
FDC_MSR_D2B                     equ %00000100 ; FDD 2 Busy
FDC_MSR_D3B                     equ %00001000 ; FDD 3 Busy
FDC_MSR_CB                      equ %00010000 ; FDC Busy (1 = Busy, 0 = Not Busy)
FDC_MSR_EXM                     equ %00100000 ; Execution Mode
FDC_MSR_DIO                     equ %01000000 ; Data Input/Output (1 = controller has data for CPU, 0 = controller expecting data from CPU)
FDC_MSR_RQM                     equ %10000000 ; Request for Master (   1 = data register ready, 0 = data register not ready)

; Status Register 0 bit mask
FDC_SR0_US                      equ %00000011 ; Unit Select (driveno during interrupt)
FDC_SR0_HD                      equ %00000100 ; Head Address (head during interrupt)
FDC_SR0_NR                      equ %00001000 ; Not Ready (drive not ready or non-existing 2nd head selected)
FDC_SR0_EC                      equ %00010000 ; Equipment Check (drive failure or recalibrate failed (retry))
FDC_SR0_SE                      equ %00100000 ; Seek End (Set if seek-command completed)
FDC_SR0_IC                      equ %11000000 ; Interrupt Code (0=OK, 1=aborted:readfail/OK if EN
                                              ; , 2=unknown cmd or senseint with no int occured, 3=aborted:disc removed etc.)
; Status Register 1
FDC_SR1_MA                      equ %00000001 ; Missing Address Mark (Sector_ID or DAM not found)
FDC_SR1_NW                      equ %00000010 ; Not Writeable (tried to write/format disc with wprot_tab=on)
FDC_SR1_ND                      equ %00000100 ; No Data (Sector_ID not found, CRC fail in ID_field)
FDC_SR1_OR                      equ %00010000 ; Over Run (CPU too slow in execution-phase (ca. 26us/Byte))
FDC_SR1_DE                      equ %00100000 ; Data Error (CRC-fail in ID- or Data-Field)
FDC_SR1_EN                      equ %10000000 ; End of Track (set past most read/write commands) (see IC)

; Status Register 2
FDC_SR2_MD                      equ %00000001 ; Missing Address Mark in Data Field (DAM not found)
FDC_SR2_BC                      equ %00000010 ; Bad Cylinder (read/programmed track-ID different and read-ID = FF)
FDC_SR2_SN                      equ %00000100 ; Scan Not Satisfied (no fitting sector found)
FDC_SR2_SH                      equ %00001000 ; Scan Equal Hit (equal)
FDC_SR2_WC                      equ %00010000 ; Wrong Cylinder (read/programmed track-ID different) (see b1)
FDC_SR2_DD                      equ %00100000 ; Data Error in Data Field (CRC-fail in data-field)
FDC_SR2_CM                      equ %01000000 ; Control Mark (read/scan command found sector with deleted DAM)

; Status Register 3
FDC_SR3_US                      equ %00000011 ; Unit Select (pin 28,29 of FDC)
FDC_SR3_HD                      equ %00000100 ; Head Address (pin 27 of FDC)
FDC_SR3_TS                      equ %00001000 ; Two Side (0=yes, 1=no (!))
FDC_SR3_T0                      equ %00010000 ; Track 0 (on track 0 we are)
FDC_SR3_RY                      equ %00100000 ; Ready (drive ready signal)
FDC_SR3_WP                      equ %01000000 ; Write Protected (write protected)
FDC_SR3_FT                      equ %10000000 ; Fault (if supported: 1=Drive failure)

; Commands.
FDC_READ_A_TRACK                equ %00000010
FDC_SPECIFY                     equ %00000011
FDC_SENS_DRIVE_STATUS           equ %00000100
FDC_WRITE_DATA                  equ %00000101
FDC_READ_DATA                   equ %00000110
FDC_RECALIBRATE                 equ %00000111
FDC_SENSE_INTERRUPT_STATUS      equ %00001000
FDC_WRITE_DELETED_DATA          equ %00001001
FDC_READ_ID                     equ %00001010
FDC_READ_DELETED_DATA           equ %00001100
FDC_FORMAT_A_TRACK              equ %00001101
FDC_SEEK                        equ %00001111
FDC_SCAN_EQUAL                  equ %00010001
FDC_SCAN_LOW_OR_EQUAL           equ %00011001
FDC_SCAN_HIGH_OR_EQUAL          equ %00011101

; Commands bits.
FDC_CMD_MT                      equ %10000000 ; Multi-Track
FDC_CMD_MF                      equ %01000000 ; MFM Mode
FDC_CMD_SK                      equ %00100000 ; Skip
FDC_CMD_HD                      equ %00000100 ; Head
FDC_CMD_US1                     equ %00000010 ; Unit Select 1
FDC_CMD_US0                     equ %00000001 ; Unit Select 0

; Motor states.
MOTOR_STATE_OFF                 equ 0
MOTOR_STATE_ON                  equ 1

; *****************************************************************************
;
; *****************************************************************************
macro mMOTOR_SET state
if state=MOTOR_STATE_OFF
    xor a
else
    ld a,1
endif
    ld bc,&fa7e
    out (c),c
    out (c),a
mend

