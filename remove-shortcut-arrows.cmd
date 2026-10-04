@echo off
chcp 65001 >nul
title Скрыть или вернуть стрелки на ярлыках

set "MODE=%~1"
if /i "%MODE%"=="off" goto restore
if /i "%MODE%"=="restore" goto restore

>nul 2>&1 reg query "HKU\S-1-5-19"
if errorlevel 1 (
    echo [Ошибка] Нужны права администратора!
    pause
    exit /b 1
)

echo [1/4] Создание blank.ico ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=32;$o=$env:SystemRoot+'\blank.ico';$x=New-Object byte[] ($s*$s*4);$a=New-Object byte[] ($s*4);for($i=0;$i -lt $a.Length;$i++){$a[$i]=255};$m=New-Object IO.MemoryStream;$w=New-Object IO.BinaryWriter($m);$w.Write([int]40);$w.Write([int]$s);$w.Write([int]($s*2));$w.Write([int16]1);$w.Write([int16]32);$w.Write([int]0);$w.Write([int]($x.Length+$a.Length));$w.Write([int]0);$w.Write([int]0);$w.Write([int]0);$w.Write([int]0);$w.Write($x);$w.Write($a);$d=$m.ToArray();$f=New-Object IO.MemoryStream;$w2=New-Object IO.BinaryWriter($f);$w2.Write([int16]0);$w2.Write([int16]1);$w2.Write([int16]1);$w2.Write([byte]$s);$w2.Write([byte]$s);$w2.Write([byte]0);$w2.Write([byte]0);$w2.Write([int16]1);$w2.Write([int16]32);$w2.Write([int]$d.Length);$w2.Write([int]22);$w2.Write($d);[IO.File]::WriteAllBytes($o,$f.ToArray())"
if errorlevel 1 (
    echo [Ошибка] Не удалось выполнить создание blank.ico
    pause
    exit /b 1
)

echo [2/4] Создание оверлея в HKLM ...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /t REG_SZ /d "%SystemRoot%\blank.ico" /f >nul
if errorlevel 1 (
    echo [Ошибка] Не удалось выполнить запись в HKLM
    pause
    exit /b 1
)

echo [3/4] Отключение штатного оверлея в HKCU ...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v IsShortcut /t REG_DWORD /d 0 /f >nul

echo [4/4] Очистка кэша иконок, выполняется перезапуск проводника ...
taskkill /f /im explorer.exe >nul 2>&1
>nul 2>&1 ping -n 3 127.0.0.1
del /q "%LOCALAPPDATA%\IconCache.db" >nul 2>&1
del /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db" >nul 2>&1
start "" explorer.exe

echo.
echo [Готово] Выполнение успешно завершено
>nul 2>&1 ping -n 3 127.0.0.1
exit /b 0

:restore
>nul 2>&1 reg query "HKU\S-1-5-19"
if errorlevel 1 (
    echo [Ошибка] Нужны права администратора!
    pause
    exit /b 1
)

echo [1/3] Удаление оверлея из HKLM ...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f >nul

echo [2/3] Удаление оверлея из HKCU ...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v IsShortcut /f >nul

echo [3/3] Удаление blank.ico. Выполняется перезапуск проводника ...
del /q "%SystemRoot%\blank.ico" >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
>nul 2>&1 ping -n 3 127.0.0.1
del /q "%LOCALAPPDATA%\IconCache.db" >nul 2>&1
del /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db" >nul 2>&1
start "" explorer.exe

echo.
echo [Готово] Возврат стрелок успешно выполнен
>nul 2>&1 ping -n 3 127.0.0.1
exit /b 0
