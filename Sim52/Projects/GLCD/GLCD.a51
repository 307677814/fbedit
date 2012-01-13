
; The processor clock speed is 24MHz.
; Cycle time is .500uS.
; Demo software to display a bit-mapped
; graphic on a 240x128 graphics display
; with a T6963C LCD controller.

PB_CD	BIT	P1.0
PB_R	BIT	P1.1
PB_W	BIT	P1.2
PB_RST	BIT	P1.3

	ORG	0000h
	LJMP	START		;program start

	ORG	0100h
START:
	; Initialize the T6963C
	CLR	PB_RST		;hardware reset
	NOP
	NOP
	NOP
	NOP
	SETB	PB_RST
	MOV	DPTR,#MSGI1	;initialization bytes
	LCALL	MSGC
	; Start of regular program
	MOV	DPTR,#MSGI2	;CG RAM address pointer set
	LCALL	MSGC
	MOV	DPTR,#MSGI4	;set auto mode
	LCALL	MSGC
	MOV	DPTR,#CGRAM	;set CG RAM
	LCALL	MSGD
	MOV	R1,#0B2h	;Auto Reset
	LCALL	WRITEC
	; Display graphic
	MOV	DPTR,#MSGI3	;graphic address pointer set
	LCALL	MSGC
	MOV	DPTR,#MSGI4	;set auto mode
	LCALL	MSGC
	MOV	DPTR,#GRAPHIC	;display graphic
	LCALL	MSGD
	MOV	R1,#0B2h	;Auto Reset
	LCALL	WRITEC
	; Display text1
	MOV	DPTR,#MSGI5	;text initialization bytes
	LCALL	MSGC
	MOV	DPTR,#MSGI4	;set auto mode
	LCALL	MSGC
	MOV	DPTR,#TEXT1	;display text
	LCALL	MSGDT
	MOV	R1,#0B2h	;Auto Reset
	LCALL	WRITEC
	; Display text2
	MOV	DPTR,#MSGI6	;text initialization bytes
	LCALL	MSGC
	MOV	DPTR,#MSGI4	;set auto mode
	LCALL	MSGC
	MOV	DPTR,#TEXT2	;display text
	LCALL	MSGDT
	MOV	R1,#0B2h	;Auto Reset
	LCALL	WRITEC
	SJMP	$		;infinite loop

;*************************************************
;SUBROUTINES
; MSGC sends the data pointed to by
; the DPTR to the graphics module
; as a series of commands with
; two parameters each.
MSGC:
	MOV	R0,#2		;# of data bytes
MSGC2:
	CLR	A
	MOVC	A,@A+DPTR	;get byte
	CJNE	A,#0A1h,MSGC3	;done?
	RET

MSGC3:
	MOV	R1,A
	LCALL	WRITED		;send it
	INC	DPTR
	DJNZ	R0,MSGC2
	CLR	A
	MOVC	A,@A+DPTR	;get command
	MOV	R1,A
	LCALL	WRITEC		;send command
	INC	DPTR
	SJMP	MSGC		;next command

; MSGD sends the data pointed to by
; the DPTR to the graphics module.
MSGD:
	CLR	A
	MOVC	A,@A+DPTR	;get byte
	CJNE	A,#0A1h,MSGD1	;done?
	RET

MSGD1:
	MOV	R1,A
	LCALL	WRITED		;send data
	INC	DPTR
	SJMP	MSGD

; MSGDT sends the data pointed to by
; the DPTR to the graphics module.
;20h is subtracted to get the psaudo ascii
MSGDT:
	CLR	A
	MOVC	A,@A+DPTR	;get byte
	CJNE	A,#0A1h,MSGDT1	;done?
	RET

MSGDT1:
	CLR	C
	SUBB	A,#20h		;Subtract 20h to get psaudo ascii
	MOV	R1,A
	LCALL	WRITED		;send data
	INC	DPTR
	SJMP	MSGDT

; WRITEC sends the byte in R1 to a
; graphics module as a command.
WRITEC:
	LCALL	STATUS		;display ready?
	SETB	PB_CD		;c/d = 1
WRITEC1:
	MOV	P2,R1		;set data
	CLR	PB_W		;strobe it
	SETB	PB_W
	RET

; WRITED sends the byte in R1 to the
; graphics module as data.
WRITED:
	LCALL	STATUS		;display ready?
	CLR	PB_CD		;c/d = 0
	SJMP	WRITEC1

; STATUS check to see that the graphic
; display is ready. It won't return
; until it is.
STATUS:
	SETB	PB_CD		;c/d=1
	MOV	P2,#0FFh	;P2 to input
	MOV	R3,#0Bh		;status bits mask
STAT1:
	CLR	PB_R		;read it
	MOV	A,P2
	SETB	PB_R
	ANL	A,R3		;status OK?
	CLR	C
	SUBB	A,R3
	JNZ	STAT1
	RET

;************************************************
; TABLES AND DATA
; Initialization bytes for 240x128
MSGI1:
	DB	00h,10h,40h	;text home address
	DB	1Eh,00h,41h	;text area
	DB	00h,00h,42h	;graphic home address
	DB	1Eh,00h,43h	;graphic area
	DB	00h,00h,81h	;mode set. EXOR Mode
	DB	04h,00h,22h	;offset register set, CG RAM area at 2000h to 27FFh
	DB	00h,00h,9Fh	;display mode set. Text on, Graphic on, Cursor on, Blink on
	DB	0A1h

MSGI2:
	DB	00h,24h,24h	;CG RAM address pointer set, character code 80h
	DB	0A1h

MSGI3:
	DB	00h,00h,24h	;graphic address pointer set
	DB	0A1h

MSGI4:
	DB	00h,00h,0B0h	;auto mode
	DB	0A1h

MSGI5:
	DB	53h,11h,24h	;text address pointer set. X=9, Y=11
	DB	0A1h

MSGI6:
	DB	6Ch,11h,24h	;text address pointer set. X=9, Y=11
	DB	55h,0Ch,21h	;Cursor pointer
	DB	00h,00h,0A0h	;1 line cursor
	DB	0A1h

CGRAM:
	;80h
	DB	00000000b
	DB	00000100b
	DB	00001110b
	DB	00010101b
	DB	00000100b
	DB	00000100b
	DB	00000100b
	DB	00000000b
	DB	0A1h

;240x128 Bitmap graphic data
;The graphic consists of 240/8*128=3840 bytes
;of binary data.
GRAPHIC:
	DB	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,0FFh,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,0FFh,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h
	DB	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	DB	0A1h

TEXT1:
	DB	'Hello World! ',80h,0A0h,0A1h		;NOTE! 20h is subtracted to get psaudo ascii

TEXT2:
	DB	'Simulatig graphic LCD',0A1h

	END
