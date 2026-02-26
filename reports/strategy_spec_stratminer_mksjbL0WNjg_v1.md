# Strategy Spec — StratMiner v2

- **Source video:** https://www.youtube.com/watch?v=MKsjbL0WNjg
- **Spec version:** v1
- **Status:** Transcript-backed (based on user-provided transcript)
- **Created:** 2026-02-26
- **Intended consumer:** AI sub-agent for backtesting / bot-building

---

## A) Strategy Snapshot
Mechanical 15m reversal strategy using **time-based open-price lines**:

- `L17` = 17:00 EST candle open
- `L00` = 00:00 EST (midnight) candle open
- Optional NY refinement: `L730` = 07:30 EST candle open

Core logic:
- Trade only when price is **above both lines** (sell bias) or **below both lines** (buy bias)
- **No trade** when price is between the two main lines
- Entry trigger = weakness candle + opposite-color confirmation
- Entry execution = limit order at **50% retrace** of confirmation candle

---

## B) Deterministic Rule Set (IF/THEN)

### 1) Market + timeframe
1. IF symbol is Forex (preferably USD pairs), THEN strategy eligible.
2. IF timeframe != M15, THEN do not evaluate signals.

### 2) Daily line construction (EST / New York)
3. At each day:
   - Record `L17` at 17:00 EST candle open
   - Record `L00` at 00:00 EST candle open
   - Extend both levels right until next daily update
4. Optional NY refinement:
   - Record `L730` at 07:30 EST candle open

### 3) Bias filter
5. IF price > `L17` AND > `L00`, THEN sell-only context.
6. IF price < `L17` AND < `L00`, THEN buy-only context.
7. IF price is between `L17` and `L00`, THEN no trade.

### 4) Weakness + confirmation
8. Weakness = rejection/failed continuation behavior (wick/rejection concept from transcript).
9. Short case:
   - IF weakness appears while/after taking a high,
   - THEN require bearish confirmation close,
   - OR allow one-candle confirmation if same candle flips and closes bearish.
10. Long case:
   - IF weakness appears while/after taking a low,
   - THEN require bullish confirmation close,
   - OR allow one-candle confirmation if same candle flips and closes bullish.

### 5) Entry model
11. After valid confirmation candle:
   - `entry = midpoint(confirmation_candle_high, confirmation_candle_low)`
   - Place limit order at `entry`
12. Stop-loss:
   - Short: above weakness candle high
   - Long: below weakness candle low
13. Entry validity:
   - IF retracement to `entry` not reached within 1..3 candles, cancel pending order
   - IF opposite weakness appears before fill, cancel pending order

### 6) Targets
14. Base target: fixed `TP = 3R` (mechanical default)
15. Optional advanced mode: next key high/low (not default)

### 7) Session preference/profile
16. Sessions (EST):
   - Asia: 20:00–00:00
   - London: 02:00–05:00
   - New York: 07:00–10:00
17. Higher-probability profiles:
   - London sweep of Asia high/low + weakness reversal
   - NY continuation after structure break
18. Preferred operating window: London + NY; avoid new trades after NY session.

---

## C) Risk Engine (hard constraints)

Non-negotiable:
- Max risk/trade = 1%
- Max daily drawdown = 5%
- Max total drawdown = 10%
- Max trades/day = 3

Formulas:
- `risk_amount = equity * 0.01`
- `stop_distance = abs(entry - stop)`
- `position_size = risk_amount / (stop_distance * pip_value_per_unit)`

Guards:
- Daily lock: if `(day_start_equity - current_equity) / day_start_equity >= 0.05`, block new trades until next day
- Global halt: if `(initial_equity - current_equity) / initial_equity >= 0.10`, halt strategy
- Trade cap: if `trades_opened_today >= 3`, reject new entries

---

## D) Bot Implementation Spec

### Inputs
- `symbols[]`
- `timezone = America/New_York`
- `tf = M15`
- `use_line_730 = true|false`
- `entry_retrace_pct = 0.50`
- `entry_expiry_candles = 3`
- `target_R = 3.0`
- risk limits from section C

### Runtime state
- `L17`, `L00`, optional `L730`
- session range markers (Asia high/low)
- `trades_today`, `day_start_equity`, `current_equity`

### Signal pipeline
1. Build daily lines
2. Determine bias (above both / below both / between)
3. Detect weakness candle
4. Validate confirmation (2-candle or 1-candle)
5. Place limit order at 50% retrace of confirmation candle
6. Cancel if no fill within 1..3 candles
7. Manage SL/TP until close

### Logging fields
- datetime, symbol, side
- L17/L00/L730 values
- weakness_type, confirmation_type
- entry/sl/tp, R_multiple
- fill_delay_candles
- session_tag
- daily_dd_pct, total_dd_pct, trades_today
- cancel_reason, block_reason

---

## E) Validation Checklist
1. Backtest 2–3+ years on target pairs
2. Include spread + slippage by session
3. Validate timezone handling (EST/EDT)
4. Compare 2-line mode vs 3-line NY refinement mode
5. Report: win rate, PF, expectancy, DD breaches, avg trades/day

---

## F) Unknowns / Clarifications Needed
1. Numeric weakness thresholds (wick/body ratios not explicitly quantified)
2. Exact key-level selection algorithm (imbalance/S&D discretionary elements)
3. Whether 3R is always mandatory or sometimes replaced by structure targets
4. Strictness of pre-session entries / post-NY no-trade behavior

---

## Machine-Readable Summary (for sub-agent ingestion)
```yaml
strategy_id: stratminer_mksjbL0WNjg_v1
timeframe: M15
timezone: America/New_York
pairs_scope: forex_usd_pairs_preferred
lines:
  - name: L17
    time_est: "17:00"
    source: candle_open
  - name: L00
    time_est: "00:00"
    source: candle_open
  - name: L730
    time_est: "07:30"
    source: candle_open
    optional: true
bias_rules:
  above_both: sell_only
  below_both: buy_only
  between: no_trade
confirmation:
  type: opposite_close_after_weakness
  one_candle_flip_allowed: true
entry:
  method: limit
  retrace_pct_of_confirmation_candle: 0.5
  expiry_candles: 3
stop_loss:
  anchor: weakness_candle_extreme
take_profit:
  mode: fixed_R
  R: 3
risk:
  risk_per_trade_pct: 1
  max_daily_dd_pct: 5
  max_total_dd_pct: 10
  max_trades_per_day: 3
sessions_est:
  asia: "20:00-00:00"
  london: "02:00-05:00"
  new_york: "07:00-10:00"
```