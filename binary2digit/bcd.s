devide:
	; BCD array nullify
	lda #0
	sta bcd
	sta bcd + 1
	sta bcd + 2
	sta bcd + 3
	sta bcd + 4
	sta bcd + 5
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
	
	;	Add BCD digit to char array 
	lda mod10
	clc
	adc #"0"
	ldx #0	;	BCD char array pos
shift_bcds:
	ldy bcd , x
	sta bcd	, x
	tya
	inx
	cpx #6
	bne shift_bcds

	lda #16 	;	Ready iteration value for next digit
	sta iterations

	lda #0	;	Reset mod10 bytes for new reminder
	sta mod10
	sta mod10+1

	lda number	;	 Check if Last division resulated in zero 
	ora number + 1	
	beq devide_complete	

	clc	;	Reset carry bit
	jmp devide_loop


