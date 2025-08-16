;;;;;;;;;;;;;;;;;;;;;;	VIA I/O  ;;;;;;;;;;;;;;;;;;;;;; 
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
IER = $600E	;	Instruction enable register
IFR = $600D	;	Interrupt Flag register
PCR = $600C	;	CA1,2 CB1,2 Control register
ACR = $600B	;	Timer and shift register settings
SR = $600A	;	Shift register
;;;;;;;;;;;;;;;;;;;;;;;	LCD CONSTANTS	 ;;;;;;;;;;;;;;;;;;;;;;
E  = %00000100
RW = %00000010
RS = %00000001
;;;;;;;;;;;;;;;;;;;;;;;	Binary2BCD	 ;;;;;;;;;;;;;;;;;;;;;;
number = $0200			; Two bytes => value to convert to bcd
mod10 = $0202				; Two bytes 
bcd = $0204					; 6 bytes => bcd data
message_pos = $020A	;	1 byte => bcd write pos
iterations = $020B	; 1 byte => usually 0~16
;;;;;;;;;;;;;;;;;;;;;;; STACK  ;;;;;;;;;;;;;;;;;;;;;;
ystack = $0300			;	Used because assembler doesn't support y register push/pull stack
;;;;;;;;;;;;;;;;;;;;;;; DEBUG ;;;;;;;;;;;;;;;;;;;;;;;
dbuf_pos = $0500		;	1 byte pointer, 0~256
dbuf = $0400				;	256 byte size, from 0400~04FF
