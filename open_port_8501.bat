@echo off
:: Этот скрипт нужно запустить от имени администратора
:: Он откроет порт 8501 в брандмауэре Windows

echo Пытаемся добавить правило для порта 8501...
netsh advfirewall firewall add rule name="Open Port 8501" dir=in action=allow protocol=TCP localport=8501

if %errorlevel% equ 0 (
    echo Правило успешно добавлено!
    echo Теперь порт 8501 открыт для входящих подключений.
) else (
    echo Не удалось добавить правило.
    echo Пожалуйста, запустите этот скрипт от имени администратора.
)

pause