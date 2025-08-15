;	VIA I/O 
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
IER = $600E	;	Instruction enable register
IFR = $600D	;	Interrupt Flag register
PCR = $600C	;	CA1,2 CB1,2 Control register
;	LCD CONSTANTS
E  = %00000100
RW = %00000010
RS = %00000001
;	Binary2BCD
number = $0200		; Two bytes => value to convert to bcd
mod10 = $0202		; Two bytes 
bcd = $0204		; 6 bytes => bcd data
message_pos = $020A	;	1 byte => bcd write pos
iterations = $020B	; 1 byte => usually 0~16
