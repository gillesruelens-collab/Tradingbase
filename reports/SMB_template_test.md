# SMB — Saturday Market Breakdown (Template v1)

Doel: elke zaterdag een **weekly shortlist** van forex paren met duidelijke setups.

## Google Sheet structuur (test)
Maak 3 tabs:

1) **SMB_Input** (ruwe output per pair per week)
2) **SMB_Overview** (filterbaar weekoverzicht)
3) **SMB_Watchlist** (alleen A/B setups + alerts)

---

## Tab 1: SMB_Input (kolommen)

| Kolom | Naam | Uitleg |
|---|---|---|
| A | Week_Start | Maandag van die week (bv. 2026-02-16) |
| B | Saturday_Run | Datum van zaterdaganalyse |
| C | Pair | EURUSD, GBPUSD, etc. |
| D | Market_Phase | Trend / Range / Transition |
| E | Weekly_High | Buitenste structuur high |
| F | Weekly_Low | Buitenste structuur low |
| G | Close | Laatste close van de week |
| H | Close_In_Range_% | ((Close-Low)/(High-Low))*100 |
| I | Bias | Bullish / Bearish / Neutral |
| J | Primary_Setup | Buy Pullback / Sell Pullback / Reversal Buy / Reversal Sell |
| K | Pattern | M / W / H&S / iH&S / Flag / None |
| L | Entry_Zone | Prijszone |
| M | Invalidation | Ongeldig boven/onder |
| N | TP1 | Eerste target |
| O | TP2 | Tweede target |
| P | Grade | A / B / C |
| Q | Alert_Type | Price Into Zone / Pattern Confirmed / Break Structure |
| R | Alert_Level | Exact prijs voor alert |
| S | Notes | Korte context |

---

## Tab 2: SMB_Overview (week-selectie)

- Cel **B1**: dropdown met beschikbare `Week_Start` waarden.
- In A4 zet je deze formule:

```gs
=QUERY(SMB_Input!A:S,"select * where A = date '"&TEXT(B1,"yyyy-mm-dd")&"' order by P asc",1)
```

- Conditional formatting op kolom P (Grade):
  - A = groen
  - B = oranje
  - C = grijs

- Conditional formatting op kolom Q (Alert_Type):
  - Pattern Confirmed = paars
  - Price Into Zone = blauw
  - Break Structure = rood

---

## Tab 3: SMB_Watchlist (alleen bruikbare setups)

In A1:

```gs
=QUERY(SMB_Input!A:S,"select * where (P='A' or P='B') and A = date '"&TEXT(SMB_Overview!B1,"yyyy-mm-dd")&"' order by P asc",1)
```

Extra kolom (T) `Action_Now`:

```gs
=IF(Q2="Price Into Zone","CHECK NOW",IF(Q2="Pattern Confirmed","READY","WAIT"))
```

---

## Alert-regels (SMB)

Per pair maximaal 3 alerts:
1. **Price Into Zone** → zodra prijs entry zone aantikt
2. **Pattern Confirmed** → M/W/H&S bevestigd op execution timeframe
3. **Break Structure** → invalidatie-level gebroken

---

## SMB test — EURUSD (week 2026-02-16)

- Week_Start: 2026-02-16
- Saturday_Run: 2026-02-21
- Pair: EURUSD
- Market_Phase: Transition to bearish pressure
- Weekly_High: 1.18744
- Weekly_Low: 1.17422
- Close: 1.17860
- Close_In_Range_%: 33.12
- Bias: Bearish-to-neutral near lows
- Primary_Setup: Sell Pullback
- Pattern: Bearish continuation context (confirm on LTF)
- Entry_Zone: 1.1820-1.1865
- Invalidation: >1.18744 acceptance
- TP1: 1.1760
- TP2: 1.1745
- Grade: B
- Alert_Type: Price Into Zone
- Alert_Level: 1.1820
- Notes: Don’t chase sell into weekly low; prefer pullback entry.
