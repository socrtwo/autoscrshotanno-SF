; Scipt to read config file
; Brian Sexton
; First line in config file will say wheter to log to word "Log To Word: Yes"
; Second line will say wheter to log to html "Log To Word: HTML"

; name of the config file
$logFileName="Config.txt"

; warn if config file does not exist
If Not FileExists($logFileName) Then 
	MsgBox(0,"Capture Window", "Config File Does not exist. Will use default settings")
EndIf

; get first line in config file
; should say  "Log To Word: Yes"
Func logToWordConfig()
	Return FileReadLine($logFileName,1)
EndFunc

; get second line in config FileChangeDir
; should say "Log To Word: HTML"
Func logToHtmlConfig()
	Return FileReadLine($logFileName,2)
EndFunc

; file name to say the word document to log To
; will be the third line
Func logToWordFileName()
	Return FileReadLine($logFileName,3)
EndFunc

Func logToHtmlFileName()
	Return FileReadLine($logFileName,4)
EndFunc

Func logCaptureMouse()
	Return FileReadLine($logFileName,5)
EndFunc