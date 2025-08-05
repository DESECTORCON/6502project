PORTA = $6001
LCDDATA = $6000

PBDIR = $6002
PADIR = $6003

ENABLE =  %00000100
READ =  %00000010
WRITE =  %00000000
INSTR =  %00000000
CHARR =  %00000001


	.org $8000

setup:
	ldx #$FF				; Stack pointer to last address for better understnading
	txs	

	lda #%11111111		; Setup PB direction
	sta	PBDIR

	lda #%11111111    ; Setup PA direction
	sta PADIR

	lda #%00000000		; Reset outputs of PA, PB
	sta LCDDATA
	sta PORTA


	
	lda #%00011000		; Function Set: 8 bit, 2 line 5x8 dots	
	jsr write_instruction 	
	
	lda #%00000001			; Clear display
	jsr write_instruction 	

	lda #%00001110				; Display on
	jsr write_instruction 	

	lda #%00000110				; Entry mode set
	jsr write_instruction


display:
	ldx #0								; Reset x register

print_loop:
	lda message,x
	jsr write_char		
	inx
	bne print_loop

	jsr halt

message: .asciiz "Hello world!                            This is awesome!"


halt:	
	jsr halt

write_instruction:
	pha
	jsr bport_input
	jsr check_busy
	jsr bport_output
	pla
	sta LCDDATA											; Write instruction data to port B
	lda #(WRITE | INSTR | ENABLE)
	sta PORTA
	
	nop
	nop
	nop

	lda #%00000000
	sta PORTA

	rts

write_char:
	pha
	jsr bport_input
	jsr check_busy	
	jsr bport_output
	pla
	sta LCDDATA
	lda #(WRITE | CHARR | ENABLE)
	sta PORTA

	nop
	nop
	nop

	lda #%00000001
	sta PORTA

	rts

check_busy:

	lda #%10000000		; Compare if busy flag is on
	and LCDDATA
	bne check_busy	
	
	rts
	
bport_input:
	lda #%00000000			; Set all BPorts to inputs
	sta PBDIR

	rts

bport_output:
	lda #%11111111			; Set all Bports to outputs 
	sta PBDIR

	rts



								; Reset vector
	.org $fffc
	.word $8000
	.word $0000



