@echo off
@setlocal

title Maple Systems Winscout Diagnoser/Helper Utility

REM   __    __ _       __                 _   
REM  / / /\ \ (_)_ __ / _\ ___ ___  _   _| |_ 
REM  \ \/  \/ / | '_ \\ \ / __/ _ \| | | | __|
REM   \  /\  /| | | | |\ \ (_| (_) | |_| | |_ 
REM    \/  \/ |_|_| |_\__/\___\___/ \__,_|\__|
REM                                           
REM  Main Program: winscout-full.bat
REM  Helper Files: winscout-main.bat, tee.bat
REM  Maple Systems Winscout Diagnostic Script
REM  Description: This script tracks running time and saves output from `winscout-main.bat`
REM  Author: Adam Anderson
REM  Code Repo: https://github.com/maplesystemsinc/winscout

REM Horizontal Rules:
set x=##########
set x=%x%%x%%x%%x%%x%%x%%x%%x%
set y=----------
set y=%y%%y%%y%%y%%y%%y%%y%%y%
set z=__________
set z=%z%%z%%z%%z%%z%%z%%z%%z%

ECHO ###############################################################################
ECHO #              MAPLE SYSTEMS WINSCOUT END-USER LICENSE AGREEMENT              #
ECHO #      PLEASE READ AND ACCEPT THE TERMS OF THE EULA PRIOR TO PROCEEDING       #
ECHO ###############################################################################
ECHO # THE USER OF MAPLE SYSTEMS WINSCOUT (MSW), AS DEVELOPED BY MAPLE SYSTEMS,    #
ECHO # INC., HEREBY ACKNOWLEDGES, AND AGREES TO THE FOLLOWING:                     #
ECHO # --------------------------------------------------------------------------- #
ECHO # (1) THE USER UNDERSTANDS THAT USING THIS SCRIPT MAY CAUSE UNWANTED,         #
ECHO # ( ) UNINTENTIONAL, AND/OR ADVERSE RESULTS RELATED TO ANY SYSTEMS ON WHICH   #
ECHO # ( ) THE SCRIPT IS RUN, AND/OR TO ANY OTHER SYSTEMS CONNECTED TO SAID        #
ECHO # ( ) SYSTEM.                                                                 #
ECHO # (2) MAPLE SYSTEMS, INC. BEARS NO LIABILITY OR RESPONSIBILITY FOR ANY DATA   #
ECHO # ( ) LOSS, DEGRADATION OF PERFORMANCE, SYSTEM INSTABILITY, OR SYSTEM FAILURE #
ECHO # ( ) AS A RESULT OF THE INSTALLATION OR EXECUTION OF MSW.                    #
ECHO # (3) MAPLE SYSTEMS, INC. DOES NOT WARRANT ANY SPECIFIC LEVEL OF PERFORMANCE  #
ECHO # ( ) PERTAINING TO MSW.                                                      #
ECHO # (4) MSW IS NOT INTENDED TO BE USED FOR PERFORMANCE TUNING.                  #
ECHO # (5) THE USER AGREES TO HOLD HARMLESS MAPLE SYSTEMS, INC. RELATED TO ANY     #
ECHO # ( ) POTENTIAL ADVERSE EFFECTS OCCURRING AS A RESULT OF THE INSTALLATION OR  #
ECHO # ( ) EXECUTION OF MSW.                                                       #
ECHO ###############################################################################

:Ask
echo Please type 'Y' to agree to the EULA above and run the script.
echo Or type 'N' to cancel and exit.
set INPUT=
set /P INPUT=Type input: %=%
if /I "%INPUT%"=="y" goto begin
if /I "%INPUT%"=="n" goto cancel
echo Please select 'Y'/'N': & goto Ask
:begin
echo Beginning diagnosis...
echo %y%
goto cont
:cancel
echo Exiting now...
echo %y%
goto endprogram
:cont

REM timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
set "timestamp=%datestamp%_%timestamp%"

REM set filename with timestamp, save to current directory
set "filename=ws-results-%timestamp%.txt"
set mypath=%cd%

REM script start time
set start=%time%

REM ############################################################
REM run winscout-main.bat, echo results, and save to %filename%
winscout-main.bat | tee.bat %filename%
REM ############################################################

REM calculate total time to execute
set end=%time%
set options="tokens=1-4 delims=:.,"
for /f %options% %%a in ("%start%") do set start_h=%%a&set /a start_m=100%%b %% 100&set /a start_s=100%%c %% 100&set /a start_ms=100%%d %% 100
for /f %options% %%a in ("%end%") do set end_h=%%a&set /a end_m=100%%b %% 100&set /a end_s=100%%c %% 100&set /a end_ms=100%%d %% 100
set /a hours=%end_h%-%start_h%
set /a mins=%end_m%-%start_m%
set /a secs=%end_s%-%start_s%
set /a ms=%end_ms%-%start_ms%
if %ms% lss 0 set /a secs = %secs% - 1 & set /a ms = 100%ms%
if %secs% lss 0 set /a mins = %mins% - 1 & set /a secs = 60%secs%
if %mins% lss 0 set /a hours = %hours% - 1 & set /a mins = 60%mins%
if %hours% lss 0 set /a hours = 24%hours%
if 1%ms% lss 100 set ms=0%ms%
set /a totalsecs = %hours%*3600 + %mins%*60 + %secs%

REM print total running time and path to output file.
echo SCAN COMPLETE.
echo Total Running Time: %hours% hrs, %mins% min, %secs%.%ms% sec (%totalsecs%.%ms%s)
echo Diagnostic results saved to disk.
echo LOCATION: "%mypath%"
echo FILENAME: "%filename%"

REM append running time to results file
echo. >> %filename%
echo %x% >> %filename%
echo %x% >> %filename%
echo END SCAN RESULTS >> %filename%
echo FILENAME: %filename% >> %filename%
echo TOTAL RUNNING TIME: %hours% hrs, %mins% min, %secs%.%ms% sec (%totalsecs%.%ms%s) >> %filename%
echo %x% >> %filename%
echo %x% >> %filename%

REM Section 7 [OPTIONAL]: Memory Check
echo %z%
echo MEMORY (RAM) CHECK `mdsched.exe`
:Ask
echo NOTE: Memory Check (`mdsched.exe`) requires a reboot.
echo Would you like to run the Memory Check? (Y/N)
set INPUT=
set /P INPUT=Type input: %=%
if /I "%INPUT%"=="y" goto yes 
if /I "%INPUT%"=="n" goto no
echo Please select 'Y'/'N': & goto Ask
:yes
echo.
echo %y%
echo Your system will now be rebooted in order to run the Memory Check.
mdsched.exe
goto cont
:no
echo.
echo %y%
echo Skipping Memory Check...
:cont

echo.
echo %x%
echo SCAN COMPLETE:
echo Please share the diagnostic results with your Tech Support Rep. or IT Admin.
echo LOCATION: "%mypath%"
echo FILENAME: "%filename%"
echo %x%
echo.

pause
:endprogram
