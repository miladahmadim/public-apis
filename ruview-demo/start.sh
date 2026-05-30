#!/usr/bin/env bash
#
# RuView demo starter voor macOS.
# Gebruik:  ./start.sh
#
set -euo pipefail

echo "==> RuView WiFi-DensePose demo starten..."

# 1. Controleer of Docker draait
if ! docker info >/dev/null 2>&1; then
  echo "FOUT: Docker draait niet."
  echo "      Open Docker Desktop en wacht tot het 'running' is, en probeer opnieuw."
  echo "      Nog geen Docker? -> https://www.docker.com/products/docker-desktop/"
  exit 1
fi

# 2. Image ophalen (eerste keer kan even duren)
echo "==> Image ophalen (ruvnet/wifi-densepose:latest)..."
docker pull ruvnet/wifi-densepose:latest

# 3. Starten
echo "==> Container starten op http://localhost:3000"
echo "    (Stop met Ctrl + C)"
open "http://localhost:3000" 2>/dev/null || true
docker run --rm -p 3000:3000 ruvnet/wifi-densepose:latest
