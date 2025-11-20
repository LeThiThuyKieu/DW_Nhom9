@echo off
REM Script để chạy ETL process mỗi ngày
REM Được sử dụng bởi Windows Task Scheduler

REM Chuyển đến thư mục chứa script
cd /d "%~dp0"

REM Chạy ETL process
echo [%date% %time%] Bat dau chay ETL process...
call npm run run:etl

if %errorlevel% equ 0 (
    echo [%date% %time%] ETL process hoan thanh thanh cong!
) else (
    echo [%date% %time%] ETL process that bai!
    exit /b 1
)

