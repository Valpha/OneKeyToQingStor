/*
一键上传图床————青云版本
*/


^!V::

	IfExist, .\settings.ini
	 {
	 IniRead, BUCKET_NAME, .\settings.ini, settings, BUCKET_NAME
	 IniRead, BUCKET_DOMAIN, .\settings.ini, settings, BUCKET_DOMAIN
	 IniRead, DEBUG_MODE, .\settings.ini, settings, DEBUG_MODE
	 IniRead, STYLE_SUFFIX, .\settings.ini, settings, STYLE_SUFFIX
	 }
	else 
	 {
	 MsgBox settings.ini not found.
     return
     }
	IfNotExist, .\config.yaml
	{
		MsgBox, config.yaml was not found.
		return	
	}

    BUCKET_DOMAIN = %BUCKET_DOMAIN%/
    WORKING_DIR = %A_ScriptDir%\
	if(STYLE_SUFFIX!="")
        STYLE_SUFFIX = ?%STYLE_SUFFIX%

	;;;; datetime+randomNum as file name prefix
	Random, rand, 1, 1000
	filePrefix =  %A_yyyy%%A_MM%%A_DD%%A_Hour%%A_Min%_%rand%
    isDebug = /c
    if(DEBUG_MODE="true")
        isDebug = /k

	;MsgBox %clipboard%
    

	if(clipboard){
	    ;MsgBox, probably file in clipboard
		;;;;; get file type by extension
		clipboardStr = %clipboard%
		StringSplit, ColorArray, clipboardStr, `.  ;split by '.'
		maxIndex := ColorArray0  ;get array lenth
		str = ColorArray%maxIndex%  
		fileType := ColorArray%maxIndex%  ;get last element of array, namely file type or file extension
	    filename = %filePrefix%.%fileType%
		; To run multiple commands consecutively, use "&&" between each
		SetWorkingDir, %WORKING_DIR% 
		RunWait, %comspec% %isDebug% qsctl mv %clipboard% qs://%BUCKET_NAME%/%filename% -c %WORKING_DIR%config.yaml 
		
	}else{
	    ;MsgBox, probably binary image in clipboard
		filename = %filePrefix%.png
		fileType := "png"
		pathAndName = %WORKING_DIR%%filename%
		;MsgBox, %pathAndName%
		SetWorkingDir, %WORKING_DIR%
		; here, thanks for https://github.com/octan3/img-clipboard-dump
		RunWait, %comspec% %isDebug% powershell set-executionpolicy remotesigned && powershell -sta -f dump-clipboard-png.ps1 %pathAndName%  && qsctl mv %pathAndName% qs://%BUCKET_NAME%/%filename% -c %WORKING_DIR%config.yaml && del %pathAndName%
	}

	;;;; paste markdown format url to current editor![](http://blog-image.pek3b.qingstor.com/201901230556_918.png)
	resourceUrl = %BUCKET_DOMAIN%%filename%%STYLE_SUFFIX%
	;MsgBox, %resourceUrl%
	; if image file
	if(fileType="jpg" or fileType="png" or fileType="gif" or fileType="bmp" or fileType="jpeg"){
		resourceUrl = ![](%resourceUrl%)
	}
	;MsgBox, %resourceUrl%
	clipboard =  ; Empty the clipboard.
	clipboard = %resourceUrl%

	;MsgBox %clipboard%
	Send ^v

return



