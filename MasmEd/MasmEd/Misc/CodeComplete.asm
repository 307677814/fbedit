
CHARS struct
	len			dd ?		;String len
	max			dd ?		;Max size
	state		dd ?		;Line state
	bmid		dd ?		;Bookmark ID
	errid		dd ?		;Error ID
CHARS ends

.const

szInvoke		db 'INVOKE',0
szPp			db 'Pp',0
szC				db 'C',0

.data?

lpOldCCProc		dd ?
ccchrg			CHARRANGE <?>

.code

CodeCompleteProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_TAB || eax==VK_RETURN
			invoke SendMessage,hREd,WM_CHAR,VK_TAB,0
			jmp		Ex
		.elseif eax==VK_ESCAPE
			invoke ShowWindow,hWin,SW_HIDE
			jmp		Ex
		.endif
	.elseif eax==WM_LBUTTONDBLCLK
		invoke SendMessage,hREd,WM_CHAR,VK_TAB,0
		jmp		Ex
	.endif
	invoke CallWindowProc,lpOldCCProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

CodeCompleteProc endp

CreateCodeComplete proc

	invoke CreateWindowEx,NULL,addr szCCLBClassName,NULL,WS_CHILD or WS_BORDER or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or STYLE_USEIMAGELIST,0,0,0,0,hWnd,NULL,hInstance,0
	mov		hCCLB,eax
	invoke SetWindowLong,hCCLB,GWL_WNDPROC,offset CodeCompleteProc
	mov		lpOldCCProc,eax
	invoke CreateWindowEx,NULL,addr szCCTTClassName,NULL,WS_POPUP or WS_BORDER or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,0,0,0,0,hWnd,NULL,hInstance,0
	mov		hCCTT,eax
	invoke SendMessage,hTab,WM_GETFONT,0,0
	push	eax
	invoke SendMessage,hCCLB,WM_SETFONT,eax,FALSE
	pop		eax
	invoke SendMessage,hCCTT,WM_SETFONT,eax,FALSE
	ret

CreateCodeComplete endp

UpdateApiCallList proc uses esi edi,lpWord:DWORD
	LOCAL	nCount:DWORD

	mov		nCount,0
	mov		eax,lpWord
	.if byte ptr [eax]
		mov		edi,hCCLB
		invoke SendMessage,edi,CCM_CLEAR,0,0
		invoke SendMessage,edi,WM_SETREDRAW,FALSE,0
		invoke SendMessage,hProperty,PRM_FINDFIRST,addr szPp,lpWord
		.if eax
			push	eax
			invoke SendMessage,hProperty,PRM_FINDGETTYPE,0,0
			xor		ecx,ecx
			.if eax=='p'
				mov		ecx,1
			.endif
			pop		edx
			invoke SendMessage,edi,CCM_ADDITEM,ecx,edx
			inc		nCount
			.while TRUE
				invoke SendMessage,hProperty,PRM_FINDNEXT,0,0
				.break .if !eax
				push	eax
				invoke SendMessage,hProperty,PRM_FINDGETTYPE,0,0
				xor		ecx,ecx
				.if eax=='p'
					mov		ecx,1
				.endif
				pop		edx
push	edx
				invoke SendMessage,edi,CCM_ADDITEM,ecx,edx
pop		edx
.if dword ptr [edx]=='oToD'
	push	edx
	invoke lstrlen,edx
	pop		edx
	lea		edx,[edx+eax+1]
	PrintStringByAddr edx
	push	edx
	invoke lstrlen,edx
	pop		edx
	lea		edx,[edx+eax+1]
	PrintStringByAddr edx
	push	edx
	invoke lstrlen,edx
	pop		edx
	lea		edx,[edx+eax+1]
	PrintStringByAddr edx
.endif
				inc		nCount
			.endw
		.endif
		.if nCount
			invoke SendMessage,edi,CCM_SORT,FALSE,0
		.endif
		invoke SendMessage,edi,WM_SETREDRAW,TRUE,0
		invoke SendMessage,edi,CCM_SETCURSEL,0,0
	.endif
	mov		eax,nCount
	ret

UpdateApiCallList endp

UpdateApiConstList proc uses esi edi,lpApi:DWORD,lpWord:DWORD,lpCPos:DWORD
	LOCAL	nCount:DWORD

	invoke SendMessage,hCCLB,CCM_CLEAR,0,0
	invoke SendMessage,hProperty,PRM_FINDFIRST,addr szC,lpApi
	.if eax
		mov		esi,eax
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		mov		nCount,0
		mov		eax,lpWord
	  @@:
		.while (byte ptr [eax]==VK_SPACE || byte ptr [eax]==VK_TAB) && eax<lpCPos
			inc		eax
		.endw
		mov		lpWord,eax
		.while byte ptr [eax] && byte ptr [eax]!=',' && eax<lpCPos
			.if byte ptr [eax]==VK_SPACE || byte ptr [eax]==VK_TAB
				jmp		@b
			.endif
			inc		eax
		.endw
		mov		edi,offset ConstData
		.while byte ptr [esi]
			mov		edx,lpWord
			call	Filter
			.if !eax
				push	edi
				.while byte ptr [esi] && byte ptr [esi]!=','
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
				.endw
				mov		byte ptr [edi],0
				inc		edi
				pop		eax
				invoke SendMessage,hCCLB,CCM_ADDITEM,2,eax
				inc		nCount
			.else
				.while byte ptr [esi] && byte ptr [esi]!=','
					inc		esi
				.endw
			.endif
			.if byte ptr [esi]
				inc		esi
			.endif
		.endw
		.if nCount
			invoke SendMessage,edi,CCM_SORT,FALSE,0
			invoke SendMessage,hCCLB,CCM_SETCURSEL,0,0
			mov		eax,lpWord
		.else
			xor		eax,eax
		.endif
		ret
	.endif
	xor		eax,eax
	ret

Filter:
	mov		ecx,esi
  @@:
	mov		al,[edx]
	.if al==VK_SPACE || al==VK_TAB || al==','
		xor		al,al
	.endif
	.if al
		mov		ah,[ecx]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		inc		edx
		inc		ecx
		sub		al,ah
		je		@b
	.endif
	movsx	eax,al
	retn

UpdateApiConstList endp

UpdateApiToolTip proc uses esi edi,lpWord:DWORD
	LOCAL	tt:TOOLTIP

	mov		eax,lpWord
	.if byte ptr [eax]
		invoke RtlZeroMemory,addr tt,sizeof TOOLTIP
		mov		tt.lpszType,offset szPp
		mov		eax,lpWord
		mov		tt.lpszLine,eax
		invoke SendMessage,hProperty,PRM_GETTOOLTIP,FALSE,addr tt
		.if tt.lpszApi
			invoke lstrlen,tt.lpszApi
			add		eax,tt.lpszApi
			inc		eax
			mov		edx,tt.lpszApi
			mov		ecx,tt.nPos
			jmp		Ex
		.endif
	.endif
	xor		eax,eax
	xor		ecx,ecx
	xor		edx,edx
  Ex:
	ret

UpdateApiToolTip endp

IsLineInvoke proc uses ebx,cpline:DWORD

	mov		edx,offset LineTxt
	mov		ebx,cpline
	call	SkipWhiteSpace
	mov		ecx,offset szInvoke
	dec		ecx
	dec		edx
	inc		ebx
  @@:
	inc		ecx
	inc		edx
	dec		ebx
	je		@f
	mov		al,[ecx]
	.if al
		mov		ah,[edx]
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		sub		al,ah
		je		@b
	.endif
	movsx	eax,al
	.if !eax
		call	SkipWhiteSpace
		mov		eax,edx
		sub		eax,offset LineTxt
	.else
  @@:
		xor		eax,eax
	.endif
	ret

SkipWhiteSpace:
	.while (byte ptr [edx]==VK_TAB || byte ptr [edx]==VK_SPACE) && ebx
		inc		edx
		dec		ebx
	.endw
	retn

IsLineInvoke endp

ApiListBox proc uses esi edi,lpRASELCHANGE:DWORD
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	tti:TTITEM
	LOCAL	cpline:DWORD
	LOCAL	buffer[256]:BYTE

	mov		esi,lpRASELCHANGE
	mov		edx,[esi].RASELCHANGE.lpLine
	xor		ecx,ecx
	.while ecx<[edx].CHARS.len && ecx<16384
		mov		al,[edx+ecx+sizeof CHARS]
		.if al==VK_RETURN
			xor		al,al
		.endif
		mov		LineTxt[ecx],al
		inc		ecx
	.endw
	xor		al,al
	mov		LineTxt[ecx],al
	mov		eax,[esi].RASELCHANGE.chrg.cpMin
	mov		edx,[esi].RASELCHANGE.cpLine
	mov		ccchrg.cpMin,edx
	mov		ccchrg.cpMax,eax
	sub		eax,edx
	mov		cpline,eax
	invoke IsLineInvoke,eax
	.if eax
		add		ccchrg.cpMin,eax
		lea		esi,LineTxt[eax]
		mov		eax,cpline
		mov		byte ptr LineTxt[eax],0
		invoke UpdateApiCallList,esi 
		.if eax
			invoke ShowWindow,hCCTT,SW_HIDE
			invoke GetCaretPos,addr pt
			invoke ClientToScreen,hREd,addr pt
			invoke ScreenToClient,hWnd,addr pt
			invoke GetClientRect,hWnd,addr rect
			mov		eax,pt.y
			add		eax,150+20
			.if eax>rect.bottom
				sub		pt.y,155
			.else
				add		pt.y,20
			.endif
			invoke SetWindowPos,hCCLB,HWND_TOP,pt.x,pt.y,200,150,SWP_SHOWWINDOW or SWP_NOACTIVATE
			invoke ShowWindow,hCCLB,SW_SHOWNA
		.else
			invoke ShowWindow,hCCLB,SW_HIDE
			invoke UpdateApiToolTip,esi
			.if eax
				mov		tti.lpszRetType,0
				mov		tti.lpszDesc,0
				mov		tti.novr,0
				mov		tti.nsel,0
				mov		tti.nwidth,0
				mov		tti.lpszApi,edx
				mov		tti.lpszParam,eax
				mov		tti.nitem,ecx
				inc		ecx
				invoke DwToAscii,ecx,addr buffer
				invoke lstrcat,addr buffer,tti.lpszApi
				mov		eax,cpline
				add		eax,offset LineTxt
				sub		eax,esi
				xor		ecx,ecx
				xor		edx,edx
				.while edx<eax
					.if byte ptr [esi+edx]=="'"
						inc		edx
						.while edx<eax && byte ptr [esi+edx]!="'"
							inc		edx
						.endw
					.elseif byte ptr [esi+edx]=='"'
						inc		edx
						.while edx<eax && byte ptr [esi+edx]!='"'
							inc		edx
						.endw
					.elseif byte ptr [esi+edx]==','
						inc		ecx
						lea		edi,[esi+edx+1]
					.endif
					inc		edx
				.endw
				mov		eax,cpline
				add		eax,offset LineTxt
				invoke UpdateApiConstList,addr buffer,edi,eax
				.if eax
					mov		edi,eax
					sub		edi,offset LineTxt
					mov		esi,lpRASELCHANGE
					add		edi,[esi].RASELCHANGE.cpLine
					mov		ccchrg.cpMin,edi
					mov		eax,[esi].RASELCHANGE.chrg.cpMin
					sub		eax,[esi].RASELCHANGE.cpLine
					.while byte ptr LineTxt[eax] && byte ptr LineTxt[eax]!=VK_SPACE && byte ptr LineTxt[eax]!=VK_TAB && byte ptr LineTxt[eax]!=','
						inc		eax
					.endw
					add		eax,[esi].RASELCHANGE.cpLine
					mov		ccchrg.cpMax,eax
					invoke ShowWindow,hCCTT,SW_HIDE
					invoke GetCaretPos,addr pt
					invoke ClientToScreen,hREd,addr pt
					invoke ScreenToClient,hWnd,addr pt
					invoke GetClientRect,hWnd,addr rect
					mov		eax,pt.y
					add		eax,150+20
					.if eax>rect.bottom
						sub		pt.y,155
					.else
						add		pt.y,20
					.endif
					invoke SetWindowPos,hCCLB,HWND_TOP,pt.x,pt.y,200,150,SWP_SHOWWINDOW or SWP_NOACTIVATE
					invoke ShowWindow,hCCLB,SW_SHOWNA
					mov		fLBConst,TRUE
				.else
					invoke ShowWindow,hCCLB,SW_HIDE
					invoke GetCaretPos,addr pt
					invoke ClientToScreen,hREd,addr pt
					add		pt.y,20
					invoke SendMessage,hCCTT,TTM_SETITEM,0,addr tti
					sub		pt.x,eax
					invoke SetWindowPos,hCCTT,HWND_TOP,pt.x,pt.y,0,0,SWP_NOACTIVATE or SWP_NOSIZE
					invoke ShowWindow,hCCTT,SW_SHOWNA
					invoke InvalidateRect,hCCTT,NULL,TRUE
				.endif
			.else
				call	HideAll
			.endif
		.endif
	.else
		call	HideAll
	.endif
	ret

HideAll:
	invoke ShowWindow,hCCTT,SW_HIDE
	invoke ShowWindow,hCCLB,SW_HIDE
	retn

ApiListBox endp
