@echo off
chcp 65001 >nul
echo 正在复制 NX_Smart_Post 文件夹到 E:\Siemens\ ...

:: 复制整个 NX_Smart_Post 文件夹（覆盖）
xcopy "%~dp0NX_Smart_Post" "E:\Siemens\NX_Smart_Post" /E /I /H /Y

:: 复制 smart_post 系列文件
copy /Y "%~dp0smart_post.tcl" "E:\Siemens\NX_Smart_Post\application\"
copy /Y "%~dp0smart_post.def" "E:\Siemens\NX_Smart_Post\application\"
copy /Y "%~dp0smart_post.pui" "E:\Siemens\NX_Smart_Post\application\"
copy /Y "%~dp0smart_post_user.tcl" "E:\Siemens\NX_Smart_Post\application\"

:: 复制 smart_post 系列文件
copy /Y "%~dp0smart_post.tcl" "E:\Siemens\NX 12.0\MACH\resource\postprocessor\"
copy /Y "%~dp0smart_post.def" "E:\Siemens\NX 12.0\MACH\resource\postprocessor\"
copy /Y "%~dp0smart_post.pui" "E:\Siemens\NX 12.0\MACH\resource\postprocessor\"
copy /Y "%~dp0smart_post_user.tcl" "E:\Siemens\NX 12.0\MACH\resource\postprocessor\"

echo.
echo NX_Smart_Post 文件夹复制完成！

