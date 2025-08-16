nmi:
irq:
	pha															;	Backing up registors so that when return from intrrupt
	txa															;	the code can run as right before the intrrupt	
	pha	
	sty ystack

	lda IFR
	ror															;	The second bit(ca1 interrupt flag) will be in carry flag
	ror
	bcs inc_num											;	 Runs inc number only when carry bit is 1
	ror
	bcs shift_load									;	Load new 1 byte to debugger	
	jmp end_interrupt								;	Not coded interrupt, ignore

inc_num:	
	clc															;	Clear carry bit 	
	lda number 
	adc #1
	sta number
	lda number + 1
	adc #0 
	sta number + 1
	bit PORTA												;	Read to clear interrupt flag ca1	
	jmp end_interrupt

shift_load:
	lda dbuf
	sta SR													; Write into sr latch. Also clears interrupt flag
	jmp end_interrupt

end_interrupt:	
	ldy ystack
	pla
	tax
	pla	
	rti	


