nmi:
irq:
	lda IFR
	ror	;	The second bit(ca1 interrupt flag) will be in carry flag
	ror
	bcc end_interrupt		;	 Runs inc number only when carry bit is 1
	pha	;	Backing up registors so that when return from intrrupt
	txa	;	the code can run as right before the intrrupt	
	pha	
	tya
	pha
	
	clc	;	Clear carry bit 	
	lda number 
	adc #1
	sta number
	lda number + 1
	adc #0 
	sta number + 1
	bit PORTA	;	Read to clear interrupt flag ca1	

	pla
	tay
	pla
	tax
	pla	
end_interrupt:	
	rti	


