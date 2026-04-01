# Zaminor — API Selectie & Integratieplan

**Project:** Zaminor.com — Nederlandstalig vastgoedplatform voor internationale vastgoedaankoop
**Doelgroep:** Nederlandse kopers (35-60 jaar) die vastgoed kopen in Spanje (Costa Blanca) en Dubai (JVC)
**Stack:** Laravel 11 + Next.js 15 + PostgreSQL + Redis
**Datum:** April 2026

---

## Overzicht

Dit document bevat alle geselecteerde API's voor het Zaminor-platform, georganiseerd per feature. Elke API is onderzocht op compatibiliteit met Nederlandse gebruikers, kosten, en relevantie voor de Zaminor koopjourney.

---

## 1. Valuta Omrekening

### Currency-api (PRIMAIR)

- **URL:** https://github.com/fawazahmed0/currency-api
- **Wat het is:** Open-source valuta-API met 150+ valuta's, inclusief EUR, AED (UAE Dirham), USD en GBP. Biedt actuele en historische wisselkoersen zonder rate limits.
- **Auth:** Geen
- **Kosten:** Gratis, geen limieten
- **HTTPS:** Ja
- **Waarom nuttig voor Zaminor:**
  - Essentieel voor de kosten-calculator: Nederlandse kopers moeten EUR omrekenen naar AED (Dubai) en lokale Spaanse kosten in EUR zien.
  - Historische koersen tonen aan klanten hoe wisselkoersen zich ontwikkelen (belangrijk bij grote aankopen van €200K+).
  - Geen rate limits betekent dat alle abonnementstiers (Basis t/m Portfolio Pro) onbeperkt gebruik kunnen maken.
  - Ondersteunt AED — dit is cruciaal. Frankfurter en VATComply (ECB-gebaseerd) ondersteunen GEEN AED.

### Frankfurter (AFGEVALLEN)

- **URL:** https://www.frankfurter.app/docs
- **Reden afgevallen:** Gebruikt ECB als bron. ECB publiceert geen AED (UAE Dirham) koersen. Onbruikbaar voor Dubai-berekeningen. Wel bruikbaar als backup voor EUR-naar-EUR-zone conversies.

---

## 2. BTW & Belasting Validatie

### VATComply.com (PRIMAIR)

- **URL:** https://www.vatcomply.com/documentation
- **Wat het is:** Gratis API voor EU BTW-nummer validatie via het officiële VIES-systeem, BTW-tarieven per EU-land, en wisselkoersen (ECB). Geen authenticatie vereist.
- **Auth:** Geen
- **Kosten:** Gratis, 2 requests per seconde per IP
- **HTTPS:** Ja
- **Endpoints:**
  - `GET /vat?vat_number=NL123456789B01` — Valideer NL BTW-nummer
  - `GET /vat?vat_number=ESA12345678` — Valideer Spaans NIF/CIF
  - `GET /vat_rates` — BTW-tarieven per EU-land
  - `GET /rates` — ECB wisselkoersen
- **Waarom nuttig voor Zaminor:**
  - Valideert Nederlandse BTW-nummers (NL-formaat) en Spaanse NIF/CIF-nummers via het officiële VIES-systeem.
  - Geeft BTW-tarieven per EU-land — nodig voor berekening van Spaanse IVA (overdrachtsbelasting) bij vastgoedaankoop.
  - Relevant voor de Modelo 210 belastingberekening (niet-residenten belasting Spanje).
  - Relevant voor IBI (Impuesto sobre Bienes Inmuebles) berekeningen.
  - 100% uptime track record.

---

## 3. Nederlandse Postcode & Adresvalidatie

### PostcodeData.nl (PRIMAIR — MVP)

- **URL:** http://api.postcodedata.nl/v1/postcode/?postcode=1211EP&streetnumber=60&ref=zaminor.com&type=json
- **Wat het is:** Gratis Nederlandse postcode API die straatnaam, stad, gemeente, provincie en GPS-coordinaten retourneert op basis van postcode + huisnummer.
- **Auth:** Geen (alleen referrer-parameter)
- **Kosten:** Gratis
- **Limiet:** 15.000 requests per uur
- **HTTPS:** Nee (alleen HTTP)
- **Response data:** straatnaam, stad, gemeente, provincie, latitude, longitude
- **Waarom nuttig voor Zaminor:**
  - Automatisch invullen van adresgegevens bij Nederlandse klantregistratie.
  - Klanten hoeven alleen postcode + huisnummer in te vullen, rest wordt automatisch aangevuld.
  - 15.000 req/uur is ruim voldoende voor de verwachte gebruikersbasis.
  - Let op: geen HTTPS — overweeg proxy via eigen backend of upgrade naar Postcode.eu voor productie.

### Kadaster BAG API (AANVULLING — P2)

- **URL:** https://www.kadaster.nl/zakelijk/producten/adressen-en-gebouwen/bag-api-individuele-bevragingen
- **Wat het is:** Officiële Basisregistratie Adressen en Gebouwen van het Kadaster. Bevat alle officieel geregistreerde adressen en gebouwen in Nederland.
- **Auth:** API Key (gratis registratie)
- **Kosten:** Gratis
- **Waarom nuttig voor Zaminor:**
  - Officiële adresvalidatie voor Nederlandse klanten — belangrijk voor compliance en betrouwbaarheid.
  - Kan gebruikt worden om te verifiëren of een ingevoerd adres daadwerkelijk bestaat.
  - Gebouwgegevens kunnen relevant zijn als klanten hun Nederlandse woning willen vergelijken met buitenlands vastgoed.

### Postcode.eu (UPGRADE-PAD — Productie)

- **URL:** https://www.postcode.eu/
- **Wat het is:** Premium postcode-API gebaseerd op officiële Kadaster-data. Industriestandaard in Nederland.
- **Auth:** API Key
- **Kosten:** Freemium (betaald voor productie)
- **Waarom nuttig voor Zaminor:**
  - Upgrade-pad wanneer PostcodeData.nl niet meer voldoet.
  - Officiële data, HTTPS, betrouwbaarder voor productie.
  - Ondersteunt ook Belgische en Luxemburgse postcodes (relevant als doelgroep uitbreidt).

---

## 4. IBAN Validatie

### OpenIBAN (PRIMAIR — EU)

- **URL:** https://openiban.com/
- **Wat het is:** Gratis IBAN-validatie API voor alle SEPA-landen. Voert checksum-validatie uit op IBAN-nummers.
- **Auth:** Geen
- **Kosten:** Gratis, geen gedocumenteerde limieten
- **HTTPS:** Ja
- **Waarom nuttig voor Zaminor:**
  - Valideert Nederlandse IBANs (NL-formaat, bijv. NL91ABNA0417164300).
  - Valideert Spaanse IBANs (ES-formaat) — nodig bij het instellen van betalingen aan Spaanse notarissen/makelaars.
  - Privacy-vriendelijk: geen logging van opgevraagde IBANs.
  - Let op: ondersteunt GEEN UAE IBANs (niet-SEPA). Voor Dubai-transacties is aparte validatie nodig.

### IBAN.com API (AANVULLING — UAE)

- **URL:** https://www.iban.com/validation-api
- **Wat het is:** Meest complete IBAN-validatie API met 97+ landen, inclusief UAE.
- **Auth:** API Key
- **Kosten:** 100 queries/maand gratis trial, daarna betaald
- **Waarom nuttig voor Zaminor:**
  - Enige optie die UAE IBANs kan valideren.
  - Retourneert ook banknaam, BIC/SWIFT-code en branchinformatie.
  - Alleen nodig als Zaminor ook Dubai-betalingen faciliteert.

---

## 5. Kaarten & Geocoding

### Mapbox (PRIMAIR)

- **URL:** https://docs.mapbox.com/
- **Wat het is:** Kaartplatform met interactieve kaarten, geocoding, routing en satellietbeelden. Volledig aanpasbaar qua styling.
- **Auth:** API Key
- **Kosten:** Gratis tot 50.000 map loads/maand (web), daarna pay-as-you-go
- **HTTPS:** Ja
- **Waarom nuttig voor Zaminor:**
  - Interactieve kaarten bij property listings met custom markers (prijs, type, status).
  - Satellietbeelden van hoge kwaliteit voor Spanje (10-20cm resolutie Costa Blanca).
  - 50.000 gratis map loads/maand is ruim voldoende voor pre-launch en early growth.
  - Volledig aanpasbare stijl past bij Zaminor branding.
  - Geocoding API (100.000 req/mnd gratis) voor adres-naar-coordinaat conversie.
  - Let op: Dubai/JVC satellietdekking moet geverifieerd worden met Mapbox support.

### Nominatim / OpenStreetMap (BACKUP — Gratis)

- **URL:** https://nominatim.org/release-docs/latest/api/Overview/
- **Wat het is:** Gratis geocoding service van OpenStreetMap. Forward en reverse geocoding wereldwijd.
- **Auth:** Geen
- **Kosten:** Gratis
- **Waarom nuttig voor Zaminor:**
  - Gratis fallback als Mapbox budget overschrijdt.
  - Goede dekking van Spanje en Dubai.
  - Kan gecombineerd worden met Leaflet voor een volledig gratis kaartoplossing.
  - Minder professionele uitstraling dan Mapbox.

---

## 6. Nederlandse Overheidsdata

### CBS Open Data (StatLine)

- **URL:** https://opendata.cbs.nl/statline/
- **Wat het is:** Officiële statistieken van het Centraal Bureau voor de Statistiek via OData v4 API. Bevat data over woningprijzen, demografie, economie, vermogen en meer.
- **Auth:** Geen
- **Kosten:** Gratis
- **Limiet:** 10.000 cellen per request (Standard API), onbeperkt via Feed API
- **Client libraries:** Python (`cbsodata`), R (`cbsodataR`)
- **Waarom nuttig voor Zaminor:**
  - **Huizenprijsindex Nederland:** Toont klanten hoe de NL woningmarkt zich ontwikkelt vs. Spanje/Dubai.
  - **Vermogensstatistieken:** Relevant voor Box 3 context — hoeveel Nederlanders worden geraakt.
  - **Demografische data:** Onderbouwt content en marktanalyses (bijv. hoeveel Nederlanders wonen in Spanje).
  - **Economische indicatoren:** Inflatie, rente, BBP — relevant voor financiële planning artikelen.
  - Kan gebruikt worden in de content pipeline voor data-driven artikelen.

### Open Government Netherlands (data.overheid.nl)

- **URL:** https://data.overheid.nl/en/ondersteuning/data-publiceren/api
- **Wat het is:** Centraal portaal voor alle Nederlandse overheidsdata. CKAN v3 API voor het doorzoeken van datasets van alle overheidsinstanties.
- **Auth:** Geen
- **Kosten:** Gratis
- **Waarom nuttig voor Zaminor:**
  - Discovery portal om relevante datasets te vinden (belasting, vastgoed, demografie).
  - Kan nieuwe databronnen opleveren naarmate het platform groeit.

### Belastingdienst

- **URL:** https://www.belastingdienst.nl/opendata
- **Wat het is:** Beperkte open data van de Belastingdienst. Developer portal op odb.belastingdienst.nl voor software-ontwikkelaars.
- **Waarom NIET direct bruikbaar voor Zaminor:**
  - Geen publieke API voor Box 3-regels of belastingberekeningen.
  - Box 3-tarieven en vermogensdrempels moeten handmatig in de Zaminor kosten-calculator worden ingebouwd en jaarlijks worden bijgewerkt.
  - De Belastingdienst API is primair voor zakelijke belastingaangifte, niet voor consumenteninformatie.

---

## 7. Landeninformatie

### REST Countries (PRIMAIR)

- **URL:** https://restcountries.com
- **Wat het is:** Gratis API met gedetailleerde informatie over alle landen: valuta, taal, tijdzone, vlag, bevolking, regio en meer.
- **Auth:** Geen
- **Kosten:** Gratis
- **HTTPS:** Ja
- **Waarom nuttig voor Zaminor:**
  - Landenprofielpagina's voor Spanje en UAE automatisch vullen met basisdata.
  - Valuta-informatie per land (EUR voor Spanje, AED voor Dubai).
  - Tijdzoneverschillen tonen (relevant voor contact met makelaars/notarissen).
  - Vlaggen en basisinfo voor de UI.

---

## 8. Feestdagen & Belastingkalender

### Nager.Date (PRIMAIR)

- **URL:** https://date.nager.at
- **Wat het is:** Gratis API voor officiële feestdagen in 90+ landen, inclusief Nederland, Spanje en UAE.
- **Auth:** Geen
- **Kosten:** Gratis
- **HTTPS:** Ja
- **Waarom nuttig voor Zaminor:**
  - Belastingkalender per land: wanneer zijn kantoren dicht (notaris, kadaster, belastingdienst)?
  - Spaanse feestdagen zijn relevant voor bezichtigingsplanning en transactie-timing.
  - Nederlandse feestdagen voor deadline-herinneringen (bijv. aangifte IB, Box 3 peildatum 1 januari).
  - Kan gecombineerd worden met handmatig ingevoerde fiscale deadlines (Modelo 210 deadline, IBI-betaling, etc.).

---

## 9. PDF Documenten & Checklists

### Spatie Laravel PDF v2.0 (PRIMAIR)

- **URL:** https://spatie.be/docs/laravel-pdf/v2
- **Wat het is:** Open-source Laravel package voor PDF-generatie. Ondersteunt meerdere drivers (DomPDF, Browsershot, Cloudflare). Volledig geintegreerd met Laravel 11.
- **Auth:** N.v.t. (lokale package)
- **Kosten:** Gratis (MIT-licentie)
- **Waarom nuttig voor Zaminor:**
  - Past direct in de Laravel 11 stack — geen externe API-calls nodig.
  - Genereert Nederlandstalige PDF documenten-checklists per land (NIE-aanvraag Spanje, DLD-registratie Dubai).
  - Volledige UTF-8 ondersteuning voor Nederlandse tekens.
  - Start met DomPDF driver (geen extra dependencies), upgrade later naar Browsershot voor complexere layouts.
  - Geen kosten, geen rate limits, geen privacy-issues (alles server-side).

### PandaDoc (LATER — P3, E-signatures)

- **URL:** https://developers.pandadoc.com
- **Wat het is:** Document generatie platform met eIDAS-conforme Qualified Electronic Signatures (QES), geldig in alle EU-lidstaten inclusief Nederland.
- **Auth:** API Key
- **Kosten:** Gratis plan: 60 documenten/jaar. Betaald: vanaf EUR 19/user/maand
- **Waarom nuttig voor Zaminor:**
  - Pas relevant in Fase 2-3 wanneer Zaminor daadwerkelijk koopcontracten faciliteert.
  - eIDAS QES is juridisch bindend in Nederland en Spanje.
  - Niet nodig voor MVP — focus eerst op informatie en begeleiding.

---

## 10. PSD2 Open Banking (Financieel Profiel)

### Status: Geen geschikte gratis optie beschikbaar

**Nordigen/GoCardless** was de beste optie maar is **gesloten voor nieuwe klanten sinds september 2025**.

**Commerciele alternatieven om te evalueren:**

| Aanbieder | NL Banken | Kosten | URL |
|---|---|---|---|
| **Tink** (Visa) | ING, ABN, Rabo, Bunq, Triodos | Betaald | https://tink.com |
| **Salt Edge** | 5000+ banken EU-breed | Betaald | https://www.saltedge.com |
| **Yapily** | NL banken ondersteund | Betaald | https://www.yapily.com |

**Waarom relevant voor Zaminor:**
- PSD2-koppeling stelt klanten in staat hun bankgegevens te delen voor een financieel profiel.
- Automatische budgetberekening op basis van werkelijke inkomsten en uitgaven.
- Dit is een Fase 3 feature (Investor/Portfolio Master tiers). Niet nodig voor MVP.
- Aanbeveling: evalueer Tink, Salt Edge en Yapily wanneer Fase 3 nadert.

---

## Prioriteitsmatrix

| Prio | API | Feature | Kosten | Fase |
|---|---|---|---|---|
| P0 | Currency-api | Valuta omrekening EUR/AED/USD | Gratis | Fase 1 |
| P0 | Mapbox | Kaarten bij listings | Gratis (50K/mnd) | Fase 1 |
| P0 | PostcodeData.nl | NL adres-autofill | Gratis | Fase 1 |
| P1 | VATComply.com | BTW validatie NL/ES | Gratis | Fase 1-2 |
| P1 | OpenIBAN | IBAN validatie NL/ES | Gratis | Fase 1-2 |
| P1 | Spatie Laravel PDF | Documenten-checklists | Gratis | Fase 2 |
| P1 | CBS Open Data | NL woningmarkt & statistieken | Gratis | Fase 2 |
| P2 | Kadaster BAG API | Officiële NL adresvalidatie | Gratis | Fase 2 |
| P2 | REST Countries | Landeninformatie | Gratis | Fase 2 |
| P2 | Nager.Date | Belastingkalender | Gratis | Fase 2 |
| P3 | Tink/Salt Edge/Yapily | PSD2 banking NL | Betaald | Fase 3 |
| P3 | PandaDoc | E-signatures (eIDAS) | EUR 19+/mnd | Fase 3 |
| P3 | IBAN.com | UAE IBAN validatie | Betaald | Fase 3 |

---

## Afgevallen API's

| API | Reden |
|---|---|
| Frankfurter | Geen AED (UAE Dirham) support — ECB publiceert geen AED koersen |
| Nordigen/GoCardless | Gesloten voor nieuwe klanten sinds september 2025 |
| Plaid | Te VS-gericht, beperkte NL banken support |
| Google Maps API | 5x duurder dan Mapbox bij vergelijkbaar gebruik |
| CraftMyPDF | Overkill — Spatie Laravel PDF is gratis en past beter in de stack |
| Tax Data API (apilayer) | VATComply.com biedt hetzelfde gratis |
| Exchangerate.host | Currency-api heeft meer valuta's en geen limieten |

---

## Integratie-aantekeningen

### Laravel 11 Backend
- **Currency-api:** HTTP client call vanuit Laravel, cache resultaten in Redis (koersen veranderen max 1x/dag)
- **VATComply.com:** HTTP client, cache BTW-tarieven in Redis (veranderen zelden)
- **PostcodeData.nl:** HTTP client, geen caching nodig (real-time lookup)
- **OpenIBAN:** HTTP client, geen caching nodig (validatie per request)
- **CBS Open Data:** OData v4 calls, cache in PostgreSQL (statistische data verandert per kwartaal)
- **Spatie Laravel PDF:** Composer package, directe integratie
- **Nager.Date:** HTTP client, cache jaarlijks in PostgreSQL

### Next.js 15 Frontend
- **Mapbox:** `react-map-gl` package of Mapbox GL JS direct
- **REST Countries:** Server-side fetch in Next.js, cache met ISR (Incremental Static Regeneration)

### Redis Caching Strategie
- Wisselkoersen: TTL 24 uur
- BTW-tarieven: TTL 7 dagen
- Landeninformatie: TTL 30 dagen
- CBS data: TTL 90 dagen
- Feestdagen: TTL 365 dagen

---

*Laatste update: April 2026*
*Auteur: Gegenereerd voor Zaminor door Claude Code*
