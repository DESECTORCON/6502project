nmi:
irq:
	pha	;	Backing up registors so that when return from intrrupt
	txa	;	the code can run as right before the intrrupt	
	pha	
	tya
	pha
	
	lda number 
	adc #1
	sta number
	lda number + 1
	adc #0 
	sta number + 1

	pla
	tay
	pla
	tax
	pla	
		
	rti	


