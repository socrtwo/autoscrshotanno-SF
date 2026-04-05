; Scipt to create HTML

func HtmlInit($FileName)
	FileWriteLine($FileName,"<title>Screenshot & Annotations Log</title>")
	FileWriteLine($FileName,"<p>Screenshot & Annotations Log</p>")
	
	$date = @MON & "/" & @MDAY & "/" & @YEAR
	$time = @HOUR & ":" & @MIN & ":" & @SEC
	
	FileWriteLine($FileName,'<p>Date : '&  $date &'</p>')
	FileWriteLine($FileName,'<p>Time : '&  $time &'</p>')
EndFunc

Func LogToHtml($FileName,$text)
	FileWriteLine($FileName,'<p>'& $text &'</p>')	
EndFunc

Func PicToHtml($FileName, $PicName)
		FileWriteLine($FileName,'<img src="' & $PicName & '" width="800" height="600">')
EndFunc