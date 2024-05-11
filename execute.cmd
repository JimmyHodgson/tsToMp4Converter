@echo off
setlocal DisableDelayedExpansion

if not exist bad_extension ( mkdir bad_extension )
if not exist processed ( mkdir processed )
if not exist output ( mkdir output )
if not exist input ( mkdir input )

for /f "delims==" %%f in ('dir /b input') do (
    :: Extract the file name without extension
    for %%n in ("%%f") do (
        call :getDate
        set "_name=%%f"
        set "_fil=%%~nn"
        set "_ext=%%~xn"

        :: Use delayed expansion only to print, preventing !! interpretation issues
        setlocal EnableDelayedExpansion
        echo !_result! processing file "!_name!" >> execute.log
        if "!_ext!" EQU ".ts" (
            call :getDate
            echo !_result! Extension ^<.ts^> verified >> execute.log

            "lib\ffmpeg.exe" -loglevel quiet -i "input\!_name!" -codec copy "output\!_fil!.mp4"

            call :getDate
            if errorlevel 1 (
                echo !_result! Error converting file !_name! >> execute.log
            ) else (
                echo !_result! File !_name! converted successfully. >> execute.log

                move "input\!_name!" "processed\!_name!"
            )

        ) else (
            call :getDate

            echo !_result! Unable to process file, extension is ^<!_ext!^> expected ^<.ts^> >> execute.log

            move "input\!_name!" "bad_extension\!_name!"

        )
        endlocal
    )


)

:getDate
SETLOCAL
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
ENDLOCAL & SET _result=%ldt%