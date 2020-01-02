@echo off
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
call :ColorText 0F "Code Lyoko Episode Upscaler from original quality to 1440p using Waifu2x"
ECHO(
SET /p s="Enter Season Number. (01-04): "
ECHO(
SET /p e="Enter Episode Number. (01-30): "
ECHO(
SET fname=Code Lyoko - s%s%e%e%.mkv
SET f=%~dp0Import\%fname%
SET o=%~dp0Export\%fname%
::f contains entire name of input file without "", 0 contains entire name of output file without ""
ECHO Input Video Path: "%f%"
ECHO Output Video path: "%o%"
ECHO(
if not exist "%f%" (goto :inputVideoGone)
if exist "%o%" (goto :outputVideo)
SET aeo=
SET afo=
SET /p rate="Enter Target Frame Rate of Video. (##): "
:setupEnglishAudioOffset
ECHO(
SET /p aeoi="Enter Offset for English Audio Source in (s.ms) format, prefix with a negative if source starts late. Or type NA if time is synced: "
If NOT %aeoi%==NA (SET aeo=-itsoffset %aeoi% )
ECHO(
SET /p aeoc="Setting Offset to [%aeo%], is this correct? (y/n): "
if NOT %aeoc%==y (goto :setupEnglishAudioOffset)
:setupFrenchAudioOffset
ECHO(
SET /p afoi="Enter Offset for French Audio Source in (s.ms) format, prefix with a negative if English starts late. Or type NA if time is synced: "
If NOT %afoi%==NA (SET afo=-itsoffset %afoi% )
ECHO(
SET /p afoc="Setting Offset to [%afo%], is this correct? (y/n): "
ECHO(
if NOT %afoc%==y (goto :setupFrenchAudioOffset)
SET sei=
SET seo=
SET sema=
SET seml=
SET semt=
SET semh=
SET sfi=
SET sfo=
SET sfma=
SET sfml=
SET sfmt=
SET sfmh=
SET sc=
:setupEnglishSub
SET /p se="Are there English Subtitles in .ass format. (y/n): "
ECHO(
if %se%==y goto :setupEnglishSubCont
if %se%==n goto :setupFrenchSub
goto :setupEnglishSub
:setupEnglishSubCont
if not exist "%~dp0Import\SPE.ass" goto :noEnglishSub
SET /p seoi="Enter Offset for English Sub Source in (s.ms) format, prefix with a negative if source starts late. Or type NA if time is synced: "
If NOT %seoi%==NA (SET seo=-itsoffset %seoi% )
ECHO(
SET /p seoc="Setting Offset to [%seo%], is this correct? (y/n): "
ECHO(
if NOT %seoc%==y (goto :setupEnglishSub)
SET sei=-i "%~dp0Import\SPE.ass" 
SET sema=-map 3:s 
SET seml=-metadata:s:s:3 language=eng 
SET semt=-metadata:s:s:3 title="English" 
SET semh=-metadata:s:s:3 handler="English" 
SET sc=-c:s copy 
:setupFrenchSub
SET /p sf="Are there French Subtitles in .ass format. (y/n): "
ECHO(
if %sf%==y goto :setupFrenchSubCont
if %sf%==n goto :confirmation
goto :setupFrenchSub
:setupFrenchSubCont
if not %sf%==y goto :confirmation
if not exist "%~dp0Import\SPF.ass" goto :noFrenchSub
SET /p sfoi="Enter Offset for French Sub Source in (s.ms) format, prefix with a negative if source starts late. Or type NA if time is synced: "
If NOT %sfoi%==NA (SET sfo=-itsoffset %sfoi% )
ECHO(
SET /p sfoc="Setting Offset to [%sfo%], is this correct? (y/n): "
ECHO(
if NOT %sfoc%==y (goto :setupFrenchSub)
SET fsubtextcheck=-c:s copy 
pause
if NOT [%sc%]==[] (goto :Fsub4)
pause
:Fsub3
SET sfi=-i "%~dp0Import\SPF.ass" 
SET sfma=-map 3:s 
SET sfml=-metadata:s:s:3 language=fra 
SET sfmt=-metadata:s:s:3 title="French" 
SET sfmh=-metadata:s:s:3 handler="French" 
SET sc=-c:s copy 
goto :confirmation
:Fsub4
SET sfi=-i "%~dp0Import\SPF.ass" 
SET sfma=-map 4:s 
SET sfml=-metadata:s:s:4 language=fra 
SET sfmt=-metadata:s:s:4 title="French" 
SET sfmh=-metadata:s:s:4 handler="French" 
SET sc=-c:s copy 
:confirmation
call :ColorText 0F "All necessary Files found"
ECHO(
:enterSequence
ECHO(
SET /p p="Start Procedure from Sequence 1, 2, 3, or 4? (1/2/3/4): "
ECHO(
If %p%==1 goto :exitSequence
If %p%==2 goto :exitSequence
If %p%==3 goto :exitSequence
if %p%==4 goto :exitSequence
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
if %p%==4 goto :Part4
:Part1
call :ColorText 0D "Starting Sequence 1"
ECHO(
call :ColorText 0F "Deleting 480p Frames"
ECHO(
del "%~dp0480Frames\*.png"
call :ColorText 0F "Deletion Complete"
ECHO(
call :ColorText 0B "Extracting 480p Frames from Video Source"
ECHO(
ffmpeg -r:v 1/2 -i "%f%" -vf yadif -c:v png "%~dp0480Frames\OEP%%06d.png" || goto :P1Error
ECHO(
call :ColorText 0B "Extraction Complete"
ECHO(
call :ColorText 0F "Deleting 1440p Frames"
ECHO(
del "%~dp01440Frames\*.png"
call :ColorText 0F "Deletion Complete"
ECHO(
call :ColorText 0D "Finished Sequence 1"
ECHO(
Sleep 3
ECHO(
:Part2
call :ColorText 0D "Starting Sequence 2"
ECHO(
if not exist "%f%" (goto :inputVideoGone)
if exist "%o%" (goto :outputVideo)
call :ColorText 0B "Upscaleing 480p Frames to 1440p"
ECHO(
"%~dp0waifu2x-caffe\waifu2x-caffe-cui.exe" -i "%~dp0480Frames" -e png  -l png -m noise_scale -d 16 -h 1440 -n 1 -p cudnn -c 256 -o "%~dp01440Frames" --auto_start 1 --auto_exit 1 --no_overwrite 1 -y upconv_7_photo || goto :P2Error
call :ColorText 0B "Conversion Complete"
ECHO(
call :ColorText 0D "Finished Sequence 2"
ECHO(
Sleep 3
ECHO(
:Part3
call :ColorText 0D "Starting Sequence 3"
ECHO(
call :ColorText 0F "Deleting Temp Files"
ECHO(
if exist "%~dp0Temp\AudioEPE.aac" del "%~dp0Temp\AudioEPE.aac"
if exist "%~dp0Temp\AudioEPF.aac" del "%~dp0Temp\AudioEPF.aac"
call :ColorText 0F "Deletion Complete"
ECHO(
call :ColorText 0B "Extracting 2 Audio Streams from Source File"
ECHO(
ffmpeg -i "%f%" -map 0:1 -vn -movflags +faststart -acodec aac -b:a 96k "%~dp0Temp\AudioEPF.aac"
ECHO(
ffmpeg -i "%f%" -map 0:2 -vn -movflags +faststart -acodec aac -b:a 96k "%~dp0Temp\AudioEPE.aac"
ECHO(
call :ColorText 0B "Extraction Complete"
ECHO(
call :ColorText 0D "Finished Sequence 3"
ECHO(
Sleep 3
ECHO(
:Part4
call :ColorText 0D "Starting Sequence 4"
ECHO(
::if not exist "%~dp0Import\SPE.ass" goto :noEnglishSub
::if not exist "%~dp0Import\SPF.ass" goto :noFrenchSub
call :ColorText 0B "Muxing 1440p Frames, Two Audio Streams, and applicable Subtitles into MKV with minor compression"
ECHO(
set framenumber=0
for %%x in (%~dp01440Frames\*.png) do set /a framenumber+=1
SET /A videolengthint=%framenumber%/%rate%
SET /A videolengthmod=%framenumber%%%%rate%
SET videolength=%videolengthint%.%videolengthmod%
ECHO %videolengthint%
ECHO %videolengthmod%
ECHO %videolength%
ffmpeg -framerate %rate% -i "%~dp01440Frames\OEP%%06d.png" %aeo%-i "%~dp0Temp\AudioEPE.aac" %afo%-i "%~dp0Temp\AudioEPF.aac" %seo%%sei%%sfo%%sfi%-map 0:v -map 1:a -map 2:a %sema%%sfma%-c:v libx264 -preset medium -crf 18 -c:a copy %sc%-metadata:s:a:0 language=eng -metadata:s:a:0 title="English" -metadata:s:a:1 language=fra -metadata:s:a:1 title="French" -metadata:s:a:0 handler="English" -metadata:s:a:1 handler="French" %seml%%sfml%%semt%%sfmt%%semh%%sfmh%-r 50 -t %videolength% -movflags +faststart "%o%" || goto :P3Error
ECHO(
Sleep 3
call :ColorText 0B "Muxing Complete"
ECHO(
call :ColorText 0D "Finished Sequence 4"
ECHO(
Sleep 1
ECHO(
:Complete
call :ColorText 0A "Procedure Complete, Please save on to Nexus-Titanium before continuing the next Episode"
ECHO(
pause
goto :eof

:inputVideoGone
call :ColorText 0c "Script Terminated, there is no Video Source, or it is not labeled (Code Lyoko - s##e##.mp4)"
ECHO(
pause
goto :eof

:outputVideo
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

:noEnglishSub
call :ColorText 0c "Script Terminated, there is no English Input Subtitle Source in "Import", or it is not labeled SPE.ass"
ECHO(
pause
goto :eof

:noFrenchSub
call :ColorText 0c "Script Terminated, there is no French Input Subtitle Source in "Import", or it is not labeled SPE.ass"
ECHO(
pause
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