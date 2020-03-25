@echo off
setlocal EnableDelayedExpansion

if not exist bad_extension ( mkdir bad_extension )
if not exist processed ( mkdir processed )
if not exist output ( mkdir output )
if not exist input ( mkdir input )

for /f "delims==" %%f in ('dir /b input') do (
    call :getDate
    echo !_result! processing file "%%f" >> execute.log
    set _ext=%%~xf
    set _fil=%%~nf
    if "!_ext!" EQU ".ts" (
        call :getDate
        echo !_result! Extension ^<.ts^> verified >> execute.log

        "lib\ffmpeg.exe" -loglevel quiet -i "input\%%f" -codec copy "output\!_fil!.mp4"

        call :getDate
        if errorlevel 1 (
            echo !_result! Error converting file %%f >> execute.log
        ) else (
            echo !_result! File %%f converted successfully. >> execute.log

            move "input\%%f" "processed\%%f"
        )

    ) else (
        call :getDate

        echo !_result! Unable to process file, extension is ^<!_ext!^> expected ^<.ts^> >> execute.log

        move "input\%%f" "bad_extension\%%f"

    )

)

:getDate
SETLOCAL
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
ENDLOCAL & SET _result=%ldt%