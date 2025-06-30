#!/bin/bash

# Проверка root-прав
if [ "$(id -u)" != "0" ]; then
  echo "Требуются права root. Запустите скрипт с sudo." 
  exit 1
fi

# Установка Docker и зависимостей
if ! command -v docker &> /dev/null; then
  echo "Установка Docker..."
  apt update
  apt install -y docker.io
  apt install qrencode
  systemctl enable --now docker
fi

# Установка Docker Compose
if ! command -v docker-compose &> /dev/null; then
  echo "Установка Docker Compose..."
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Создание рабочей директории
mkdir -p /opt/xray-reality/config
cd /opt/xray-reality

# Генерация ключей
echo "Генерация ключей..."
docker run --rm teddysun/xray xray x25519 > keys.txt
PRIVATE_KEY=$(grep 'Private key:' keys.txt | awk '{print $3}')
PUBLIC_KEY=$(grep 'Public key:' keys.txt | awk '{print $3}')

# Генерация UUID
UUID=$(cat /proc/sys/kernel/random/uuid)

# Генерация short_id (8 символов)
SHORT_ID=$(openssl rand -hex 4)

# Запрос параметров
read -p "Введите порт (по умолчанию 443): " PORT
PORT=${PORT:-443}

read -p "Введите домен назначения (например: yandex.ru): " DEST_DOMAIN
DEST_DOMAIN=${DEST_DOMAIN:-yandex.ru}

read -p "Введите временную зону (по умолчанию Europe/Moscow): " TZ
TZ=${TZ:-Europe/Moscow}

# Создание docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3.8'
services:
  xray:
    image: teddysun/xray:latest
    container_name: xray-reality
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./config:/etc/xray
    environment:
      TZ: "$TZ"
EOF

# Создание config.json
cat > config/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$DEST_DOMAIN:443",
          "xver": 0,
          "serverNames": ["$DEST_DOMAIN"],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": ["$SHORT_ID"]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

# Открытие порта в фаерволе
if command -v ufw &> /dev/null; then
  ufw allow $PORT/tcp
  ufw reload
fi

# Запуск контейнера
echo "Запуск Xray..."
docker-compose up -d

# Проверка работы
sleep 3
docker ps | grep xray-reality

# Вывод параметров
echo -e "\n\033[1;32mУСТАНОВКА ЗАВЕРШЕНА!\033[0m"
echo -e "\n\033[1;33mПАРАМЕТРЫ ДЛЯ ПОДКЛЮЧЕНИЯ:\033[0m"
echo "========================================"
echo "Адрес сервера:    $(curl -s ifconfig.me)"
echo "Порт:             $PORT"
echo "ID пользователя:  $UUID"
echo "Public Key:       $PUBLIC_KEY"
echo "Short ID:         $SHORT_ID"
echo "Flow:             xtls-rprx-vision"
echo "Protocol:         vless"
echo "Network:          tcp"
echo "Security:         reality"
echo "Сервер SNI:       $DEST_DOMAIN"
echo "ALPN:             (пусто)"
echo "Fingerprint:      (пусто)"
echo "========================================"
echo -e "\nQR-код для приложений:"
echo -e "vless://$UUID@$(curl -s ifconfig.me):$PORT?security=reality&encryption=none&pbk=$PUBLIC_KEY&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=$DEST_DOMAIN&sid=$SHORT_ID#Xray-Reality" | qrencode -t UTF8
