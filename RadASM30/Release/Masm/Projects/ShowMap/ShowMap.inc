include windows.inc
include user32.inc
include kernel32.inc
include comdlg32.inc
include comctl32.inc
include gdi32.inc
include gdiplus.inc
include gdiplus_structs.inc
include ole32.inc
include oleaut32.inc

includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib
includelib comctl32.lib
includelib gdi32.lib
includelib gdiplus.lib
includelib ole32.lib 
includelib oleaut32.lib 
includelib STLinkLib.lib 

;#########################################################################
;VKim's Debug

include masm32.inc
include \RadASM30\masm\inc\debug.inc
includelib masm32.lib
includelib \RadASM30\masm\lib\debug.lib

;#########################################################################

STLinkConnect			PROTO hWin:HWND
STLinkDisconnect		PROTO
STLinkReset				PROTO hWin:HWND
STLinkRead 				PROTO hWin:HWND,rdadr:DWORD,wradr:DWORD,nBytes:DWORD
STLinkWrite				PROTO hWin:HWND,wradr:DWORD,rdadr:DWORD,nBytes:DWORD
FpToAscii				PROTO :PTR TBYTE,:PTR CHAR,:DWORD
InitScroll				PROTO

;#########################################################################

IDD_DIALOG              equ 1000
IDC_MAP                 equ 1001
IDC_BTNZOOMIN           equ 1002
IDC_BTNZOOMOUT          equ 1003
IDC_CHKPAUSE			equ 1013
IDC_CHKLOCK				equ 1007
IDC_CHKTRAIL			equ 1008
IDC_CHKGRID				equ 1014
IDC_CBOGOTO             equ 1004
IDC_EDTNORTH            equ 1005
IDC_EDTEAST             equ 1006
IDC_EDTDIST				equ 1009
IDC_STCLAT              equ 1010
IDC_STCLON              equ 1011
IDC_STCDIST             equ 1012
IDC_STCBEAR				equ 1016
IDC_EDTBEAR				equ 1015

IDD_DLGADDPLACE         equ 1100
IDC_EDTNAME             equ 1101
IDC_EDTLONGITUDE        equ 1102
IDC_EDTLATTITUDE        equ 1103
IDC_CBOFONT             equ 1104
IDC_CBOICON             equ 1105
IDC_BTNGPS              equ 1106
IDC_TRBZOOM             equ 1107

IDC_STCGAIN				equ 1019
IDC_TRBGAIN				equ 1018
IDC_STCNOISE			equ 1023
IDC_TRBNOISE			equ 1022
IDC_STCPULSES			equ 1021
IDC_TRBPULSES			equ 1020
IDC_STCRANGE			equ 1025
IDC_TRBRANGE			equ 1024
IDC_CHKRANGE			equ 1026
IDC_CHKFISHDETECT		equ 1027

IDM_MENU                equ 10000
IDM_FILE_OPENTRIP       equ 10010
IDM_FILE_SAVETRIP       equ 10011
IDM_FILE_OPENDIST       equ 10014
IDM_FILE_SAVEDIST       equ 10015
IDM_FILE_OPENTRAIL      equ 10012
IDM_FILE_SAVETRAIL      equ 10013
IDM_FILE_EXIT           equ 10001
IDM_OPTION_SPEED        equ 10002
IDM_OPTION_BATTERY      equ 10003
IDM_OPTION_AIRTEMP      equ 10004
IDM_OPTION_SCALE		equ 10009
IDM_OPTION_TIME			equ 10016
IDM_OPTION_RANGE		equ 10020
IDM_OPTIO_DEPTH			equ 10019
IDM_OPTION_WATERTEMP	equ 10021
IDM_OPTION_COMPORT      equ 10008
IDM_LOG_START           equ 10005
IDM_LOG_END             equ 10006
IDM_LOG_REPLAY          equ 10007
IDM_LOG_CLEARTRAIL		equ 10017
IDM_LOG_STARTSONAR		equ 10022
IDM_LOG_ENDSONAR		equ 10023
IDM_LOG_REPLYSONAR		equ 10024

IDM_CONTEXT             equ 11000
IDM_EDITPLACE           equ 11001
IDM_ADDPLACE            equ 11002
IDM_TRIPPLANNING        equ 11003
IDM_DISTANCE            equ 11004
IDM_FULLSCREEN			equ 11017
IDM_TRIP_DONE           equ 11005
IDM_TRIP_SAVE           equ 11006
IDM_TRIP_EDIT           equ 11011
IDM_TRIP_CLEAR          equ 11007
IDM_TRIP_INSERT         equ 11013
IDM_TRIP_DELETE         equ 11014
IDM_DIST_DONE           equ 11008
IDM_DIST_SAVE           equ 11009
IDM_DIST_EDIT           equ 11012
IDM_DIST_CLEAR          equ 11010
IDM_DIST_INSERT         equ 11015
IDM_DIST_DELETE         equ 11016

IDR_ACCEL				equ 1

;Map constants
MAXBMP					equ 512*2							;Max number of bitmaps to cache
MAXPLACES				equ 256								;Max number of places
MAXZOOM					equ 32								;Max number of zoom definitions
MAXFONT					equ 16								;Max number of font definitions
MAXTRIP					equ 1024							;Max number of trip positions
MAXTRAIL				equ 2048							;Max number of trail positions
MAXDIST					equ 256								;Max number of distance calculation poins
MAXMAPOPTION			equ 5								;Max number of overlays on map scteen
MAXSONAROPTION			equ 3								;Max number of overlays on sonar scteen

;Sonar constants
MAXXECHO				equ 512								;Max number of sonar X-echos
MAXYECHO				equ 512								;Max number of sonar Y-echos
MINYECHO				equ 100
MAXRANGE				equ 13								;Number of depth ranges
STM32_Sonar				equ 20000000h						;STM32 ram address
SONARBACKCOLOR			equ 0FFFF80h						;Back color of sonar

LONPOINT struct
	iLon			DWORD ?									;Longitude
	ixpos			DWORD ?									;Map x position
LONPOINT ends

LATPOINT struct
	iLat			DWORD ?									;Lattitude
	iypos			DWORD ?									;Map y position
LATPOINT ends

BMP struct
	inuse			DWORD ?									;The tile is still needed
	mapinx			DWORD ?									;Used in folder name to jpegs
	nx				DWORD ?									;Number x, used in filename
	ny				DWORD ?									;Number y, used in filename
	hBmp			HBITMAP ?								;Bitmap handle
BMP ends

PLACE struct
	font			DWORD ?									;Index of font, 0 (no font) or 1 to 6
	icon			DWORD ?									;Index of icon, 0 (no icon) or 1 to 16
	zoom			DWORD ?									;Minimum zoom level to plot text
	iLon			DWORD ?									;Longitude
	iLat			DWORD ?									;Lattitude
	ptmap			POINT <>								;Map coordinate
	text			BYTE 32 dup(?)							;Name of place
PLACE ends

ZOOM struct
	zoomval			DWORD ?									;Current zoom value
	mapinx			DWORD ?									;Used in folder name to jpegs
	scalem			DWORD ?									;Scale in meters
	scalep			DWORD ?									;Scale bar in pixels
	text			BYTE 16 dup(?)							;Scale bar text
	nx				DWORD ?									;Number of x-jpegs in current zoom
	ny				DWORD ?									;Number of y-jpegs in current zoom
	xPixels			DWORD ?									;Width of map in pixels
	yPixels			DWORD ?									;Height of map in pixels
	xMeters			DWORD ?									;Width of map in meters
	yMeters			DWORD ?									;Height of map in meters
ZOOM ends

OPTIONS struct
	show			DWORD ?									;Show on map screen
	position		DWORD ?									;Position on map screen
	pt				POINT <>								;Offset from left/right and top/bottom
	font			DWORD ?									;Index of font (1 to 6)
	text			BYTE 16 dup(?)							;Text to plot on map screen
OPTIONS ends

COM struct
	active			DWORD ?									;Communication with GPS is active if TRUE
	szcom			BYTE 16 dup(?)							;Com port (COM1, COM2 ...)
	nbaud			DWORD ?									;Baudrate (4800 to 38400)
	nbits			DWORD ?									;Data bits (7 or 8)
	nparity			DWORD ?									;Parity bit (False/True)
	nstop			DWORD ?									;Stop bits (0 or 1)
COM ends

LOG struct
	iLon			DWORD ?									;Longitude
	iLat			DWORD ?									;Lattitude
	iBear			DWORD ?									;Bearing
	iTime			DWORD ?									;Dos time
LOG ends

MAP struct
	zoomval			DWORD ?									;Current zoom value
	mapinx			DWORD ?									;Used in folder name to map jpegs
	topx			DWORD ?									;Upper left, unzoomed
	topy			DWORD ?									;Upper top, unzoomed
	mapwt			DWORD ?									;Current width of map screen
	mapht			DWORD ?									;Current height of map screen
	ncursor			DWORD ?									;The index of the bearing cursor (0 to 7)
	fcursor			DWORD ?									;If TRUE cursor is visible (used to make the cursor blink)
	cursorx			DWORD ?									;Cursor x position
	cursory			DWORD ?									;Cursor y position
	paintnow		DWORD ?									;Force a repaint counter

	zoominx			DWORD ?									;Current index of the ZOOM array
	zoommax			DWORD ?									;Index to first free ZOOM
	hDC				HDC ?									;Map window DC
	mDC				HDC ?									;Memory DC
	mDC2			HDC ?									;Memory DC
	tDC				HDC ?									;Used to draw a single tile onto mDC
	hmBmpOld		HBITMAP ?								;Original  bitmap in mDC
	hmBmpOld2		HBITMAP ?								;Original  bitmap in mDC2
	cxs				DWORD ?									;Screen x-size
	cys				DWORD ?									;Screen y-size
	nx				DWORD ?									;Number of x-jpegs in current zoom
	ny				DWORD ?									;Number of y-jpegs in current zoom
	xPixels			DWORD ?									;Width of map in pixels
	yPixels			DWORD ?									;Height of map in pixels
	xMeters			DWORD ?									;Width of map in meters
	yMeters			DWORD ?									;Height of map in meters
	iLon			DWORD ?									;Longitude
	iLat			DWORD ?									;Lattitude
	gpslogpause		DWORD ?									;TRUE if 'Pause Log' is checked
	gpslock			DWORD ?									;TRUE if 'Lock to GPS' is checked
	gpstrail		DWORD ?									;TRUE if 'Show Trail' is checked
	mapgrid			DWORD ?									;TRUE if 'Show Grid' is checked
	place			PLACE MAXPLACES dup(<>)					;Places definitions
	freeplace		DWORD ?									;Index to first emty place
	zoom			ZOOM MAXZOOM dup(<>)					;Zoom definitions
	font			HFONT MAXFONT dup(?)					;Font handles
	options			OPTIONS MAXMAPOPTION dup(<>)			;Options for overlays on map screen
	comopt			COM <>									;Comport
	btrip			DWORD ?									;Trip planning flag, 0 not active, 1 active, 2 done, 3 edit
	triphead		DWORD ?									;Head index in trip array
	trip			LOG MAXTRIP dup(<>)						;Trip array
	trailhead		DWORD ?									;Head index in trail array
	trailtail		DWORD ?									;Tail index in trail array
	trail			LOG MAXTRAIL dup(<>)					;Trail array
	bdist			DWORD ?									;Distance measure flag, 0 not active, 1 active, 2 done, 3 edit
	disthead		DWORD ?									;Head index in distance array
	dist			LOG MAXDIST dup(<>)						;Distance array
	iBear			DWORD ?									;Bearing
	iTime			DWORD ?									;Dos time
	onpoint			DWORD ?									;Point index, -1 if not on point
	fSumDist		REAL10 ?								;The sum of a distance calculation
	nLonPoint		DWORD ?									;Number of longitude entries in array
	hMemLon			HGLOBAL ?								;Longitude array
	nLatPoint		DWORD ?									;Number of lattitude entries in array
	hMemLat			HGLOBAL ?								;Lattitude array
MAP ends

SONAR struct
	mDC				HDC ?
	hBmp			HBITMAP ?
	hBmpOld			HBITMAP ?
	wt				DWORD ?									;Width of sonar screen
	options			OPTIONS MAXSONAROPTION dup(<>)			;Options for overlays on sonar screen
	Range			DWORD ?									;Range (0 to 12)
	AutoRange		DWORD ?									;If TRUE autorange is on
	FishDetect		DWORD ?									;If TRUE fish detect is on
	minyecho		DWORD ?
	Noise			DWORD ?									;Noise reject level (0 to 255)
	Start			BYTE ?
	PingPulses		BYTE ?									;Number of pulses in a ping ((0 to 255)+1)
	Gain			WORD ?									;Gain level (0 to 31)
	Timer			WORD ?									;Time between each echo reading
	Skip			WORD ?									;Number of echo readings to skip
;	EchoIndex		WORD ?
	ADCBattery		WORD ?									;Battery level
	ADCWaterTemp	WORD ?									;Water temprature
	ADCAirTemp		WORD ?									;Air temprature
	sonarrange		BYTE MAXXECHO dup(?)					;Range array
	sonar			BYTE MAXXECHO*MAXYECHO dup(?)			;Echo array
	hReply			HANDLE ?								;Handle of replay file
	hLog			HANDLE ?								;Handle of log file
SONAR ends

RANGE struct
	range		DWORD ?
	interval	DWORD ?
	skip		DWORD ?
RANGE ends

.const

dd256				DWORD 256
dd512				DWORD 512
dd72				DWORD 72

ClassName			BYTE 'DLGCLASS',0						;Window class for main window
szMapClassName		BYTE 'MAPCLASS',0						;Window class for map window
szSonarClassName	BYTE 'SONARCLASS',0						;Window class for sonar window
szAppName			BYTE 'Navigation',0						;Application name

szAskSaveTrail		BYTE 'Save current trail?',0			;Messagebox string
szAskOverwrite		BYTE 'Overwrite existing file?',0Dh,0Ah,0

szFileName			BYTE '%s\Map\X%d\Land%02X%02X.jpg',0	;Format string to get map tile path & filename

szNULL				BYTE 0
szBS				BYTE '\',0
szCRLF				BYTE 0Dh,0Ah,0

szIniFile			BYTE 'ShowMap.ini',0					;File name of ini file

szIniPlace			BYTE 'Place',0							;Ini file app / key
szIniMap			BYTE 'Map',0
szIniZoom			BYTE 'Zoom',0
szIniPos			BYTE 'Pos',0
szIniFont			BYTE 'Font',0
szIniOption			BYTE 'Option',0
szIniLon			BYTE 'Lon',0
szIniLat			BYTE 'Lat',0

szFonts				BYTE 'None',0							;Font selection descriptions
					BYTE 'Small',0
					BYTE 'Small, Bold',0
					BYTE 'Medium',0
					BYTE 'Medium, Bold',0
					BYTE 'Large',0
					BYTE 'Large, Bold',0,0

szIcons				BYTE 'None',0							;Icon selection descriptions
					BYTE 'Waypoint, start',0
					BYTE 'Waypoint, middle',0
					BYTE 'Waypoint, end',0
					BYTE 'Cross',0
					BYTE 'City',0
					BYTE 'Building, small',0
					BYTE 'Building, large',0
					BYTE 'Light house',0
					BYTE 'Shallow',0
					BYTE 'Fish, small',0
					BYTE 'Fish, large',0
					BYTE 'Filled square',0
					BYTE 'Yellow dot',0
					BYTE 'Green dot',0
					BYTE 'Red dot',0
					BYTE 'Blue dot',0,0

sonarrange			RANGE <4,200,10>,<6,200,10>,
						  <10,250,10>,<20,250,10>,
						  <30,300,10>,<50,300,10>,
						  <70,350,10>,<100,350,10>,
						  <150,400,10>,<200,400,10>,
						  <250,450,10>,<300,450,10>,
						  <350,500,10>

szFmtDec			BYTE '%u',0
szFmtDepth			BYTE '%02u',0

.data?

hInstance			HINSTANCE ?								;Instance handle
CommandLine			DWORD ?									;Pointer to command line
gdiplSTI			GdiplusStartupInput <>					;Gdi+ structure
token				DWORD ?									;Gdi+ token
hWnd				HWND ?									;Handle of main window
hMap				HWND ?									;Handle of map screen
hSonar				HWND ?									;Handle of sonar screen
hMenu				HMENU ?									;Hamdle of menu
hContext			HMENU ?									;Hamdle of context menu
hAccel				HACCEL ?								;Handle of accelerator table
hIml				HIMAGELIST ?							;Imagelist handle
szAppPath			BYTE MAX_PATH dup(?)					;Application path
map					MAP <>									;Map data
mousept				POINT <>								;Point where lbutton clicked
bmpcache			BMP MAXBMP dup(<>)						;Cached bitmaps
hMapThread			HANDLE ?								;Map drawing thread
fExitMapThread		DWORD ?									;Flag to exit the map drawing thread
hGpsThread			HANDLE ?								;Thread to comunicate with GPS
fExitGpsThread		DWORD ?									;Flag to exit the GpsThread
szIniFileName		BYTE MAX_PATH dup(?)					;Path and filename of ini file
szbuff				BYTE 512 dup(?)							;Temporary buffer
tid					DWORD ?									;Thread ID
fSTLink				DWORD ?									;If TRUE STLink connected
fThread				DWORD ?									;If TRUE sonar thread is running
sonardata			SONAR <>								;Sonar data
hSplittV			HCURSOR ?								;Horizontal splitt cursor