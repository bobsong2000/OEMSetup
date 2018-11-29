@echo off
cls
echo ====================================*
echo 作 者: BobSong
echo Create Date: 2018-10-24. 
echo Description: 常用软件安装批处理
echo ====================================

pause
echo.
echo	======正在检测您的系统......======
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
	echo ======您的系统是32位的====== 
	set myBit=x86 
)
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	echo ======您的系统是64位的======
	set myBit=x64
)

echo.
echo	======安装随机必备软件======

:INSTALL_RAR
if exist "%ProgramW6432%\WinRAR\rar.exe" goto :INSTALL_INPUT
echo.
echo ======安装WinRAR======
for  %%i in (%~dp0WINRAR\WinRAR*%myBit%*.exe) do (set myRAR=%%i)
echo 安装myRAR...
start /wait myRAR /s

:INSTALL_INPUT
echo.
echo ======安装输入法======
for %%i in (%~dp0INPUT\*Input*.exe) do (echo 安装%%i...&&start /wait %%i /s)

REM  导入注册表
REM  regedit /s %~dp0REG7\desktop.reg

REM 使用dpinst安装驱动程序
REM  if exist %~dp0Drv\DpInst_X64.exe start /wait %~dp0Drv\DpInst_X64.exe

REM 拷贝软件
rem xcopy e:\*.* d: /s /h /c /y

echo.
echo ======显示说明文件======
explorer.exe "https://github.com/bobsong2000/OEMSetup/blob/master/README.md"


:NETINSTALL
echo.
rem   ======网络安装其他软件======
set /P InstOther= 是否联网安装其他常用软件[Y(default)/N]?
if /I "%InstOther%"=="N"  goto :END

rem    ***根据需要修改
set IntSource=
set OutSource=

echo.
echo	======正在检测网络连接情况......======
ping -n 2 223.5.5.5>%temp%\1.ping
findstr "TTL" %temp%\1.ping>nul
if %errorlevel%==0 (
	set mySource=%OutSource%)        
ping -n 2 10.67.12.130>%temp%\2.ping
findstr "TTL" %temp%\2.ping>nul
if %errorlevel%==0 (
	set mySource=%IntSource%
	echo ======采用内网安装======

) else (
	echo ======采用外网安装======
)
echo  请先配置您的网络后再重新安装。
pause


:SETPATH
rem	======建立本地文件夹======
rem    ***根据需要修改
set myPath=%SystemDrive%\ProgramGreen
echo.
echo	======安装默认路径为：%myPath%======
set /p isCurrent= 是否安装到该文件夹[Y(default)/N]?
:RESETPATH
if /I "%isCurrent%" == "N" (set /p myPath= 请输入新的安装路径:)
if exist %myPath%  (set /p isCurrent= 文件夹已存在，是否覆盖[Y(default)/N]？&&goto :RESETPATH）
echo	======建立%myPath%文件夹======
if not exist %myPath% (mkdir %myPath% 

:COPYFILES
echo.
echo ======开始复制文件......======

REM ======复制文件夹1...======
	set sub-dir=_Baks 
	if not exist %myPath%\%sub-dir% (mkdir %myPath%\%sub-dir%)
	echo.
	echo 正在复制 %myPath%\%sub-dir% 文件夹
	copy %~dp0wget.exe %myPath%\%sub-dir%
	cd /d %myPath%\%sub-dir%
	call wget.exe -c -r -nv -nd %mySource%/%sub-dir%&&del /q wget.exe
echo.

REM ======复制文件夹2...======
	set sub-dir=_Tools 
	echo.
	echo 正在复制 %myPath%\%sub-dir% 文件夹
	if not exist %myPath%\%sub-dir% (mkdir %myPath%\%sub-dir%)
	copy %~dp0wget.exe %myPath%\%sub-dir%
	cd /d %myPath%\%sub-dir%
	call wget.exe -c -r -nv -nd %mySource%/%sub-dir%&&del /q wget.exe >nul


REM ======复制文件夹3...======
	set sub-dir=_Config
	echo.
	echo 正在复制 %myPath%\%sub-dir% 文件夹
	if not exist %myPath%\%sub-dir% (mkdir %myPath%\%sub-dir%)
	copy %~dp0wget.exe %myPath%\%sub-dir%
	cd /d %myPath%\%sub-dir%
                call wget.exe -c -r -nv -nd %mySource%/%sub-dir%&&del /q wget.exe

echo.
if not exist %myPath%\_ShortCuts  goto :INSTALL     ::初次运行安装

pause
exit

:INSTALL
echo.
echo ======安装绿色常用软件======
	cd /d %myPath%\_Baks
	xcopy .\*%myBit%*.rar ..\ /s /h /c /y
	cd /d %myPath%\
	for %%i in (*%myBit%*.rar) do (echo.&&echo 安装%%i...&& "%ProgramW6432%"\WINRAR\RAR.EXE x -y -idq %%i && echo %%i;%myPath%\%%i >> list.txt
	)

echo ======创建软件快捷方式======
set sub-dir=_ShortCuts 
if not exist %myPath%\%sub-dir% (mkdir %myPath%\%sub-dir%)
rem 复制时使用 copy %~dp0wget.exe %myPath%\%sub-dir%
cd /d %myPath%\%sub-dir%
rem 复制时使用call wget.exe -c -r -q -nd %mySource%/%sub-dir%&&del /q wget.exe


if exist tmp.vbs del tmp.vbs /q
:enterFileName
echo.
set /p fileName=      [请输入文件或者目录的全路径]:
if /i "!fileName!"=="" goto :enterFileName
if not exist "%filename%" cls & echo 你输入的目录或者文件名不存在，请重新输入 & pause & goto :enterFileName
echo.
for %%i in ("!fileName!") do set name=%%~ni
set /p shortCutPath=      [请输入将创建方式保存到的路径]:
set shortCutPath="!shortCutPath!\!name!.lnk"
echo Dim WshShell,Shortcut>>tmp.vbs
echo Dim path,fso>>tmp.vbs
echo path="%fileName%">>tmp.vbs
echo Set fso=CreateObject("Scripting.FileSystemObject")>>tmp.vbs
echo Set WshShell=WScript.CreateObject("WScript.Shell")>>tmp.vbs
echo Set Shortcut=WshShell.CreateShortCut(%shortCutPath%)>>tmp.vbs
echo Shortcut.TargetPath=path>>tmp.vbs
echo Shortcut.Save>>tmp.vbs
"%SystemRoot%\System32\WScript.exe" tmp.vbs
::del tmp.vbs /s /q
if exist %shortCutPath% echo 快捷方式创建完毕... & pause>nul
if not exist %shortCutPath% echo 快捷方式创建失败,请重新操作... & pause>nul


pause

:END



echo ======删除临时文件======
REM  RD /S /Q %SystemDrive%\DpInst

echo ======软件已全部安装配置完成!====== 
pause 

exit

