; Scipt to capture Active Window when a major event occurs
; Bsexton4(at)gmail(dot)com
; Script will take a screen capture when user events occur
; Will capture screen when user presses hot key (Control-Alt-C)
; Can pause with (Control-Alt-P)
; 4/19/2008

; system include files
#include <ScreenCapture.au3>
#include <GuiMenu.au3>
#include <Constants.au3>
#include <Misc.au3>
; user defined include files
#include <Config.au3>
#include <CreateHtml.au3>
#include <MouseHook.au3>
#include <CreateWordDoc.au3>
#include <Gui.au3>

$sleepTime = 500                  				; how long to sleep between checks for event changes
$numOfEventChanges = 0            				; counter used to say how many event changes have occured. Will be used when creating screen captures
$currentActiveWindow = WinGetTitle("")          ; variable to hold active screen title
$screenLog = "capture"            				; file name of captured screen File
$logFile = "Log.doc"             			    ; name of file to hold logging. Defualt will be reset if config file exists
$htmlFile = "Log.html"           				; name of file to hold HTML. Defualt will be reset if config file exists
$textInWindow = ""                				; text inside a window, will compare against this to determing what the user has entered
$logCaptureMouse = True           				; var to decide if mouse should be capture when doing screen shots
$screenChanged = False
$logToWord = True
$logToHtml = True
$captureIsPaused=False
$hGUI = GUICreate("", @DesktopWidth+50, @DesktopHeight+50, -15, -15, -1, 0x00000080)   ; transparent gui used to hide mouse cursor
$list = ProcessList()           ; List all processes

; VISTA: This script requires full Administrative rights
; #requireadmin

; initialize hooks 
HookInit()

; check to see if application is already running, if it is do not start a second occurance
if _Singleton("ScreenshotAndAnnotate",1) = 0 Then
    Msgbox(0,"Warning","An occurence of ScreenshotAndAnnotate is already running")
	OnAutoItExit()
	Exit
	; MyExit()
EndIf

; creates hotkey that will make program exit
; hot key is (ctl-Alt-x)
HotKeySet("^!x", "MyExit")

; creates hotkey that will get the current window
; even if it has not changed
; hot key is (ctl-Alt-c)
HotKeySet("^!c", "UserInitCapture")

; toggle whether or not mouse is being capture
HotKeySet("^!m","SetMouseIncapture")

; allow user to Pause captured events
HotKeySet("^!p","TogglePause")

; create custom menus on taskbar
; CreateCustomMenus()

; determine what the configuration should be
ConfigFromGuiOrFile()

; create html file
; function must be called after config as it uses the log file name
If $logToHtml Then
	HtmlInit($htmlFile)
EndIf

; create word document
If $logToWord Then
	WordInit($logFile)
EndIf

; main loop and look for current active window
while(True)
	If not $captureIsPaused Then
		CheckForEventChange()
	EndIf
	Sleep($sleepTime)
WEnd

Func GetConfig()
	If logToWordConfig()=="Log To Word: Yes" Then
		If _WordGetVersion() Then ; verify a version is returned else no word on computer
			$logToWord=True
		Else
			$logToWord=False
		EndIf
	Else
		$logToWord=False
	EndIf
	
	If logToHtmlConfig()=="Log To Word: HTML" Then 
		$logToHtml=True
	Else
		$logToHtml=False
	EndIf
	
	if logCaptureMouse()=="Turn off Mouse during Capture: Yes" Then
		$logCaptureMouse=True
	Else
		$logCaptureMouse=False
	EndIf
	
	$logFile=logToWordFileName()
	$htmlFile=logToHtmlFileName()
EndFunc

; get variables from Gui Config
; prerequisite is the GUI should have been run before
; this is called or else defaults will be taken
Func GetConfigFromGui()
	If GuiLogToWordConfig() Then
		If _WordGetVersion() Then ; verify a version is returned else no word on computer
			$logToWord=True
		Else
			$logToWord=False
		EndIf
	Else
		$logToWord=False
	EndIf
	
	If GuiLogToHtmlConfig() Then 
		$logToHtml=True
	Else
		$logToHtml=False
	EndIf
	
	if GuiLogCaptureMouse() Then
		$logCaptureMouse=True
	Else
		$logCaptureMouse=False
	EndIf
	
	$logFile=GuiLogToWordFileName()
	$htmlFile=GuiLogToHtmlFileName()
	
EndFunc

; takes screenshot of active screen
func CaptureScreen()
	If $logCaptureMouse Then
		HideCursor()
		Sleep(10)      ; slight pause to give the mouse time to go away
	EndIf
	_ScreenCapture_CaptureWnd($screenLog&$numOfEventChanges&".jpg",WinGetHandle($currentActiveWindow)) ; create unigue file with iterated name
	
	If $logToHtml Then
		PicToHtml($htmlFile, $screenLog&$numOfEventChanges&".jpg") 
	EndIf
	
	If $logToWord Then
		PicToHtml($htmlFile, $screenLog&$numOfEventChanges&".jpg") 
		PicToWord($logFile, $screenLog&$numOfEventChanges&".jpg")
	EndIf
	
	If $logCaptureMouse Then
		UnhideCursor()
	EndIf
EndFunc

Func UserInitCapture()
	If $logToWord Then
		LogToFile("User initiated screen capture")
		LogToFile("Active Screen is " & $currentActiveWindow)
	EndIf
		
	If $logToHtml Then
		LogToHtml($htmlFile,"User initiated screen capture")
	EndIf
		
	$numOfEventChanges=$numOfEventChanges+1 ; not sure if this should be counted as event change
	CaptureScreen()
EndFunc

; gets the currently active screen
func GetActiveScreen()
	$currentActiveWindow=WinGetTitle("")
	return $currentActiveWindow
EndFunc

; check if events have changed 
; used as agregate for different checks
func CheckForEventChange()
	; TestForScreenChange() ; this is turned off by user request right now
	; TestForUserEnteredText()
	TestForSubMenu()
	TestForChangedProcesses()	
	TestForRightClick()
EndFunc

; log to file
Func LogToFile($logText)
	If $logToWord Then
		LogToWord($logFile,$logText)
	EndIF
	If $logToHtml Then
		LogToHtml($htmlFile,$logText)
	EndIf
EndFunc

; Function exits program
Func MyExit()
	MsgBox(0,"Screenshot & Annotations", "Screenshot & Annotations exiting");
	LogToFile("Screenshot & Annotations exited")
    Exit 
EndFunc 

; test to see if current window is different from previous window
Func TestForScreenChange()
	; using 1 = so change must be significant == requires exact match (this is unique functionality to autoit)
	if $currentActiveWindow=GetActiveScreen() Then
		$screenChanged=False
    Else
		LogToFile("Active Screen is " & $currentActiveWindow)
		$numOfEventChanges=$numOfEventChanges+1
		CaptureScreen() ; take capture of current active screen 
		$screenChanged=True
	EndIf
EndFunc

; check to see if list of running processes are different
Func TestForChangedProcesses()
	$currentProcesses = ProcessList ()

	For $X = 1 to $currentProcesses[0][0] ; loop through all current processes
		$found = false

		For $Y = 1 to $list[0][0] ; compare processes in previous list of processes
			If $list[$Y][1] = $currentProcesses[$X][1] Then
			$found = true
			ExitLoop
			EndIf
		Next

		If $found = false Then
			LogToFile("Application started: " & $currentProcesses[$X][0])
			$numOfEventChanges=$numOfEventChanges+1
			CaptureScreen()          ; take capture of current active screen 
			$screenChanged=True
			$list=$currentProcesses  ; because processes changed set new list to be the one to test against
		EndIf
	Next
EndFunc

; check to see if user right clicked
Func TestForRightClick()
	If UserRightClicked() Then
		LogToFile("Right Click on " & GetActiveScreen())
		$numOfEventChanges=$numOfEventChanges+1  ; increase number of events and add new number for log file
		CaptureScreen()                          ; take capture of current active screen 
		$screenChanged=True
		SetUserClicked(False)
	EndIf
EndFunc

; check to see if text on current screen is different
; will log if screen changes
Func TestForUserEnteredText()
		if $screenChanged=False Then        ; test if we are on a diffrent screen and log if that is the case 
			Return False
		Else
			$textInWindow=WinGetText (WinGetTitle(""))
			LogToFile("Text on screen is " & $textInWindow)
		EndIf
	; EndIf
EndFunc

; check if submenu is selected
Func TestForSubMenu()
	If CheckForSubMenu() Then
		LogToFile("SubMenu selected " & GetActiveScreen())
		$numOfEventChanges=$numOfEventChanges+1
		CaptureScreen() ; take capture of current active screen 
		$screenChanged=True
	EndIf
EndFunc

; hide mouse cursor 
; works by creating transparent screen
Func HideCursor()
	$hGUI = GUICreate("", @DesktopWidth+50, @DesktopHeight+50, -15, -15, -1, 0x00000080)                           ; transparent gui used to hide mouse cursor
    WinSetTrans($hGUI, "", 1)
    WinSetOnTop($hGUI, "", 1)
    GUISetCursor(16)
    GUISetState(@SW_SHOW, $hGUI)
EndFunc

; makes cursor viewable again by delecting transparent screen
Func UnhideCursor()
	GUIDelete($hGUI)
EndFunc

; Func will toggle whether or not mouse will be in capture
; called by a hot key
Func SetMouseIncapture()
	If $logCaptureMouse Then
		$logCaptureMouse=False
	Else
		$logCaptureMouse=True
	EndIf	

	MsgBox(0,"Screenshot & Annotations", "Mouse in screen capture set to " & $logCaptureMouse)
EndFunc

; check to see if a menu item is selected
; is called by testfor sub menu which handle logging
Func CheckForSubMenu()
	; Retrieves the handle of the menu assigned to the given window
	$hMain = _GUICtrlMenu_GetMenu (WinGetHandle(WinGetTitle("")))
	 
	For $i = 0 To _GUICtrlMenu_GetItemCount($hMain)
        $subMenu = _GUICtrlMenu_GetItemSubMenu($hMain, $i)
        For $x = 0 To _GUICtrlMenu_GetItemCount($subMenu)
            If BitAND(_GUICtrlMenu_GetItemState($subMenu, $x), 16) Then
				$menu=_GUICtrlMenu_GetItemText($subMenu, $x)
				LogToFile("Menu name is " & StringRegExpReplace($Menu, "[&]", " ", 0) & " item number " & $x)
				Return True
            EndIf
        Next
    Next
EndFunc

Func ConfigFromGuiOrFile()
	If $CmdLine[0] > 0 Then  ; test to see if at least 1 command line option
		If $CmdLine[1]="File" Then ; look for the word "File"
			GetConfig()
		Else                       ; here we have a command line switch but don't recognize it
			MsgBox(0,"","Unknown command line switch "& $CmdLine[1])
			GetConfig() ; get config from file all the same
		EndIf	
	Else    ; no command line switch so start up GUI
		GuiInit()
		GetConfigFromGui() 
	EndIf
EndFunc

Func TogglePause()
	If not $captureIsPaused Then
		$captureIsPaused=True
		MsgBox(0,"Screenshot And Annotate","Screenshot And Annotate Paused")
	Else
		$captureIsPaused=False
		MsgBox(0,"Screenshot And Annotate","Screenshot And Annotate Unpaused")
	EndIf
	
EndFunc

Func CreateCustomMenus()
	Opt("TrayMenuMode",1)	; Default tray menu items (Script Paused/Exit) will not be shown.

	$pauseitem	= TrayCreateItem("Pause")
	TrayCreateItem("")
	$StopWordLogItem= TrayCreateItem("Toggle Word Logging")
	TrayCreateItem("")
	$StopHtmlLogItem= TrayCreateItem("Toggle HTML Logging")
	TrayCreateItem("")
	$StopMouseCaptureitem= TrayCreateItem("Toggle Mouse Capture")
	TrayCreateItem("")
	$aboutItem	= TrayCreateItem("About")
	TrayCreateItem("")
	$exitItem	= TrayCreateItem("Exit")

	TraySetState()

	While 1
		$msg = TrayGetMsg()
		Select
			;Case $msg = 0
			;	ContinueLoop
			Case $msg = $pauseItem
				Msgbox(64, "Preferences:", "OS:" & @OSVersion)
			Case $msg = $StopWordLogItem
				Msgbox(64,"","Stop Word")
		;	Case $msg = $StopHtmlLogItem
		;		Msgbox(64,"","Stop HTML")
		;	Case $msg = $StopMouseCaptureItem
		;		MsgBox(64,"","Mouse Capture")
		;	Case $msg = $aboutItem
		;		Msgbox(64, "About:", "Screen Shots and Annotations")
			Case $msg = $exitItem
				ExitLoop
	EndSelect
	WEnd
	Exit
EndFunc