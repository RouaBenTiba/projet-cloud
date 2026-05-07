#!/bin/bash
set -e

echo "===== SYSTEM UPDATE ====="
apt-get update -y
apt-get install -y curl git nginx build-essential

echo "===== INSTALL NODE 20 ====="
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

npm install -g @angular/cli

echo "===== CLONE REPO ====="
cd /home/ubuntu
rm -rf app
git clone ${github_repo} app

echo "===== FRONTEND ====="
cd /home/ubuntu/app/client

chown -R ubuntu:ubuntu /home/ubuntu/app/client

rm -rf node_modules package-lock.json dist

npm install

echo "===== BUILD ANGULAR ====="
npx ng build --configuration production

echo "===== FIND BUILD PATH (AUTO) ====="
BUILD_PATH=$(find dist -type d -name browser | head -n 1)

if [ -z "$BUILD_PATH" ]; then
  BUILD_PATH=$(find dist -maxdepth 2 -type d | head -n 1)
fi

echo "BUILD PATH: $BUILD_PATH"

if [ ! -f "$BUILD_PATH/index.html" ]; then
  echo "❌ Build failed"
  ls -R dist
  exit 1
fi

echo "===== DEPLOY TO NGINX ====="
rm -rf /var/www/html/*
cp -r "$BUILD_PATH"/* /var/www/html/

echo "===== NGINX CONFIG ====="
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

systemctl enable nginx
systemctl restart nginx

echo "===== TEST ====="
curl http://localhost | head -n 20 || true

echo "DEPLOY DONE"