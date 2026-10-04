# No shortcut arrows

Скрывает стрелки на ярлыках Windows 10, 11 через реестр. Без сторонних программ.

## Как работает

Переопределяет ресурс 29 в `imageres.dll` пустой иконкой через `Explorer\Shell Icons`

## Запуск

```bat
remove-shortcut-arrows.cmd          :: скрывает стрелки
remove-shortcut-arrows.cmd off      :: возвращает стрелки обратно
```

Нужны права администратора. Проводник перезапустится автоматически.

## Что меняется

- `HKLM\...\Explorer\Shell Icons` → `29` = `C:\Windows\blank.ico`
- `HKCU\...\Explorer\Shell Icons` → `IsShortcut` = `0`
- Создаётся `C:\Windows\blank.ico`, чистится кэш иконок

## Откат вручную

```powershell
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v IsShortcut /f
Remove-Item C:\Windows\blank.ico -Force
Stop-Process -Name explorer -Force; Start-Process explorer.exe
```

## Ограничения

Стрелки могут вернуться после крупных обновлений Windows - требуется повторить скрипт.

## Лицензия

[MIT](LICENSE)
