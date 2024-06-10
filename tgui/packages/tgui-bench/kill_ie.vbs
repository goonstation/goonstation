Dim oShell : Set oShell = CreateObject("WScript.Shell")
oShell.Run "taskkill /f /im iexplore.exe", , True
oShell.Run "taskkill /f /im ilowutil.exe", , True
