;DOCUMENT VIEW TABSPACE SHOULD BE SET TO 2;		; TODO 
;;;;;;;;;;;;;;;;;;VIA;;;;;;;;;;;;;;;;;;
PORTB    = $6000
PORTA    = $6001
DDRB     = $6002
DDRA     = $6003
T2LOW    = $6008																;	T2 low order latch(write), counter(read)
T2HIGHC  = $6009																;	T2 high order counter(r/w)	
ACR      = $600B																; Timer, shift register, ab port latch control(Aux control register)
IFR			 = $600D																;	InterruptFlagRegister IRQ|TIMER1|TIMER2|CB1|CB2|SHIFTREGISTER|CA1|CA2'
IER			 = $600E																;	Interrupt Enable Register, 7th bit set/clear 
;;;;;;;;;;;;;SYSTEM TIME;;;;;;;;;;;;;;;;;
TIMER_HBYTE		 = %00000011											; Clock cycle number that translates into 1 milisecond (10^3)
TIMER_LBYTE		 = %11101000
systime				 = $5000													; System time. 4 byte value. Roll back occurs after approx 49 days 
;;;;;;;;;;;;;;;DELAY;;;;;;;;;;;;;;;;;;;;;
timestamp 		 = $5059													; Timestamp. 1 byte value 
timedelta			 = $505A													; Timedelta from timestamp. 1 byte value
;;;;;;;;;;;;;;;;;;LCD;;;;;;;;;;;;;;;;;;
E  						 = %00000100
RW 						 = %00000010
RS 						 = %00000001
last_refresh 	 = $5004													; Last lcd refresh time. 4 byte value
vram					 = $5008													; Lcd display buffer. 80 byte length 5008~5057
display_on		 = $5058
;;;;;;;;;;;;;;;;;;BCD;;;;;;;;;;;;;;;;;;
number = $0200																; Two bytes => value to convert to bcd
mod10 = $0202																	; Two bytes 
bcd = $0204																		; 6 bytes => bcd data
iterations = $020A														; 1 byte => usually 0~16

  .org $8000

reset:
  ldx #$ff																		;	Set stack pointer to largest value
  txs
	sei																					; Disable interrupts during setup(is enabled at the end of reset block)
	;;;;;;;;;;;;;;;LCD SETUP;;;;;;;;;;;;;;;;;;;;;
  lda #%11111111 															; Set all pins on port B to output
  sta DDRB
  lda #%00000111 															; Set bottom 3 pins on port A to output
  sta DDRA
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #$00000001 ; Clear display
  jsr lcd_instruction
	jsr vram_reset

	;;;;;;;;;;;;;;;;;TIMER SETUP;;;;;;;;;;;;;;;;;;;;;;
	lda #0																				; Reset timer 4 byte value
	ldx #3
time_reset:							
	sta systime, x																; Reset systime 
	sta last_refresh, x														; Reset lcd last refresh time
	dex
	bpl time_reset																; Branch when x is not negative
	lda #%10100000																;	Enable interrupts from Timer2
	sta IER	
	lda #%00000000																; Set Timer 2 mode to timed interrupts
	sta ACR	
	lda	TIMER_LBYTE 															; Load count value in timer latch/counter
	sta	T2LOW 	
	lda TIMER_HBYTE																; This automatically starts the timer
	sta T2HIGHC

	;	Store number 510 in ram
	lda #%11111110	; Store lower byte of 16 bit number
	sta number
	lda #%00000001	; Store higher byte of 16 bit number
	sta number+1

	;;;;;;;;;;;;BCD SETUP;;;;;;;;;;;;;;
	lda #0														; Setting null terminator for bcd array
	sta bcd + 5
	lda #0  													;	Reset mod10 bytes
	sta mod10
	sta mod10+1
	lda #16														;	Load iteration num
	sta iterations
	clc																; Clear carry flag => this carry flag is the first bit to be pushed into number

	;;;;;;;;;VARIABLE SETUP;;;;;;;;;;;;
	lda #%00001111
	sta display_on
	lda #0
	sta timestamp
	lda #0 
	sta timedelta 

	cli																; Interrupt Enable
bcd_compute:
	lda #0
	ldx #4
reset_bytes:
	sta bcd,x
	dex
	bpl reset_bytes											;	loop again only when x is not rolled back(negative)	
devide_loop:
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
	jmp devide_loop

got_reminder:
	lda number	;	Last nanugii bit 
	rol
	sta number
	lda number+1
	rol 
	sta number+1
	
	clc	;	Reset carry bit 
	lda mod10
	adc #"0"
	ldx #0
shift_loop:										; Shifts bytes to right to represent numbers in normal format
	ldy bcd,x
	sta bcd,x
	tya
	inx
	cpx #5											; Shifts bcd+0 ~ bcd+5 bytes. bcd+6 byte is null indicator to indicate end of array
	bne shift_loop	

	lda #16 	;	Ready iteration value for next digit
	sta iterations
	lda #0	;	Reset mod10 bytes for new reminder
	sta mod10
	sta mod10+1

	lda number	;	 Check if Last division resulated in zero 
	ora number + 1	
	beq update_display 
	jmp devide_loop

update_display:
	lda #%00000010						; Setting cursor to home position
	jsr lcd_instruction
	ldx #0
update_display_loop:				;	Printing one byte at a time 
	lda vram,x
	jsr print_char				
	inx
	cpx #80
	bne update_display_loop
loop:
	sec												; Calculating timedelta from timestamp
	lda systime
	sbc	timestamp
	cmp #50
	bne pass									; Check time  
	lda systime
	sta timestamp

vram_update:								; Update vram contents only at certain intervals
	jsr vram_reset						; Reset vram first
	ldx #0
	ldy #11
append_bcd:									; Update bcd with new bcd converted system time
	lda bcd,x
	beq	escape								; Escape loop when null byte(array terminator) read
	sta vram,y	
	inx
	iny
	jmp	append_bcd 
escape:
pass:												; Continusly compute bcd from system time
	lda systime
	sta number
	lda systime + 1
	sta number + 1
	jmp bcd_compute

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
	sei						 ; Disable Interrupts
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
	cli						 ; Enable interrupts
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
	sei							; Disable Interrupts
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
	cli						  ; Enable interrupts
  rts

vram_reset:
	ldx #0																			; Reset vram data
	lda #%00010000															; Empty lcd character
vram_reset_loop:
	sta	vram,x
	inx
	cpx #80
	bne vram_reset_loop
	rts


nmi: rti						
irq:
	pha							; Push mcu state into stack 
	txa
	pha
	tya
	pha

	lda IFR
	asl
	asl
	asl
	bcs systimer
	jmp end_interrupt

systimer:																; Add 1ms to systime and carry to all bytes(3)
	lda systime  
	adc #1
	sta systime  
	ldx #1
carry_loop:
	lda systime,x
	adc #0
	sta systime,x
	inx
	cpx #4
	bne carry_loop
	
	lda TIMER_HBYTE												; Restart timer2
	sta T2HIGHC
	jmp end_interrupt	
	
end_interrupt:
	pla																		; Recover mcu state to before interrupt
	tay
	pla
	tax
	pla
	rti

  .org $fffa
	.word nmi
  .word reset
  .word irq
