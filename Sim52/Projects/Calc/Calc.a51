
LCDBUFF		equ	40h		;40h-4Fh 16 byte buffer
LCDBUFFSIZE	equ	16
CR		equ	50h		;Byte at address 50h holds 0Dh
LASTCHR		equ	51h		;Holds the last key pressed
FUNCTION	equ	52h		;Holds function +,-,* or /
NDIGITS		equ	53h		;Number of digits entered
MAXDIGITS	equ	8		;Max number of digits
FPOUTPTR	equ	54h		;Holds address of output character
FPOUTSTR	equ	55h		;Address of output string, max 16 bytes
NOENTRY		bit	20h.0
;CCE		bit	20h.1		;If set then CE/C has been pressed once

INTGRC		BIT	21h.1		;BIT SET IF INTEGER ERROR
ADD_IN		BIT	21h.3		;DCMPXZ IN BASIC BACKAGE
ZSURP		BIT	21h.6		;ZERO SUPRESSION FOR HEX PRINT
ARG_STACK	EQU	22h		;ARGUMENT STACK POINTER
FORMAT		EQU	23h		;LOCATION OF OUTPUT FORMAT BYTE
FP_STATUS	EQU	24h		;24 NOT used data pointer me
CONVT		EQU	66h		;String addr TO CONVERT NUMBERS

;RESET:***********************************************
		ORG	0000h
		LJMP	START		;RESET:
;IE0IRQ:**********************************************
		ORG	0003h
		RETI			;IE0IRQ:
;TF0IRQ:**********************************************
		ORG	000Bh
		RETI			;TF0IRQ:
;IE1IRQ:**********************************************
		ORG	0013h
		RETI			;IE1IRQ:
;TF1IRQ:**********************************************
		ORG	001Bh
		RETI			;TF1IRQ:
;RITIIRQ:*********************************************
		ORG	0023h
		RETI			;RITIIRQ:
;TF2EXF2IRQ:******************************************
		ORG	002Bh
		RETI			;TF2EXF2IRQ:
;*****************************************************

START:		MOV	CR,#0Dh
		MOV	ARG_STACK,#85h	;ARG STACK
		MOV	FORMAT,#00h	;FORMAT
		MOV	DPTR,#ZRO
		LCALL	PUSHC
		MOV	FUNCTION,#'+'
		ACALL	LCDINIT
		ACALL	LCDCLEAR
START0:		ACALL	LCDCLEARBUFF
		MOV	LCDBUFF+LCDBUFFSIZE-1,#'0'
		ACALL	LCDSHOW
		SETB	NOENTRY
		MOV	NDIGITS,#00h
START1:		ACALL	PSCANKEYB
		JZ	START1
		CJNE	A,#'C',START2
		JB	NOENTRY,START
		SJMP	START0
START2:		CJNE	A,#'+',START3
		PUSH	ACC
		ACALL	GETRESULT
		POP	FUNCTION
		SETB	NOENTRY
		MOV	NDIGITS,#00h
		SJMP	START1
START3:		CJNE	A,#'-',START4
		PUSH	ACC
		ACALL	GETRESULT
		POP	FUNCTION
		SETB	NOENTRY
		MOV	NDIGITS,#00h
		SJMP	START1
START4:		CJNE	A,#'*',START5
		PUSH	ACC
		ACALL	GETRESULT
		POP	FUNCTION
		SETB	NOENTRY
		MOV	NDIGITS,#00h
		SJMP	START1
START5:		CJNE	A,#'/',START6
		PUSH	ACC
		ACALL	GETRESULT
		POP	FUNCTION
		SETB	NOENTRY
		MOV	NDIGITS,#00h
		SJMP	START1
START6:		JB	NOENTRY,START10
		MOV	R7,NDIGITS
		CJNE	R7,#MAXDIGITS-1,$+3
		JNC	START1
		ACALL	LCDSCROLL
		ACALL	LCDSHOW
		SJMP	START1
START10:	PUSH	ACC
		ACALL	LCDCLEARBUFF
		MOV	LCDBUFF+LCDBUFFSIZE-1,#'0'
		POP	ACC
		CJNE	A,#'.',START11
		MOV	LCDBUFF+LCDBUFFSIZE-2,#'0'
START11:	CJNE	A,#'0',START12
		MOV	LCDBUFF+LCDBUFFSIZE-1,#'0'
		ACALL	LCDSHOW
		SJMP	START1
START12:	MOV	LCDBUFF+LCDBUFFSIZE-1,A
		ACALL	LCDSHOW
		CLR	NOENTRY
		AJMP	START1

GETRESULT:	JNB	NOENTRY,GETRESULT1
		MOV	A,ARG_STACK
		ADD	A,#6
		MOV	ARG_STACK,A
		MOV	R1,#LCDBUFF
		LCALL	FLOATING_POINT_INPUT
GETRESULT1:	MOV	R1,#LCDBUFF
		LCALL	FLOATING_POINT_INPUT
		MOV	A,FUNCTION
		ACALL	EXEC
		MOV	R0,#FPOUTSTR
		MOV	FPOUTPTR,R0
		MOV	R0,ARG_STACK
		LCALL	PUSHAS
		LCALL	FLOATING_POINT_OUTPUT
		ACALL	LCDCLEARBUFF
		MOV	R0,FPOUTPTR
		MOV	R1,#LCDBUFF+LCDBUFFSIZE-1
GETRESULT2:	DEC	R0
		MOV	A,@R0
		MOV	@R1,A
		DEC	R1
		CJNE	R0,#FPOUTSTR,GETRESULT2
		ACALL	LCDSHOW
		RET

EXEC:		CJNE	A,#'+',EXEC1
		LJMP	FLOATING_ADD
EXEC1:		CJNE	A,#'-',EXEC2
		LJMP	FLOATING_SUB
EXEC2:		CJNE	A,#'*',EXEC3
		LJMP	FLOATING_MUL
EXEC3:		CJNE	A,#'/',EXEC4
		LJMP	FLOATING_DIV
EXEC4:		RET

LCDSCROLL:	PUSH	ACC
		MOV	NDIGITS,#00h
		MOV	R0,#LCDBUFF
		MOV	R1,#LCDBUFF+1
		MOV	R7,#LCDBUFFSIZE-1
LCDSCROLL1:	MOV	A,@R1
		CJNE	A,#'.',LCDSCROLL2
		DEC	NDIGITS
LCDSCROLL2:	CJNE	A,#' ',LCDSCROLL3
		DEC	NDIGITS
LCDSCROLL3:	INC	NDIGITS
		MOV	@R0,A
		INC	R0
		INC	R1
		DJNZ	R7,LCDSCROLL1
		POP	ACC
		MOV	@R0,A
		RET

LCDSHOW:	CLR	A
		ACALL	LCDSETADR
		MOV	R7,#LCDBUFFSIZE
		MOV	R0,#LCDBUFF
		ACALL	LCDPRINTSTR
		RET

PSCANKEYB:	MOV	R7,#04h
		MOV	R6,#0Eh
		MOV	R5,#00h
PSCANKEYB1:	MOV	A,P1
		ANL	A,#0F0h
		ORL	A,R6
		MOV	P1,A
		MOV	A,P1
		ANL	A,#0F0h
		CJNE	A,#0F0h,PSCANKEYB2
		;Next column
		MOV	A,R6
		SETB	C
		RLC	A
		ANL	A,#0Fh
		MOV	R6,A
		;Wait loop
		DJNZ	R5,$
		DJNZ	R7,PSCANKEYB1
		;No keys down
		CLR	A
		SJMP	PSCANKEYB5
		;A key is down, find column and row
PSCANKEYB2:	MOV	R5,#04h
PSCANKEYB3:	DEC	R5		;Row
		RLC	A
		JC	PSCANKEYB3
		MOV	A,R6
		MOV	R6,#0FFh	;Column
PSCANKEYB4:	INC	R6
		RRC	A
		JC	PSCANKEYB4
		;Convert column and row to a character
		MOV	A,R5
		RL	A
		RL	A
		ORL	A,R6
		MOV	DPTR,#KEYS
		MOVC	A,@A+DPTR
		CJNE	A,LASTCHR,PSCANKEYB5
		;Previous key not released yet
		CLR	A
		SJMP	PSCANKEYB6
PSCANKEYB5:	MOV	LASTCHR,A
PSCANKEYB6:	PUSH	ACC
		MOV	A,P1
		ORL	A,#0Fh
		MOV	P1,A
		POP	ACC
		RET

;MMSCANKEYB:	MOV	R7,#04h
;		MOV	R6,#0Eh
;		MOV	R5,#00h
;		MOV	DPTR,#8000h
;MMSCANKEYB1:	MOVX	A,@DPTR
;		ANL	A,#0F0h
;		ORL	A,R6
;		MOVX	@DPTR,A
;		MOV	A,P1
;MOV 51h,A
;		ANL	A,#0F0h
;		CJNE	A,#0F0h,MMSCANKEYB2
;		;Next column
;		MOV	A,R6
;		SETB	C
;		RLC	A
;		ANL	A,#0Fh
;		MOV	R6,A
;		;Wait loop
;		DJNZ	R5,$
;		DJNZ	R7,MMSCANKEYB1
;		;No keys down
;		CLR	A
;		SJMP	MMSCANKEYB5
;		;A key is down, find column and row
;MMSCANKEYB2:	MOV	R5,#04h
;MMSCANKEYB3:	DEC	R5		;Row
;		RLC	A
;		JC	MMSCANKEYB3
;		MOV	A,R6
;		MOV	R6,#0FFh	;Column
;MMSCANKEYB4:	INC	R6
;		RRC	A
;		JC	MMSCANKEYB4
;		;Convert column and row to a character
;		MOV	A,R5
;		RL	A
;		RL	A
;		ORL	A,R6
;		MOV	DPTR,#KEYS
;		MOVC	A,@A+DPTR
;		CJNE	A,LASTCHR,MMSCANKEYB5
;		;Previous key not released yet
;		CLR	A
;		SJMP	MMSCANKEYB6
;MMSCANKEYB5:	MOV	LASTCHR,A
;MMSCANKEYB6:	MOV	DPTR,#8000h
;		PUSH	ACC
;		MOVX	A,@DPTR
;		ORL	A,#0Fh
;		MOVX	@DPTR,A
;		POP	ACC
;		RET

KEYS:		DB	'789+'
		DB	'456-'
		DB	'123*'
		DB	'C0./'

;------------------------------------------------------------------
;LCD Output.
;------------------------------------------------------------------
LCDDELAY:	PUSH	07h
		MOV	R7,#00h
		DJNZ	R7,$
		POP	07h
		RET

;A contains nibble, ACC.4 contains RS
LCDNIBOUT:	SETB	ACC.5		;E
		MOV	P2,A
		CLR	P2.5		;Negative edge on E
		RET

;A contains byte
LCDCMDOUT:	PUSH	ACC
		SWAP	A		;High nibble first
		ANL	A,#0Fh
		ACALL	LCDNIBOUT
		POP	ACC
		ANL	A,#0Fh
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY	;Wait for BF to clear
		RET

;A contains byte
LCDCHROUT:	PUSH	ACC
		SWAP	A		;High nibble first
		ANL	A,#0Fh
		SETB	ACC.4		;RS
		ACALL	LCDNIBOUT
		POP	ACC
		ANL	A,#0Fh
		SETB	ACC.4		;RS
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY	;Wait for BF to clear
		RET

LCDCLEAR:	MOV	A,#00000001b
		ACALL	LCDCMDOUT
		MOV	R7,#00h
LCDCLEAR1:	ACALL	LCDDELAY
		DJNZ	R7,LCDCLEAR1
		RET

;A contais address
LCDSETADR:	ORL	A,#10000000b
		ACALL	LCDCMDOUT
		RET

LCDPRINTSTR:	MOV	A,@R0
		ACALL	LCDCHROUT
		INC	R0
		DJNZ	R7,LCDPRINTSTR
		RET

LCDINIT:	MOV	A,#00000011b	;Function set
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY	;Wait for BF to clear
		MOV	A,#00101000b
		ACALL	LCDCMDOUT
		MOV	A,#00101000b
		ACALL	LCDCMDOUT
		MOV	A,#00001100b	;Display ON/OFF
		ACALL	LCDCMDOUT
		ACALL	LCDCLEAR	;Clear
		MOV	A,#00000110b	;Cursor direction
		ACALL	LCDCMDOUT
		RET

LCDCLEARBUFF:	MOV	R0,#LCDBUFF
		MOV	R7,#LCDBUFFSIZE
		MOV	A,#20H
LCDCLEARBUFF1:	MOV	@R0,A
		INC	R0
		DJNZ	R7,LCDCLEARBUFF1
		RET

		ORG	1000h

$include	(FP52INT.a51)

		END