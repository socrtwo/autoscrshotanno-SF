#include <Word.au3>

func WordInit($FileName)
	$currentScreen=WinGetTitle("")  ; get title of current screen so we can go back to it
	
	LogToWord($FileName,"Screenshot & Annotations Log")
	
	$date = @MON & "/" & @MDAY & "/" & @YEAR
	$time = @HOUR & ":" & @MIN & ":" & @SEC
	
	LogToWord($FileName,'Date : '&  $date)
	LogToWord($FileName,'Time : '&  $time)
	
	LogToWord($FileName,$currentScreen)
	WinWait($currentScreen)
	If Not WinActive($currentScreen) Then WinActivate($currentScreen)
	WinActivate($currentScreen) ; go back off of word but leave it open
EndFunc

; get word version and decide if word is installed
Func _WordGetVersion()
    Local $oWord, $WordVer

    $oWord = ObjCreate("Word.Basic")
    If IsObj($oWord) Then
        $WordVer = $oWord.AppInfo(2)
    Else
		MsgBox(0,"","Word not installed")
        $WordVer = 0
    EndIf
    $oWord = ""
    Return $WordVer
EndFunc


Func _WordAddLineBreak(ByRef $o_object)
    $o_object.ActiveDocument.Content.InsertParagraphAfter
EndFunc

Func _WordAddSection(ByRef $o_object)
    $o_object.ActiveDocument.Sections.Add
EndFunc

Func _WordAppendText(ByRef $o_object, $sText)
    If Not IsObj($o_object) Then
        __WordErrorNotify("Error", "_WordAppendText", "$_WordStatus_InvalidDataType")
        SetError($_WordStatus_InvalidDataType, 1)
        Return 0
    EndIf
    $o_object.Range.insertAfter($sText)
    SetError($_WordStatus_Success)
    Return 1
EndFunc  

Func LogToWord($wordLogFileName,$text)
    $oWordApp = _WordCreate($wordLogFileName)
    $oDoc = _WordDocGetCollection($oWordApp, 0)

	$oSelection = $oWordApp.Selection

	$oSelection.TypeText($text)	
	$oSelection.TypeParagraph()
EndFunc

Func PicToWord($fileName, $picName)
	$oWordApp = _WordCreate($fileName)
    $oDoc = _WordDocGetCollection($oWordApp, 0)
	$filqq1 = $fileName & "\" & $picName
	$oSelection = $oWordApp.Selection
	Dim $szDrive, $szDir, $szFName, $szExt
     _PathSplit($fileName, $szDrive, $szDir, $szFName, $szExt) ; suck out just the path
	 $fileName=$szDrive&$szDir
	$oShape = $oSelection.InlineShapes.AddPicture($fileName & $picName)
EndFunc

Func CloseWord($wordLogFileName)
	$oWordApp = _WordCreate($wordLogFileName)
	$oDoc = _WordDocGetCollection($oWordApp, 0)
	$oDoc.Save $fileName 6
    $oDoc.close
    WinClose("Microsoft Word")
EndFunc