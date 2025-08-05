PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %00000100
RW = %00000010
RS = %00000001

number = $0200		; Two bytes
mod10 = $0202		; Two bytes 

message = $0204		; 6 bytes

iterations = $0300	; 1 byte => usually 0~16

  .org $8000


reset:
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%00000111 ; Set bottom 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #$00000001 ; Clear display
  jsr lcd_instruction

	lda #0	; Set end null byte for message termination
	sta message+5

	;	Store number 510 in ram
	lda #%11111110	; Store lower byte of 16 bit number
	sta number
	lda #%00000001	; Store higher byte of 16 bit number
	sta number+1

	lda #%00000000 	;	Reset mod10 bytes
	sta mod10
	sta mod10+1

	clc	; Clear carry flag => this carry flag is the first bit to be pushed into number
			
devide:
	lda number	; Load low number byte
	rol	; Rotate left low number byte
	sta number	
	lda number + 1	;	Load high number byte
	rol	;	Rotate left high number byte, carry in from low byte
	sta number + 1	
	lda mod10
	rol 
	sta mod10
	lda mod10 + 1
	rol 
	sta mod10 + 1


	lda number	;	 Check if Last division resulated in zero times ten
	ora number + 1	
	beq loop


	sec	;	Set carry flag so no unintentional borrow is done from last rotate left
	lda mod10
	sbc #10
	tax 
	lda mod10 + 1
	sbc #0	;	In case a borrow is needed
	tay 
	;	Subtracted are in y,x registers. 

	bcc ignore_results	;	Ignore results if carry flag is 0, thus the mod10 part is smaller than 10
	
	;	If not, store new values into ram
	stx mod10
	sty mod10 + 1
	
ignore_results:
		
	ldx iterations
	dex
	stx iterations
	beq got_reminder
	jmp devide

got_reminder:
	lda #0	;	Store carry flag for next devide 
	rol
	tax

	lda mod10
	adc #"0"
	jsr print_char
		
	txa	;	Carry flag is stored in the least sig bit of x register
	lsr

	lda #16 	;	Ready iteration value for next digit
	sta iterations

	jmp devide


  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp print

loop:
  jmp loop



lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcdbusy

  lda #RW
  sta PORTA
  lda #%11111111  ; Port B is output
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
  rts

  .org $fffc
  .word reset
  .word $0000
