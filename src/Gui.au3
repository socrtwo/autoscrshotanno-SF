#include <GUIConstants.au3>
#include <file.au3>
#include <array.au3>

$logToWord=False
$logToHtml=False
$logCaptureMouse=False
$logFileInGui=""
$htmlFileInGui=""
$logFileSet=False
$htmlFileSet=False
$wordFileGui=""
$htmlFileGui=""

Func GuiInit()
	GUICreate("Screenshot and Annotations") ; will create a dialog box that when displayed is centered

	$logToWordGui = GUICtrlCreateCheckbox ("Log to Word", 10, 10, 120, 20)
	$logToHTMLGui = GUICtrlCreateCheckbox ("Log to HTML", 10, 30, 120, 20)
	$CaptureMouseGui = GUICtrlCreateCheckbox ("Mouse in Capture", 10, 50, 120, 20)

	; label and input for Word file
	GUICtrlCreateLabel ("Word File Location",  10, 70)
	$wordLocationGui = GUICtrlCreateButton("Word file", 10, 90, 150)
	$wordFileGui = GUICtrlCreateInput ($logFileInGui, 10,  120, 300, 20)

	; label and input for HTML file
	GUICtrlCreateLabel ("HTML File Location",  10, 140)
	$htmlLocationGui = GUICtrlCreateButton("HTML file", 10, 155, 150)
	$htmlFileGui = GUICtrlCreateInput ($htmlFileInGui, 10,  180, 300, 20)

	; box to initiate start of application
	$startApplicationGui     = GUICtrlCreateButton("Start Application", 10, 200, 150)
	GUICtrlSetState(-1, $GUI_FOCUS) ; the focus is on this button

	; General information
	GUICtrlCreateLabel ("Screenshot and Annotation will look for changed events performed by the user ",  10, 225)
	GUICtrlCreateLabel ("and create a log file with events and screenshots. ",  10, 240)
	
	$viewReadme = GUICtrlCreateButton("View Readme", 10, 260, 150)

	GUISetState () ; creates GUI
	; Run the GUI until the dialog is closed
	Do
		$msg = GUIGetMsg()
		if $msg = $wordLocationGui Then
			GetWordFile()
		EndIf
		If $msg = $htmlLocationGui Then
			GetHtmlFile()
		EndIf
		If $msg = $viewReadme Then
			Run("notepad Readme.txt")
		EndIf
		If $msg = $startApplicationGui Then ; if user starts application attempt to exit the loop
			$validLogFile=True ; will check to see if it realy is true
			
			; will check to see if there is a valid extension for word log
			$logFileInGui=GUICtrlRead($wordFileGui) ; read name of word file			
			If StringCompare("",$logFileInGui) Then ; if the text is not blank
				If Not ValidWordLog($logFileInGui) Then
					MsgBox(0,"","Please add .doc or .docx for Word File extension and complete path name")
					$validLogFile=False
				EndIf
			EndIf
			
			; will check to see if there is a valid extension for html log
			$htmlFileInGui=GUICtrlRead($htmlFileGui) ; read name of html file
			If StringCompare("",$htmlFileInGui) Then ; if the text is not blank
				If  Not ValidHtmlLog($htmlFileInGui) Then ; see if word file or html file have proper extensions
					MsgBox(0,"","Please add .htm or .html for Html File extension and complete path name")
					$validLogFile=False
				EndIf					
			EndIf
			
			; check to see if user has entered any text for logs
			If GUICtrlRead($wordFileGui) == "" And GUICtrlRead($htmlFileGui) == ""  Then 
				If $logFileSet==False And $htmlFileSet==False Then
					MsgBox(0,"","Must Select either Word or HTML log")
					$validLogFile=False
				EndIf
			EndIf
		
			; if nothing made log file false exit the loop and start application
			If $validLogFile==True Then
				ExitLoop
			EndIf
		EndIf
	Until $msg = $GUI_EVENT_CLOSE

	$logToWordState  = GUICtrlRead($logToWordGui) ; return the state of the menu item
	$logToHTMLState = GUICtrlRead($logToHtmlGui)
    $CaptureMouseState = GUICtrlRead($CaptureMouseGui)
 
    ; check the state of the control 
	; if set to 4 is not checked
	If $logToWordState==4 Then
		$logToWord=False
	EndIf
 
    ; if set to 1 it has been checked
	If $logToWordState==1 Then
		$logToWord=True
	EndIf
 
	If $logToHTMLState==4 Then
		$logToHtml=False
	EndIf

	If $logToHTMLState==1 Then
		$logToHtml=True
	EndIf

	If $CaptureMouseState==4 Then
		$logCaptureMouse=False
	EndIf

	If $CaptureMouseState==1 Then
		$logCaptureMouse=True
	EndIf
 

    ; get information from text boxes
	; don't get from text boxes if chosen by selection
	If Not $logFileSet Then
		$logFileInGui=GUICtrlRead($wordFileGui)
		if $logFileInGui=="" Then
			$logFileSet=False
		Else
			$logFileSet=True
			$logToWord=True
		EndIf
	EndIf
	
	If Not $htmlFileSet Then
		$htmlFileInGui=GUICtrlRead($htmlFileGui)
		if $htmlFileInGui=="" Then
			$htmlFileSet=False
		Else
			$logToHtml=True
			$htmlFileSet=True
		EndIf
	EndIf


    GUIDelete("Screenshot and Annotations") ; make the GUI go away

EndFunc

; Return whether or not to log to word
Func GuiLogToWordConfig()
	Return $logToWord
EndFunc

; Return whether or not to log to HTML
Func GuiLogToHtmlConfig()
	Return $logToHtml
EndFunc

; File name for word file
Func GuiLogToWordFileName()
	Return $logFileInGui
EndFunc

; File 
Func GuiLogToHtmlFileName()
	; MsgBox(0, "" , "$htmlFileInGui" & $htmlFileInGui & " $htmlFileGui " & $htmlFileGui)
	Return $htmlFileInGui
EndFunc

; Whether or not to capture mouse
Func GuiLogCaptureMouse()
	Return $logCaptureMouse
EndFunc

Func GetWordFile()
	$message = "Select Word File"

	$logFileInGui = FileOpenDialog($message, @ScriptDir & "\", "Word File (*.doc;*.docx)", 8 )

	If @error Then
		MsgBox(4096,"","No File(s) chosen")
	Else
		; Dim $szDrive, $szDir, $szFName, $szExt
        ; _PathSplit($logFileInGui, $szDrive, $szDir, $szFName, $szExt) ; suck out just the log name
        ; $logFileInGui=$szFName&$szExt
		; $logFileInGui = StringReplace($logFileInGui, "|", @CRLF)
		MsgBox(4096,"","Word Log: " & $logFileInGui)
		GUICtrlSetData ($wordFileGui,$logFileInGui) ; set name of application back into gui
		$logFileSet=True
	EndIf
EndFunc

Func GetHtmlFile()
	$message = "Select HTML File"

	$htmlFileInGui = FileOpenDialog($message, @ScriptDir & "\", "HTML File (*.html)", 8)

	If @error Then
		MsgBox(4096,"","No File(s) chosen")
	Else
		; Dim $szDrive, $szDir, $szFName, $szExt
        ; _PathSplit($htmlFileInGui, $szDrive, $szDir, $szFName, $szExt) ; suck out just the log name
        ; $htmlFileInGui=$szFName&$szExt
		; $htmlFileInGui = StringReplace($htmlFileInGui, "|", @CRLF)
		MsgBox(4096,"","HTML Log: " & $htmlFileInGui)
		GUICtrlSetData ($htmlFileGui,$htmlFileInGui) ; set name of application back into gui
		$htmlFileSet=True
	EndIf
	
EndFunc

; check to see if word file has .doc or docx name
Func ValidWordLog($logName)
	$validExtension=False
	$validPath=False
	
	If stringRight($logName, 5)==".docx" Then
		$validExtension=True
    Else
		If  stringRight($logName, 4)==".doc" Then
			$validExtension=True
		EndIf
	EndIf
	
	If StringLeft($logName,2)=="C:" Then
		$validPath=True
    Else
		If  StringLeft($logName,2)=="c:" Then
			$validPath=True
		EndIf
	EndIf
	
	If $validPath And $validExtension Then
		Return True
	Else
		Return False
	EndIf
EndFunc

; check to see if html file has .htm or .html name
Func ValidHtmlLog($logName)
	$validExtension=False
	$validPath=False
	
	If stringRight($logName, 5)==".html" Then
		$validExtension=True
    Else
		If  stringRight($logName, 4)==".htm" Then
			$validExtension=True
		EndIf
	EndIf
	
	If StringLeft($logName,2)=="C:" Then
		$validPath=True
    Else
		If  StringLeft($logName,2)=="c:" Then
			$validPath=True
		EndIf
	EndIf
	
	If $validPath And $validExtension Then
		Return True
	Else
		Return False
	EndIf
EndFunc