@echo off
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
SET /p m="Would you like to upscale random Frames or Intro? (F/I): "
if p==F (goto :Sequence1)
if p==I (goto :Sequence2)
:Sequence1
call :ColorText 0B "Starting Sequence 2 on TestFrameSource"
ECHO(
if exist "%~dp0TestExport\*.png" (del "%~dp0TestExport\*.png")
call :ColorText 0F "Upscaleing 480p Frames to 1440p"
"%~dp0\waifu2x-caffe\waifu2x-caffe-cui.exe" -i "%~dp0\TestFrameSource" -e png  -l png -m noise_scale -h 1440 -n 1 -p cudnn -d 16 -c 512 -o "C:\Users\Christian\Google Drive\CLEClean Screensaver\TestExport" --auto_start 1 --auto_exit 1 --no_overwrite 1 -y upconv_7_photo || goto :P2Error
call :ColorText 0F "Conversion Complete"
ECHO(
call :ColorText 0D "Finished Sequence 2 on TestFrameSource"
ECHO(
Sleep 1
ECHO(
pause
goto :eof
:Sequence2
call :ColorText 0B "Starting Sequence 2 on TestIntroSource"
ECHO(
if exist "%~dp0TestExport\*.png" (del "%~dp0TestExport\*.png")
call :ColorText 0F "Upscaleing 480p Frames to 1440p"
"%~dp0\waifu2x-caffe\waifu2x-caffe-cui.exe" -i "%~dp0\TestVideoSource" -e png  -l png -m noise_scale -h 1440 -n 0 -p cudnn -c 512 -o "%~dp0\TestExport" --auto_start 1 --auto_exit 1 --no_overwrite 1 -y upconv_7_photo || goto :P2Error
call :ColorText 0F "Conversion Complete"
ECHO(
call :ColorText 0D "Finished Sequence 2 on TestIntroSource"
ECHO(
ECHO(
call :ColorText 0D "Starting Sequence 4"
ECHO(
call :ColorText 0B "Muxing 1440p Frames, Two Audio Streams, and applicable Subtitles into MKV with minor compression"
ECHO(
ffmpeg -framerate %rate% -i "%~dp0TestVideoSource\OEP%%06d.png" -map 0:v -c:v libx264 -preset medium -crf 18 -r 25 -movflags +faststart "%o%" || goto :P3Error
ECHO(
Sleep 3
call :ColorText 0B "Muxing Complete"
ECHO(
call :ColorText 0D "Finished Sequence 4"
ECHO(
Sleep 1
ECHO(
pause
goto :eof
:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof