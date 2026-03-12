@echo off
setlocal

REM ============================
REM 0) Locate VS DevCmd
REM ============================
set "VSENV_INS=C:\Program Files\Microsoft Visual Studio\18\Insiders\Common7\Tools\VsDevCmd.bat"
set "VSENV_22=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat"

if exist "%VSENV_INS%" (
  echo [env] Using VS 2026 Insiders
  call "%VSENV_INS%" -arch=x64 -host_arch=x64
) else if exist "%VSENV_22%" (
  echo [env] Using VS 2022 BuildTools
  call "%VSENV_22%" -arch=x64 -host_arch=x64
) else (
  echo [error] VsDevCmd.bat not found.
  echo Checked:
  echo   "%VSENV_INS%"
  echo   "%VSENV_22%"
  pause
  exit /b 1
)

REM ============================
REM 1) Project root
REM ============================
set "PROJ=C:\premier predict"
if not exist "%PROJ%\CMakeLists.txt" (
  echo [error] Project folder not found or missing CMakeLists.txt:
  echo   "%PROJ%"
  pause
  exit /b 1
)
cd /d "%PROJ%"

REM ============================
REM 2) Qt paths
REM ============================
set "QT_DIR=C:\newqt\6.10.2\msvc2022_64"
set "QT_CMAKE=%QT_DIR%\lib\cmake\Qt6"
set "QT_BIN=%QT_DIR%\bin"

if not exist "%QT_CMAKE%\Qt6Config.cmake" (
  echo [error] Qt6Config.cmake not found:
  echo   "%QT_CMAKE%\Qt6Config.cmake"
  pause
  exit /b 1
)

REM ============================
REM 3) Clean build (optional)
REM ============================
if exist build (
  echo [clean] Removing build...
  rmdir /s /q build
)

REM ============================
REM 4) Configure + Build
REM ============================
echo [cmake] Configure...
cmake -S . -B build -G "NMake Makefiles" -DBUILD_GUI=ON -DQt6_DIR="%QT_CMAKE%"
if errorlevel 1 goto :fail

echo [cmake] Build...
cmake --build build
if errorlevel 1 goto :fail

REM ============================
REM 5) Build dataset + Train
REM ============================
if not exist data\processed mkdir data\processed

echo [data] build_dataset...
".\build\build_dataset.exe"
if errorlevel 1 goto :fail

echo [ml] train_model...
".\build\train_model.exe"
if errorlevel 1 goto :fail

REM ============================
REM 6) Run GUI
REM ============================
echo [run] epl_app...
set "PATH=%QT_BIN%;%PATH%"
".\build\epl_app.exe"

echo.
echo [done]
pause
exit /b 0

:fail
echo.
echo [FAILED] See errors above.
pause
exit /b 1