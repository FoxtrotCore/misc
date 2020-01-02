@echo off
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
if not exist "%~dp0Import\EP.mkv" goto :noInput
if exist "%~dp0Export\Code Lyoko - s##e## - TITLE.mp4" goto :GeneralVideo
call :ColorText 0F "All necessary Files found"
ECHO(
:enterSequence
ECHO(
SET /p p="Start Procedure from Sequence 1, 2, or 3? (1/2/3): "
ECHO(
If %p%==1 goto :exitSequence
If %p%==2 goto :exitSequence
If %p%==3 goto :exitSequence
call :ColorText 06 "Incorrect Value"
ECHO(
goto :enterSequence
:exitSequence
ECHO(
call :ColorText 0E "All Parameters Configured, BEGINNING PROCEDURE"
ECHO(
pause
ECHO(
ECHO(
if %p%==1 goto :Part1
if %p%==2 goto :Part2
if %p%==3 goto :Part3
:Part1
call :ColorText 0B "Starting Sequence 1"
ECHO(
call :ColorText 0F "Deleting 480p Frames"
ECHO(
del "%~dp0480Frames\*.png"
call :ColorText 0F "Deletion Complete"
ECHO(
call :ColorText 0F "Extracting 480p Frames from Video Source"
ECHO(
ffmpeg -i "%~dp0Import\EP.mkv" -c:v png "%~dp0480Frames\OEP%%07d.png" || goto :P1Error
ECHO(
call :ColorText 0F "Extraction Complete"
ECHO(
call :ColorText 0D "Finished Sequence 1"
ECHO(
ECHO(
:Part2
call :ColorText 0B "Starting Sequence 2"
ECHO(
call :ColorText 0F "Deleting 1440p Frames"
ECHO(
del "%~dp01440Frames\*.png"
call :ColorText 0F "Deletion Complete"
ECHO(
call :ColorText 0F "Upscaleing 480p Frames to 1440p"
"%~dp0waifu2x-caffe\waifu2x-caffe-cui.exe" -i "%~dp0480Frames" -e png  -l png -m noise_scale -h 1440 -n 3 -p cudnn -c 512 -o "%~dp01440Frames" --auto_start 1 --auto_exit 1 --no_overwrite 1 -y upconv_7_photo || goto :P2Error
call :ColorText 0F "Conversion Complete"
ECHO(
call :ColorText 0D "Finished Sequence 2"
ECHO(
ECHO(
:Part3
call :ColorText 0B "Starting Sequence 3"
ECHO(
call :ColorText 0F "Deleting Temp Files"
ECHO(
if exist "%~dp0Temp\AudioEPE.aac" del "%~dp0Temp\AudioEPE.aac"
if exist "%~dp0Temp\AudioEPF.aac" del "%~dp0Temp\AudioEPF.aac"
call :ColorText 0F "Deletion Complete"
ECHO(
call :ColorText 0B "Muxing 1440p Frames and Two Audio Streams into MP4 with minor Compression"
ECHO(
ffmpeg -i "%~dp0Import\EP.mkv" -map 0:1 -vn -movflags +faststart -acodec aac -b:a 96k "%~dp0Temp\AudioEPF.aac"
ffmpeg -i "%~dp0Import\EP.mkv" -map 0:2 -vn -movflags +faststart -acodec aac -b:a 96k "%~dp0Temp\AudioEPE.aac"
ffmpeg -framerate 50 -i "%~dp01440Frames\OEP%%07d.png" -i "%~dp0Temp\AudioEPF.aac" -itsoffset 1.00 -i "%~dp0Temp\AudioEPE.aac" -map 0:v -map 1:a -map 2:a -c:v libx264 -preset medium -crf 18 -c:a copy -metadata:s:a:0 language=fra -metadata:s:a:0 title="French" -metadata:s:a:1 language=eng -metadata:s:a:1 title="English" -metadata:s:a:0 handler="French" -metadata:s:a:1 handler="English" -r 50 -movflags +faststart -shortest "%~dp0Export\Code Lyoko - s##e## - TITLE.mp4" || goto :P3Error
call :ColorText 0F "Muxing Complete"
ECHO(
call :ColorText 0D "Finished Sequence 3"
ECHO(
ECHO(
:Complete
call :ColorText 0A "Procedure Complete, Please save on to Nexus-Titanium before continuing the next Episode"
ECHO(
pause
goto :eof

:noInput
call :ColorText 0c "Script Terminated, there is no Video Source, or it is not labeled EP.mp4"
ECHO(
pause
goto :eof

:GeneralVideo
call :ColorText 0c "Script Terminated, there is still a Final Product in the Export Folder. This is just a Precautionary Error asking you to save the Video, if you havent, so you didnt just waste the past 7 hours. Remove the file from the directory and rerun the script"
ECHO(
pause
goto :eof

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof

:P1Error
ECHO(
call :ColorText 0c "MAJOR Error Creating Video, The Image Splitting Sequence has failed"
pause
goto :eof
:P1Error
ECHO(
call :ColorText 0c "MAJOR Error Creating Video, The Upscaling Sequence has failed"
pause
goto :eof
:P3error
ECHO(
call :ColorText 0c "MAJOR Error Creating Video, The Video Export Sequence has failed"
pause
goto :eof