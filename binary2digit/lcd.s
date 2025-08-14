lcd_chome:
	lda #%00000010
	jsr lcd_instruction
	rts	

lcd_clear:
	lda #%00000001
	jsr lcd_instruction
	rts

lcd_wait:
	sei	;	Intrrupt disabled when waiting for lcd 
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
	cli	;	Enable Intrrupts
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
	sei	;	Stop intrrupts when sending data => Enable bit timing 	
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
	cli	;	Intrrupts enabled after Enable signal complete
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
	sei	;	Same as lcd_instruction
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
	cli
  rts


