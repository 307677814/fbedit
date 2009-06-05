SymEnumSourceFiles				PROTO	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
;SymEnumSourceLines				PROTO	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

SOURCEFILE struct DWORD
	ModBase					QWORD ?
	FileName				DWORD ?
SOURCEFILE ends

SRCCODEINFO struct DWORD
	SizeOfStruct            DWORD ?
	Key                     PVOID ?
	ModBase                 QWORD ?
	Obj         			BYTE MAX_PATH+1 dup(?)
	FileName				BYTE MAX_PATH+1 dup(?)
	LineNumber              DWORD ?
	Address                 DWORD ?
SRCCODEINFO ends

.const

szVersionInfo					db '\StringFileInfo\040904B0\FileVersion',0
szVersion						db 'DbgHelp version %s',0
szSymOk							db 'Symbols OK',0
szSymbol						db 'Name: %s Adress: %X Size %u',0
szSymEnumSourceFiles			db 'SymEnumSourceFiles',0
szSourceFile					db 'FileName: %s',0
szSymEnumSourceLines			db 'SymEnumSourceLines',0
szSourceLine					db 'FileName: %s Adress: %X Line %u',0
szSymLoadModule					db 'SymLoadModule failed.',0
szSymInitialize					db 'SymInitialize failed.',0
szSymEnumTypes					db 'SymEnumTypes',0
szFinal							db 'DbgHelp found %u sources containing %u lines and %u symbols,',0Dh,0

.data?

dwModuleBase					DWORD ?
im								IMAGEHLP_MODULE <>

.code

GetDbgHelpVersion proc
	LOCAL	buffer[2048]:BYTE
	LOCAL	lpbuff:DWORD
	LOCAL	lpsize:DWORD

	invoke GetFileVersionInfo,addr DbgHelpDLL,NULL,sizeof buffer,addr buffer
	.if eax
		invoke VerQueryValue,addr buffer,addr szVersionInfo,addr lpbuff,addr lpsize
		.if eax
			mov		eax,lpbuff
			invoke wsprintf,addr buffer,addr szVersion,eax
			invoke PutString,addr buffer
		.endif
	.endif
	ret

GetDbgHelpVersion endp

EnumSymbolsCallback proc uses edi,SymbolName:DWORD,SymbolAddress:DWORD,SymbolSize:DWORD,UserContext:DWORD
	LOCAL	buffer[512]:BYTE

	.if SymbolSize
		.if fOptions & 1
			invoke wsprintf,addr buffer,addr szSymbol,SymbolName,SymbolAddress,SymbolSize
			invoke PutString,addr buffer
		.endif
		mov		eax,dbg.inxsymbol
		mov		edx,sizeof DEBUGSYMBOL
		mul		edx
		mov		edi,dbg.hMemSymbol
		lea		edi,[edi+eax]
		mov		eax,SymbolAddress
		mov		[edi].DEBUGSYMBOL.Address,eax
		mov		eax,SymbolSize
		mov		[edi].DEBUGSYMBOL.nSize,eax
		invoke lstrcpy,addr [edi].DEBUGSYMBOL.szName,SymbolName
		inc		dbg.inxsymbol
	.endif
	mov		eax,TRUE
	ret

EnumSymbolsCallback endp

EnumSourceFilesCallback proc uses ebx edi,pSourceFile:DWORD,UserContext:DWORD
	LOCAL	buffer[512]:BYTE

	mov		ebx,pSourceFile
	.if fOptions & 1
		invoke wsprintf,addr buffer,addr szSourceFile,[ebx].SOURCEFILE.FileName
		invoke PutString,addr buffer
	.endif
	mov		eax,dbg.inxsource
	mov		edx,sizeof DEBUGSOURCE
	mul		edx
	mov		edi,dbg.hMemSource
	lea		edi,[edi+eax]
	mov		eax,dbg.inxsource
	mov		[edi].DEBUGSOURCE.FileID,ax
	invoke lstrcpy,addr [edi].DEBUGSOURCE.FileName,[ebx].SOURCEFILE.FileName
	inc		dbg.inxsource
	mov		eax,TRUE
	ret

EnumSourceFilesCallback endp

EnumLinesCallback proc uses ebx esi edi,pLineInfo:DWORD,UserContext:DWORD
	LOCAL	buffer[512]:BYTE

	mov		ebx,pLineInfo
	.if fOptions & 1
		invoke wsprintf,addr buffer,addr szSourceLine,addr [ebx].SRCCODEINFO.FileName,[ebx].SRCCODEINFO.Address,[ebx].SRCCODEINFO.LineNumber
		invoke PutString,addr buffer
	.endif
	; Find source file
	xor		ecx,ecx
	.while ecx<dbg.inxsource
		push	ecx
		mov		eax,ecx
		mov		edx,sizeof DEBUGSOURCE
		mul		edx
		mov		esi,dbg.hMemSource
		lea		esi,[esi+eax]
		invoke lstrcmpi,addr [esi].DEBUGSOURCE.FileName,addr [ebx].SRCCODEINFO.FileName
		.if !eax
			mov		eax,dbg.inxline
			mov		edx,sizeof DEBUGLINE
			mul		edx
			mov		edi,dbg.hMemLine
			lea		edi,[edi+eax]
			mov		ax,[esi].DEBUGSOURCE.FileID
			mov		[edi].DEBUGLINE.FileID,ax
			mov		eax,[ebx].SRCCODEINFO.LineNumber
			mov		[edi].DEBUGLINE.LineNumber,eax
			mov		eax,[ebx].SRCCODEINFO.Address
			mov		[edi].DEBUGLINE.Address,eax
;			mov		[edi].DEBUGLINE.SourceByte,0
;			mov		[edi].DEBUGLINE.BpSet,FALSE
;			mov		[edi].DEBUGLINE.NoDebug,FALSE
;			mov		[edi].DEBUGLINE.BreakPoint,FALSE
			inc		dbg.inxline
			pop		ecx
			.break
		.endif
		pop		ecx
		inc		ecx
	.endw
	mov		eax,TRUE
	ret

EnumLinesCallback endp

DbgHelp proc uses ebx,hProcess:DWORD,lpFileName
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetDbgHelpVersion
	invoke SymInitialize,hProcess,0,FALSE
	.if eax
		invoke SymLoadModule,hProcess,0,lpFileName,0,0,0
		.if eax
			mov		dwModuleBase,eax
			mov		im.SizeOfStruct,sizeof IMAGEHLP_MODULE
			invoke SymGetModuleInfo,hProcess,dwModuleBase,addr im
			.if im.SymType1!=SymNone
				.if fOptions & 1
					invoke PutString,addr szSymOk
				.endif
				invoke SymEnumerateSymbols,hProcess,dwModuleBase,addr EnumSymbolsCallback,0
				;invoke GetProcAddress,hDbgHelpDLL,addr szSymEnumSourceFiles
				.if fOptions & 1
					invoke PutString,addr szSymEnumSourceFiles
				.endif
				invoke SymEnumSourceFiles,hProcess,dwModuleBase,0,0,offset EnumSourceFilesCallback,0
				;invoke SymEnumSourceLines,hProcess,dwModuleBase,0,0,0,0,0,offset EnumLinesCallback,0
				invoke GetProcAddress,hDbgHelpDLL,addr szSymEnumSourceLines
				.if eax
					mov		ebx,eax
					.if fOptions & 1
						invoke PutString,addr szSymEnumSourceLines
					.endif
					push	0
					push	offset EnumLinesCallback
					push	0
					push	0
					push	0
					push	0
					push	0
					push	dwModuleBase
					push	hProcess
					call	ebx
				.endif
;				push 0
;				push	dwModuleBase
;				push	hProcess
;				call SymFunctionTableAccess
				;invoke SymEnumTypes,hProcess,dwModuleBase,EnumerateSymbolsCallback,0
;				invoke GetProcAddress,hDbgHelpDLL,addr szSymEnumTypes
;				.if eax
;					mov		ebx,eax
;					.if fOptions & 1
;						invoke PutString,addr szSymEnumTypes
;					.endif
;					push	1
;					push	offset EnumSymbolsCallback
;					push	0
;					push	dwModuleBase
;					push	hProcess
;					call	ebx
;				.endif
				push 0
				invoke SymUnloadModule,hProcess,dwModuleBase
			.endif
		.else
			invoke PutString,addr szSymLoadModule
		.endif
		invoke SymCleanup,hProcess
		invoke wsprintf,addr buffer,addr szFinal,dbg.inxsource,dbg.inxline,dbg.inxsymbol
		invoke PutString,addr buffer
	.else
		invoke PutString,addr szSymInitialize
	.endif
	ret

DbgHelp endp
