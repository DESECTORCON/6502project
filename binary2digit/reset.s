reset:
	cli	;	Enable intrrupts (default) 

  ldx #$ff	;	Set stack pointer to largest value
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
	jsr lcd_clear 
 
	;	Reset number
	lda #0; Store lower byte of 16 bit number
	sta number
	lda #0; Store higher byte of 16 bit number
	sta number+1

	lda #0  ;	Reset mod10 bytes
	sta mod10
	sta mod10+1

	lda #16	;	Load default iterations value
	sta iterations

	lda #0	;	Message write position value: will increment as convertion commences
	sta message_pos

	clc	; Clear carry flag => this carry flag is the first bit to be pushed into number
	
