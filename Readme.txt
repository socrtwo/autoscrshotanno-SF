Screenshot and Annotations will look for events that change on the PC (new windows, changed menus, new processes, right clicks, etc) and will capture information and screen captures to a log file.

When program first starts, if word is installed it will launch word. Application will create word and HTML log from then on.

Will capture screen when user presses hot key (Control-Alt-C)

Exit program by pressing (Control-Alt-C)

Pause the logging with (Control-Alt-P)

Toggle whether or not to capture the mouse in screen shots with (Control-Alt-m)

License is GPL.

Can use config file with command line option "File". Place in windows shorcut or from command line type
"ScreenShotAndAnnotate File"

The config file can be used to set the log file names or which logs will be created.
Example log file.

Log To Word: Yes
Log To Word: HTML
Log.doc
Log.html
Turn off Mouse during Screen Capture: Yes

First line says whether or not to log to word.
Second line says whether or not to log to HTML.
Third line is name of word log
Fourth line is name of HTML log
Fifth line says whether or not the mouse will hide during capture. (It will flick off if set to yes during screen capture).