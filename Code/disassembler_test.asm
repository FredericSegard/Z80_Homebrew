; GENERAL EQUATES
NULL			= $00
CTRLC			= $03				; Control-C (Break)
CTRLG			= $07				; Control-G (Bell)
BKSP			= $08				; Backspace
TAB				= $09				; Horizontal tab
LF				= $0A				; Line-feed character
CS				= $0C				; Clear Screen
CR				= $0D				; Carriage-return character
CTRLO			= $0F				; Control "O"
CTRLQ			= $11				; Control "Q"
CTRLR			= $12				; Control "R"
CTRLS			= $13				; Control "S"
CTRLU			= $15				; Control "U"
ESC				= $1B				; Escape
SPACE			= $20				; Space character
DEL				= $7F				; Delete

DELIMITER		= " "				; Space delimiter between command line parameters
ERRORPTR		= "^"				; Error pointer symbol (used for pointing to the error position on command line)
QUOTE			= $22
JUMP			= $C3				; Delimiter for command list items (It's the actual jp command opcode)
HELP			= $0F
EOT				= $FF				; End of table

;PARAMETERS
HorizTextRes	= 40				; Horizontal text resolution (40 or 80)
VertTextRes		= 24				; Vertical text resolution (typical 24 or 25)
ErrorPtrOffset	= 8					; Take into account the command prompt width
BytesFree		= (VectorTable-EndOfCode)+(StartOfCode-InterruptVectorEnd)	; Base free bytes

; I/O ADDRESSES
SIO_PortA_Data	= $00				; SIO data port A
SIO_PortB_Data	= $01				; SIO data port B
SIO_PortA_Ctrl	= $02				; SIO control port A
SIO_PortB_Ctrl	= $03				; SIO control port B
ClockSelect		= $28				; Clock speed selection address (values $00 to $03)
BankSelect		= $30				; RAM bank select address (values ($00 to $0E)
RomDisable		= $38				; ROM dissable address (any value)

Ascii2HexNibble		= $FE00				; [A -> A][A -> A]
Ascii2HexByte		= $FE03				; [(HL) -> A][(HL) -> A]
Ascii2HexWord		= $FE06				; [(HL) -> BC][(HL) -> BC]
ClearScreen			= $FE09				; [][]
GetHexParameter		= $FE0C				; [(HL) -> BC,A,(HL)][(HL) -> BC,A,(HL)]
PrintChar			= $FE0F				; [A ->][A ->]
PrintString			= $FE12				; [HL ->][HL ->]
PrintCRLF			= $FE15				; [][]
PrintNibble			= $FE18				; [A ->][A ->]
PrintByte			= $FE1B				; [A ->][A ->]
PrintWord			= $FE1E				; [HL ->][HL ->]
RangeValidation		= $FE21				; Start&EndAddress -> C, Start&EndAddress, Start&EndAddressAlt)
ReadChar			= $FE24				; [-> A][-> A]
ReadCharNoWait		= $FE27
ReadString			= $FE2A				; [HL ->][HL ->]
ReadByte			= $FE2D				; [-> A][-> A]
ReadWord			= $FE30				; [-> HL][-> HL]
SkipSpaces			= $FE33				; [HL -> HL][HL -> HL]
UpperCase			= $FE36				; [A -> A][A -> A]
Registers			= $FE39				; [][]
Dec2Hex				= $FE3C				; [(HL) -> BC]

InterruptVectorEnd	= $FD00			; End of interrupt vector table
VectorTable			= $FD02			; Start of vector and jump tables
StartOfCode			= $FD04			; Start of code address
EndOfCode			= $FD06			; End of code address

	.org $1000

Start:
	ld		BC,$0000
	ld		(CurrentAddress),BC
	ld		HL,CommandBuffer
	call	Disassemble
	ret

Disassemble:
	push	AF
	push	BC
	push	DE
	push	HL

;	ld		HL,(BufferPointer)		; Restore current buffer pointer in HL
	call	GetHexParameter			; Get parameter: the start address to disassemble
	jr		nc,DisassembleEnd		; Exit routine if there was an error in the parameter
	cp		0						; Is there a parameter?
	jr		nz,DisDefaultLines		; If There's a parameter, go check second parameter
	ld		BC,(CurrentAddress)		; Since it's no parameter, then place CurrentAddress as default address

DisDefaultLines:
	push	BC						; Save address
	pop		HL						;	to HL
	
	ld		C,VertTextRes-3			; Get number of vertical lines







DisassembleEnd:
	pop		HL
	pop		DE
	pop		BC
	pop		AF
	ret

	
;  __  __
; |	 \/	 |	 ___   ___	 ___	__ _	__ _	___	  ___
; | |\/| |	/ _ \ / __| / __|  / _` |  / _` |  / _ \ / __|
; | |  | | |  __/ \__ \ \__ \ | (_| | | (_| | |	 __/ \__ \
; |_|  |_|	\___| |___/ |___/  \__,_|  \__, |  \___| |___/
;									   |___/
; ---------------------------------------------------------------------------------------------------------------------
; SYSTEM MESSAGES, INCLUDING ERROR MESSAGES




; __	 __					_			_		_
; \ \	/ /	  __ _	 _ __  (_)	 __ _  | |__   | |	 ___   ___
;  \ \ / /	 / _` | | '__| | |	/ _` | | '_ \  | |	/ _ \ / __|
;	\ V /	| (_| | | |	   | | | (_| | | |_) | | | |  __/ \__ \
;	 \_/	 \__,_| |_|	   |_|	\__,_| |_.__/  |_|	\___| |___/
;
; ---------------------------------------------------------------------------------------------------------------------
; VARIABLES AT THE END OF THE CODE ARE DECLARED IN BYTE SIZE

CommandBuffer:		db	"8000",NULL		; Command prompt buffer
CurrentAddress		ds	2				; 
StartAddress:		ds	2				; Original start or source address
EndAddress:			ds	2				; Original end or destination address
StartAddressAlt:	ds	2				; Original start or source address
EndAddressAlt:		ds	2				; Original end or destination address


; Data for disassembler
; ---------------------------------------------------------------------------------------------------------------------
; Parameter 1: OpCode #1
; Parameter 2: Number of OpCode bytes (MSB), Number of Operands (LSB)
; Parameter 3: Next OpCode(s) if any
; Parameter 4: Mnemonic (Terminated by bit7 high to save space)

InstructionSet:

	