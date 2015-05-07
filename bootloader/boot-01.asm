;********************************************
;	boot-1.asm
;		- A Simple Bootloader
;
;	Operating System Development Tutorial
;
;********************************************

org	0x7c00														; We are loaded by BIOS at 0x7C00
bits	16														; We are still in 16 bit Real Mode
start:	
						jmp loader

;*************************************************;
;	OEM Parameter block
;*************************************************;

; Error Fix 2 - Removing the ugly TIMES directive -------------------------------------

;;	TIMES 0Bh-$+start DB 0										; The OEM Parameter Block is exactally 3 bytes
																; from where we are loaded at. This fills in those
																; 3 bytes, along with 8 more. Why?

bpbOEM					db "My OS   "							; This member must be exactally 8 bytes. It is just
																; the name of your OS :) Everything else remains the same.

bpbBytesPerSector:  	DW 512
bpbSectorsPerCluster: 	DB 1
bpbReservedSectors: 	DW 1
bpbNumberOfFATs: 	    DB 2
bpbRootEntries: 	    DW 224
bpbTotalSectors: 	    DW 2880
bpbMedia: 	            DB 0xF0
bpbSectorsPerFAT: 	    DW 9
bpbSectorsPerTrack: 	DW 18
bpbHeadsPerCylinder: 	DW 2
bpbHiddenSectors: 	    DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber: 	        DB 0
bsUnused: 	            DB 0
bsExtBootSignature: 	DB 0x29
bsSerialNumber:	        DD 0xa0a1a2a3
bsVolumeLabel: 	        DB "MOS FLOPPY "
bsFileSystem: 	        DB "FAT12   "

msg db "Welcome to My Operating System!", 0

;********************************************
;	Print a String
;	DS=>SI: 0 terminated string
;********************************************

Print:
						lodsb									; Load next byte from string SI to AL
						or 					al, al 				; Does AL==0?
						jz					PrintDone  			; Yep, null terminator found-bail out
						mov					ah, 0eh 			; Nope-Print the character (function number = 0Eh : Display Character)
						int 				10h
						jmp					Print 				; Repeat until null terminator found

PrintDone:
						ret 									; we are done, so return

;********************************************
;	Bootloader Entry Point
;********************************************

loader:
						xor					ax, ax				; Setup segments to insure they are 0. Remeber that
						mov					ds, ax				; we have ORG 0x7c00. This means all addresses are based
						mov					es, ax				; from 0x7c00:0. Because the data segments are within the same
																; code segment, null em.

						mov					si, msg				; Our message to print.
						call				Print

						xor					ax, ax				; Clear AX.
						int 				0x12 				; Get the amount of KB from the BIOS.

						cli										; Clear all Interrupts
						hlt										; Halt the system

times 510 - ($-$$) db 0											; We have to be 512 bytes. Clear the rest of bytes to be 0
dw	0xAA55														; Boot Signiture
