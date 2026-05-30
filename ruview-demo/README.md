# RuView demo — uitproberen op je MacBook

Dit mapje helpt je de **RuView WiFi-DensePose demo** te draaien met
gesimuleerde data — **geen hardware (ESP32) nodig**. Je kijkt zo in je
browser hoe het systeem werkt.

> Bron-project: https://github.com/ruvnet/RuView
> RuView zet gewone WiFi-signalen om in aanwezigheids-, ademhalings- en
> houdingsdetectie, zonder camera.

---

## Wat je nodig hebt

- Een Mac (of andere computer) met **Docker Desktop**
  → installeer via https://www.docker.com/products/docker-desktop/
- Start Docker Desktop op en wacht tot het icoontje "running" aangeeft.

Controleer in de Terminal:

```bash
docker --version
```

---

## Snelste manier (1 commando)

In de Terminal, in dit mapje:

```bash
cd ruview-demo
chmod +x start.sh      # alleen de allereerste keer
./start.sh
```

Het script controleert Docker, haalt het image op, opent je browser en start
de demo. Stop met `Ctrl + C`.

---

## Alternatief: met Docker Compose

```bash
cd ruview-demo
docker compose up
```

Open daarna in je browser:

```
http://localhost:3000
```

Stoppen: `Ctrl + C`, of in een ander Terminal-tabblad `docker compose down`.

---

## Alternatief: helemaal handmatig

```bash
docker pull ruvnet/wifi-densepose:latest
docker run --rm -p 3000:3000 ruvnet/wifi-densepose:latest
```

Daarna `http://localhost:3000` openen.

---

## Problemen oplossen

| Probleem | Oplossing |
|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop is niet gestart. Open het en wacht tot "running". |
| `port is already allocated` | Poort 3000 is bezet. Gebruik een andere, bv. `docker run --rm -p 8080:3000 ruvnet/wifi-densepose:latest` en open `http://localhost:8080`. |
| Het image kan niet gevonden worden | Controleer je internetverbinding; de naam kan ook `ruvnet/ruview:latest` zijn — kijk op https://hub.docker.com/u/ruvnet |
| Pull duurt lang | Normaal bij de eerste keer; het image is groot. |

---

## Daarna: echt met hardware?

Wil je later verder met echte WiFi-sensing, dan heb je minimaal **één
ESP32-S3** (~€10) nodig (let op: de gewone ESP32 en ESP32-**C3** worden
**niet** ondersteund). Voor goede dekking worden 3–6 nodes aangeraden.
Dat is een vervolgstap; begin gerust eerst met deze demo.
