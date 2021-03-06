
IDD_DLGTRIPLOG      equ 1300
IDC_LSTFILES        equ 1301
IDC_EDTFILE         equ 1302
IDC_BTNDELETE		equ 1303

.const

szStartLog			BYTE 'Start Trip Logging',0
szPlayLog			BYTE 'Replay Trip Log',0
szLogPath			BYTE '\TripLog',0
szLogFileName		BYTE 'TripLog%s_%s.log',0

szOpenTrip			BYTE 'Open Trip',0
szSaveTrip			BYTE 'Save Trip',0
szTripPath			BYTE '\Trips',0
szTrpFileName		BYTE 'Trip%s_%s.trp',0

szOpenDist			BYTE 'Open Distance',0
szSaveDist			BYTE 'Save Distance',0
szDistPath			BYTE '\Distance',0
szDstFileName		BYTE 'Dist%s_%s.dst',0

szOpenTrail			BYTE 'Open Trail',0
szSaveTrail			BYTE 'Save Trail',0
szTrailPath			BYTE '\Trails',0
szTrlFileName		BYTE 'Trail%s_%s.trl',0

szSonarPath			BYTE '\Sonar',0
szSonarFileName		BYTE 'Sonar%s_%s.snr',0
szStartSonarLog		BYTE 'Start Sonar Logging',0
szPlaySonarLog		BYTE 'Replay Sonar Log',0

szSaveNMEA			BYTE 'Save NMEA log',0

szAllFiles			BYTE '\*.*',0


szDateFmtFile		BYTE 'yyyyMMdd',0
szTimeFmtFile		BYTE 'HHmm',0

.data?

fSaveFile			DWORD ?
szPath				BYTE MAX_PATH dup(?)
szFile				BYTE MAX_PATH dup(?)

.code

TripLogProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	datebuff[16]:BYTE
	LOCAL	timebuff[16]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		fSaveFile,FALSE
		invoke strcpy,addr szPath,addr szAppPath
		mov		eax,lParam
		.if eax==IDM_LOG_START
			invoke strcat,addr szPath,addr szLogPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szStartLog
			invoke GetDateFormat,NULL,NULL,NULL,offset szDateFmtFile,addr datebuff,sizeof datebuff
			invoke GetTimeFormat,NULL,NULL,NULL,offset szTimeFmtFile,addr timebuff,sizeof timebuff
			invoke wsprintf,addr buffer,addr szLogFileName,addr datebuff,addr timebuff
			invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			mov		fSaveFile,TRUE
		.elseif eax==IDM_LOG_REPLAY
			invoke strcat,addr szPath,addr szLogPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szPlayLog
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETCURSEL,0,0
			.if eax!=LB_ERR
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,0,addr buffer
				invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			.endif
			invoke GetDlgItem,hWin,IDC_EDTFILE
			mov		ebx,eax
			invoke GetWindowLong,ebx,GWL_STYLE
			or		eax,WS_DISABLED
			invoke SetWindowLong,ebx,GWL_STYLE,eax
		.elseif eax==IDM_FILE_OPENTRIP
			invoke strcat,addr szPath,addr szTripPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szOpenTrip
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETCURSEL,0,0
			.if eax!=LB_ERR
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,0,addr buffer
				invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			.endif
			invoke GetDlgItem,hWin,IDC_EDTFILE
			mov		ebx,eax
			invoke GetWindowLong,ebx,GWL_STYLE
			or		eax,WS_DISABLED
			invoke SetWindowLong,ebx,GWL_STYLE,eax
		.elseif eax==IDM_FILE_SAVETRIP
			invoke strcat,addr szPath,addr szTripPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szSaveTrip
			invoke GetDateFormat,NULL,NULL,NULL,offset szDateFmtFile,addr datebuff,sizeof datebuff
			invoke GetTimeFormat,NULL,NULL,NULL,offset szTimeFmtFile,addr timebuff,sizeof timebuff
			invoke wsprintf,addr buffer,addr szTrpFileName,addr datebuff,addr timebuff
			invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			mov		fSaveFile,TRUE
		.elseif eax==IDM_FILE_OPENDIST
			invoke strcat,addr szPath,addr szDistPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szOpenDist
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETCURSEL,0,0
			.if eax!=LB_ERR
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,0,addr buffer
				invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			.endif
			invoke GetDlgItem,hWin,IDC_EDTFILE
			mov		ebx,eax
			invoke GetWindowLong,ebx,GWL_STYLE
			or		eax,WS_DISABLED
			invoke SetWindowLong,ebx,GWL_STYLE,eax
		.elseif eax==IDM_FILE_SAVEDIST
			invoke strcat,addr szPath,addr szDistPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szSaveDist
			invoke GetDateFormat,NULL,NULL,NULL,offset szDateFmtFile,addr datebuff,sizeof datebuff
			invoke GetTimeFormat,NULL,NULL,NULL,offset szTimeFmtFile,addr timebuff,sizeof timebuff
			invoke wsprintf,addr buffer,addr szDstFileName,addr datebuff,addr timebuff
			invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			mov		fSaveFile,TRUE
		.elseif eax==IDM_FILE_OPENTRAIL
			invoke strcat,addr szPath,addr szTrailPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szOpenTrail
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETCURSEL,0,0
			.if eax!=LB_ERR
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,0,addr buffer
				invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			.endif
			invoke GetDlgItem,hWin,IDC_EDTFILE
			mov		ebx,eax
			invoke GetWindowLong,ebx,GWL_STYLE
			or		eax,WS_DISABLED
			invoke SetWindowLong,ebx,GWL_STYLE,eax
		.elseif eax==IDM_FILE_SAVETRAIL
			invoke strcat,addr szPath,addr szTrailPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szSaveTrail
			invoke GetDateFormat,NULL,NULL,NULL,offset szDateFmtFile,addr datebuff,sizeof datebuff
			invoke GetTimeFormat,NULL,NULL,NULL,offset szTimeFmtFile,addr timebuff,sizeof timebuff
			invoke wsprintf,addr buffer,addr szTrlFileName,addr datebuff,addr timebuff
			invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			mov		fSaveFile,TRUE
		.elseif eax==IDM_LOG_STARTSONAR
			invoke strcat,addr szPath,addr szSonarPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szStartSonarLog
			invoke GetDateFormat,NULL,NULL,NULL,offset szDateFmtFile,addr datebuff,sizeof datebuff
			invoke GetTimeFormat,NULL,NULL,NULL,offset szTimeFmtFile,addr timebuff,sizeof timebuff
			invoke wsprintf,addr buffer,addr szSonarFileName,addr datebuff,addr timebuff
			invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			mov		fSaveFile,TRUE
		.elseif eax==IDM_LOG_REPLAYSONAR
			invoke strcat,addr szPath,addr szSonarPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szPlaySonarLog
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETCURSEL,0,0
			.if eax!=LB_ERR
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,0,addr buffer
				invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			.endif
			invoke GetDlgItem,hWin,IDC_EDTFILE
			mov		ebx,eax
			invoke GetWindowLong,ebx,GWL_STYLE
			or		eax,WS_DISABLED
			invoke SetWindowLong,ebx,GWL_STYLE,eax
		.elseif eax==IDM_GPS_SAVE
			invoke strcat,addr szPath,addr szLogPath
			invoke strcpy,addr buffer,addr szPath
			invoke strcat,addr buffer,addr szAllFiles
			invoke DlgDirList,hWin,addr buffer,IDC_LSTFILES,NULL,DDL_READWRITE
			invoke SetWindowText,hWin,addr szSaveNMEA
			invoke GetDateFormat,NULL,NULL,NULL,offset szDateFmtFile,addr datebuff,sizeof datebuff
			invoke GetTimeFormat,NULL,NULL,NULL,offset szTimeFmtFile,addr timebuff,sizeof timebuff
			invoke wsprintf,addr buffer,addr szLogFileName,addr datebuff,addr timebuff
			invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
			mov		fSaveFile,TRUE
		.endif
		.if !fSaveFile
			invoke GetDlgItem,hWin,IDC_BTNDELETE
			invoke ShowWindow,eax,SW_SHOWNA
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetDlgItemText,hWin,IDC_EDTFILE,addr buffer,sizeof buffer
				invoke strcpy,addr szFile,addr szPath
				invoke strcat,addr szFile,addr szBS
				invoke strcat,addr szFile,addr buffer
				.if fSaveFile
					invoke GetFileAttributes,offset szFile
					.if eax==INVALID_HANDLE_VALUE
						invoke SendMessage,hWin,WM_CLOSE,NULL,offset szFile
					.else
						invoke strcpy,addr szbuff,addr szAskOverwrite
						invoke strcat,addr szbuff,addr buffer
						invoke MessageBox,hWin,addr szbuff,addr szAppName,MB_ICONQUESTION or MB_YESNO
						.if eax==IDYES
							invoke SendMessage,hWin,WM_CLOSE,NULL,offset szFile
						.endif
					.endif
				.else
					invoke SendMessage,hWin,WM_CLOSE,NULL,offset szFile
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNDELETE
				invoke GetDlgItemText,hWin,IDC_EDTFILE,addr buffer,sizeof buffer
				invoke strlen,addr buffer
				.if eax
					invoke strcpy,addr szbuff,addr szAskDelete
					invoke strcat,addr szbuff,addr buffer
					invoke MessageBox,hWin,addr szbuff,addr szAppName,MB_ICONQUESTION or MB_YESNO
					.if eax==IDYES
						invoke strcpy,addr szFile,addr szPath
						invoke strcat,addr szFile,addr szBS
						invoke strcat,addr szFile,addr buffer
						invoke GetFileAttributes,offset szFile
						.if eax!=INVALID_HANDLE_VALUE
							invoke DeleteFile,offset szFile
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETCURSEL,0,0
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_DELETESTRING,eax,0
							invoke SetDlgItemText,hWin,IDC_EDTFILE,addr szNULL
						.endif
					.endif
				.endif
			.endif
		.elseif edx==LBN_SELCHANGE
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETCURSEL,0,0
			mov		edx,eax
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,edx,addr buffer
			invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
		.elseif edx==LBN_DBLCLK
			invoke SendMessage,hWin,WM_COMMAND,IDOK,0
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,lParam
		invoke SetFocus,hWnd
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TripLogProc endp

OpenTrip proc uses ebx esi edi,lpFileName:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	hMem:HGLOBAL
	LOCAL	dwread:DWORD

	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		push	eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,addr [eax+1]
		mov		hMem,eax
		pop		edx
		invoke ReadFile,hFile,hMem,edx,addr dwread,NULL
		mov		mapdata.triphead,0
		mov		esi,hMem
		xor		ebx,ebx
		.while byte ptr [esi] && ebx<MAXTRIP
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.trip.iLon[edx],eax
			mov		mapdata.trip.iLon[edx+sizeof LOG],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.trip.iLat[edx],eax
			mov		mapdata.trip.iLat[edx+sizeof LOG],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.trip.iBear[edx],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=0Dh
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=0Dh
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.trip.iTime[edx],eax
			.if byte ptr [esi]==0Dh
				inc		esi
			.endif
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
			inc		ebx
		.endw
		mov		mapdata.triphead,ebx
		invoke CloseHandle,hFile
		invoke GlobalFree,hMem
		mov		eax,mapdata.triphead
		dec		eax
		invoke GetDistance,addr mapdata.trip,eax
	.endif
	ret

OpenTrip endp

SaveTrip proc uses ebx,lpFileName:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	dwwrite:DWORD

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		xor		ebx,ebx
		.while ebx<mapdata.triphead
			mov		buffer,0
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.trip.iLon[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.trip.iLat[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.trip.iBear[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.trip.iTime[edx]
			invoke strcat,addr buffer,addr szCRLF
			invoke strlen,addr buffer[1]
			mov		edx,eax
			invoke WriteFile,hFile,addr buffer[1],edx,addr dwwrite,NULL
			inc		ebx
		.endw
		invoke CloseHandle,hFile
	.endif
	ret

SaveTrip endp

OpenDistance proc uses ebx esi edi,lpFileName:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	hMem:HGLOBAL
	LOCAL	dwread:DWORD

	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		push	eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,addr [eax+1]
		mov		hMem,eax
		pop		edx
		invoke ReadFile,hFile,hMem,edx,addr dwread,NULL
		mov		mapdata.disthead,0
		mov		esi,hMem
		xor		ebx,ebx
		.while byte ptr [esi] && ebx<MAXDIST
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.dist.iLon[edx],eax
			mov		mapdata.dist.iLon[edx+sizeof LOG],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.dist.iLat[edx],eax
			mov		mapdata.dist.iLat[edx+sizeof LOG],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.dist.iBear[edx],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=0Dh
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=0Dh
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.dist.iTime[edx],eax
			.if byte ptr [esi]==0Dh
				inc		esi
			.endif
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
			inc		ebx
		.endw
		mov		mapdata.disthead,ebx
		invoke CloseHandle,hFile
		invoke GlobalFree,hMem
		mov		eax,mapdata.disthead
		dec		eax
		invoke GetDistance,addr mapdata.dist,eax
	.endif
	ret

OpenDistance endp

SaveDistance proc uses ebx,lpFileName:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	dwwrite:DWORD

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		xor		ebx,ebx
		.while ebx<mapdata.disthead
			mov		buffer,0
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.dist.iLon[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.dist.iLat[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.dist.iBear[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.dist.iTime[edx]
			invoke strcat,addr buffer,addr szCRLF
			invoke strlen,addr buffer[1]
			mov		edx,eax
			invoke WriteFile,hFile,addr buffer[1],edx,addr dwwrite,NULL
			inc		ebx
		.endw
		invoke CloseHandle,hFile
	.endif
	ret

SaveDistance endp

OpenTrail proc uses ebx esi edi,lpFileName:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	hMem:HGLOBAL
	LOCAL	dwread:DWORD

	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		push	eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,addr [eax+1]
		mov		hMem,eax
		pop		edx
		invoke ReadFile,hFile,hMem,edx,addr dwread,NULL
		mov		mapdata.trailhead,0
		mov		mapdata.trailtail,0
		mov		esi,hMem
		xor		ebx,ebx
		.while byte ptr [esi]
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.trail.iLon[edx],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.trail.iLat[edx],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=','
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.trail.iBear[edx],eax
			lea		edi,buffer
			.while byte ptr [esi] && byte ptr [esi]!=0Dh
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.break .if byte ptr [esi]!=0Dh
			inc		esi
			inc		esi
			mov		byte ptr [edi],0
			invoke DecToBin,addr buffer
			mov		edx,ebx
			shl		edx,4
			mov		mapdata.trail.iTime[edx],eax
			inc		ebx
			and		ebx,MAXTRAIL-1
			mov		mapdata.trailhead,ebx
			.if ebx==mapdata.trailtail
				inc		mapdata.trailtail
				and		mapdata.trailtail,MAXTRAIL-1
			.endif
			.if byte ptr [esi]==0Dh
				inc		esi
			.endif
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
		.endw
		invoke CloseHandle,hFile
		invoke GlobalFree,hMem
		invoke CheckDlgButton,hWnd,IDC_CHKSHOWTRAIL,BST_CHECKED
		mov		mapdata.gpstrail,TRUE
	.endif
	ret

OpenTrail endp

ClearTrail proc
	
	mov		mapdata.ntrail,0
	mov		mapdata.trailhead,0
	mov		mapdata.trailtail,0
	inc		mapdata.paintnow
	fldz
	fstp	mapdata.fSumDist
	invoke SetDlgItemText,hControls,IDC_STCDIST,addr szNULL
	invoke wsprintf,addr mapdata.options.text[sizeof OPTIONS*5],addr szFmtDist,0
	ret

ClearTrail endp

SaveTrail proc uses ebx,lpFileName:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	dwwrite:DWORD

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		mov		ebx,mapdata.trailtail
		.while ebx!=mapdata.trailhead
			mov		buffer,0
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.trail.iLon[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.trail.iLat[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.trail.iBear[edx]
			mov		edx,ebx
			shl		edx,4
			invoke PutItemInt,addr buffer,mapdata.trail.iTime[edx]
			invoke strcat,addr buffer,addr szCRLF
			invoke strlen,addr buffer[1]
			mov		edx,eax
			invoke WriteFile,hFile,addr buffer[1],edx,addr dwwrite,NULL
			inc		ebx
		.endw
		invoke CloseHandle,hFile
	.endif
	ret

SaveTrail endp

SaveNMEALog proc uses ebx,lpFileName:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	dwwrite:DWORD
	LOCAL	buffer[256]:BYTE

	push	mapdata.gpslogpause
	mov		mapdata.gpslogpause,TRUE
	invoke Sleep,100
	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		xor		ebx,ebx
		.while TRUE
			invoke SendDlgItemMessage,hWnd,IDC_LSTNMEA,LB_GETTEXT,ebx,addr buffer
		  .break .if eax==LB_ERR
			invoke strcat,addr buffer,addr szCRLF
			invoke strcmpn,addr buffer,addr szGPRMC,6
			.if !eax
				invoke WriteFile,hFile,addr szNULL,1,addr dwwrite,NULL
			.else
			.endif
			invoke strlen,addr buffer
			mov		edx,eax
			invoke WriteFile,hFile,addr buffer,edx,addr dwwrite,NULL
			inc		ebx
		.endw
		invoke CloseHandle,hFile
	.endif
	pop		mapdata.gpslogpause
	ret

SaveNMEALog endp
