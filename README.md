Как запустить скрипт
Нажмите Win + X и выберите «Терминал (Администратор)» или «PowerShell (Запуск от имени администратора)».
Разрешите выполнение локальных скриптов на время сессии (если заблокировано политикой безопасности):
powershell


Set-ExecutionPolicy RemoteSigned -Scope Process -Force

Сохраните приведенный ниже код в файл setup-frontend.ps1 и запустите его:
powershell


.\setup-frontend.ps1
