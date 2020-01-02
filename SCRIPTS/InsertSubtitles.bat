@echo off
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
SET /p s="Please enter Season Number. (01-04): "
SET /p e="Please enter Episode Number. (01-30): "
for %%a in (%~dp0Import-Subtitles\*.mp4) do set v=%%a
SET f=Code Lyoko - s%s%e%e% - 
setlocal
call :strlen prefixpathsize %~dp0
goto :continueMath

:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    set "t=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!t:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "t=!t:~%%P!"
        )
    )
)
( 
    endlocal
    set "%~1=%len%"
    exit /b
)
:continueMath
SET /a prefixpathlen=%prefixpathsize%
SET /a fullpathlen=%prefixpathlen%+19
CALL SET fulltitle=%%v:~%fullpathlen%%%
SET pretitle=%fulltitle:~0,22%
::fulltitle contains entire name of file without ""
ECHO(
if NOT "%pretitle%"=="%f%" (goto :generalInput)
if not exist "%~dp0\Import-Subtitles\SPE.srt" goto :noEnglishSub
if not exist "%~dp0\Import-Subtitles\SPF.srt" goto :noFrenchSub
call :ColorText 0F "All necessary Files found"
ECHO(
ECHO(
call :ColorText 0E "All Parameters Configured, BEGINNING PROCEDURE"
ECHO(
pause
ECHO(
ECHO(
call :ColorText 0B "Starting Sequence"
ECHO(
call :ColorText 0F "Converting Temp Subtitle Files"
ECHO(
ffmpeg -i "%~dp0Import-Subtitles\SPF.srt" "%~dp0Temp\SPF.ass" || goto :PError
ffmpeg -i "%~dp0Import-Subtitles\SPE.srt" "%~dp0Temp\SPE.ass" || goto :PError
ECHO(
call :ColorText 0F "Conversion Complete"
ECHO(
call :ColorText 0F "Muxing Video and 2 Subtitle Streams into MP4 without additional Compression"
ECHO(
ffmpeg -i "%v%" -i "%~dp0Temp\SPF.ass" -i "%~dp0Temp\SPE.ass" -map 0:v -map 1:s -map 2:s -c:v copy -c:a copy -c:s mov_text -metadata:s:s:3 language=fra -metadata:s:s:4 language=eng -metadata:s:s:3 title="French" -metadata:s:s:4 title="English" -metadata:s:s:3 handler="French" -metadata:s:s:4 handler="English" "%~dp0Export-Subtitles\%fulltitle%" || goto :PError
ECHO:
call :ColorText 0F "Muxing Complete"
ECHO(
call :ColorText 0B "Finished Sequence"
ECHO(
ECHO(
call :ColorText 0A "Subtitle Insertion Complete, Please save on to Nexus-Titanium before continuing the next File"
ECHO(
pause
goto :eof
:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof
:Perror
call :ColorText 0c "MAJOR Error Creating Video, Subtitle Insertion"
pause
goto :eof
:noEnglishSub
call :ColorText 0c "Script Terminated, there is no English Input Subtitle Source in "Import-Subtitles", or it is not labeled SPE.srt"
ECHO(
pause
goto :eof
:noFrenchSub
call :ColorText 0c "Script Terminated, there is no French Input Subtitle Source in "Import-Subtitles-Subtitiles", or it is not labeled SPE.srt"
ECHO(
pause
goto :eof
:generalInput
call :ColorText 0c "Script Terminated, there is no Corrosponding Video in "Import-Subtitles" Folder, or it is not labeled \"Code Lyoko - s%s2%e%e2% - Title\""
ECHO(
pause
goto :eof