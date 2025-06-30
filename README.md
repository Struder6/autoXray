# autoXray
bash script that allows you to install Xray + REALITY in a blink of an eye

![Docker](https://img.shields.io/badge/Docker-✓-blue?logo=docker)
![Xray](https://img.shields.io/badge/Xray-✓-success)
![Reality](https://img.shields.io/badge/Reality-✓-important)
![Bash](https://img.shields.io/badge/Bash-v5.0%2B-green)

Автоматический скрипт для установки Xray сервера с протоколом Reality с использованием Docker. Скрипт генерирует все необходимые ключи, настраивает окружение и предоставляет параметры подключения в удобном формате.

## Особенности

- Полностью автоматическая установка
- Генерация ключей и UUID
- Настройка фаервола
- Поддержка пользовательских параметров
- QR-код для быстрого подключения
- Простое обновление

## Предварительные требования

- Сервер с Ubuntu/Debian (рекомендуется Ubuntu 20.04+)
- Доступ с правами root
- Интернет-соединение

## Установка

1. Скачайте скрипт установки:
```bash
curl -O https://github.com/Struder6/autoXray.git
```

2. Дайте права на выполнение:
```bash
chmod +x xray.sh
```

3. Запустите скрипт:
```bash
sudo ./xray.sh
```

## Использование

Во время установки скрипт запросит:
1. Порт для Xray (по умолчанию: 443)
2. Домен назначения для маскировки (по умолчанию: yandex.ru)
3. Временную зону (по умолчанию: Europe/Moscow)

После установки будут показаны параметры подключения:

```
========================================
Адрес сервера:    192.168.1.100
Порт:             443
ID пользователя:  7a4c3e2b-1d8f-4a6c-9b0e-5f3d2c1a8b76
Public Key:       wWxXyYzZ0123456789abcdefghijklmnop
Short ID:         baacd3
Flow:             xtls-rprx-vision
Protocol:         vless
Network:          tcp
Security:         reality
Сервер SNI:       yandex.ru
========================================
```

## Обновление

Для обновления Xray до последней версии:

```bash
cd /opt/xray-reality
docker-compose pull
docker-compose up -d --force-recreate
```

## Параметры подключения (пример для v2rayN)

| Параметр         | Значение                     |
|------------------|-----------------------------|
| Address          | IP вашего сервера           |
| Port             | 443                         |
| ID               | 7a4c3e2b-1d8f-4a6c-9b0e-5f3d2c1a8b76 |
| Flow             | xtls-rprx-vision            |
| Encryption       | none                        |
| Transport        | reality                     |
| Public Key       | wWxXyYzZ0123456789abcdefghijklmnop |
| Short ID         | baacd3                      |
| SpiderX          | Отключено                   |
| Сервер SNI       | yandex.ru                   |

## Управление сервисом

- Проверить статус:
```bash
docker ps | grep xray-reality
```

- Просмотр логов:
```bash
docker logs xray-reality
```

- Остановить сервис:
```bash
cd /opt/xray-reality
docker-compose down
```

- Запустить сервис:
```bash
cd /opt/xray-reality
docker-compose up -d
```

## Безопасность

- Не передавайте и не публикуйте свои приватные ключи
- Регулярно обновляйте Xray
- Используйте сложные UUID
- Ограничьте доступ к серверу с помощью фаервола

## Устранение проблем

Если соединение не работает:
1. Проверьте открыт ли порт: `sudo ufw status`
2. Проверьте логи: `docker logs xray-reality`
3. Убедитесь что домен назначения доступен
4. Проверьте правильность параметров подключения

