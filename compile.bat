@ECHO OFF
:: Allow the install location of Visual Studio 2022 to be set by the environment
IF NOT DEFINED VS_2022_PATH (
       SET "VS_2022_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community"
)
call "%VS_2022_PATH%\VC\Auxiliary\Build\vcvarsall.bat" x64
set "BUILD_DIR=Release"
:: Prepare Ninja for building Release with MSVC
cmake -B %BUILD_DIR% ^
      -G Ninja ^
      --fresh ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DPRODUCTION_BUILD=ON
:: Build
cmake --build %BUILD_DIR% ^
      --clean-first
