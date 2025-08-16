# EasyParking Backend

A data-driven parking backend prototype: provides “Nearby Parking,” “Keyword Search,” and “Future Vacancy Probability” features, forming a complete pipeline from data ingestion to API exposure.

- Tech stack: Flask (REST API) + MySQL (data store) + data ingestion/prediction scripts
- Default port: 5001 (CORS enabled)
- Routing style: most endpoints support both plain and `/api`-prefixed forms (e.g., `/nearby` and `/api/nearby`)

---

## Quick Start

Prerequisites:
- MySQL installed and database `Eparking_opendata` created
- Python 3.10+ (3.10–3.13 are fine)
- Optional: create a virtual environment and install dependencies

Create a virtual environment (optional):
```bash
python3 -m venv .venv
```

Activate the virtual environment (macOS):
```bash
source .venv/bin/activate
```

Install core dependencies (minimal runnable set):
```bash
pip install flask flask-cors mysql-connector-python requests passlib[bcrypt] pandas
```

Start the backend API service:
```bash
python3 easyparkingAPI.py
```

Run data ingestion and prediction (populate DB for demo):
- Ingest car-park base info (static)
```bash
python3 Parking_info.py
```

- Ingest near real-time vacancy
```bash
python3 Parking_Vacancy_Data.py
```

- Ingest historical data (15-min granularity with incremental updates)
```bash
python3 Parking_Vacancy_historical_Data.py
```

- Compute future vacancy probability (96 x 15-min slots)
```bash
python3 predict_vacancy_probability.py
```

---

## Features

- Nearby search: query car parks within a radius and return real-time vacancy with last update time
- Keyword search: fuzzy match by name/address
- Probability forecast: compute the probability of having a vacancy for each 15-min slot (96 per day)
- Data ingestion: fetch government open data, cleanse, and store
- Prediction storage: write statistical probabilities to DB for API consumption
- CORS: frontends/static pages can call APIs directly

---

## Repository Structure

- <mcfile name="easyparkingAPI.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/easyparkingAPI.py"></mcfile>: Flask API main program (public endpoints)
- <mcfile name="Parking_info.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/Parking_info.py"></mcfile>: ingest and store car-park base info
- <mcfile name="Parking_Vacancy_Data.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/Parking_Vacancy_Data.py"></mcfile>: ingest near real-time vacancy (with connection pool and batch UPSERT)
- <mcfile name="Parking_Vacancy_historical_Data.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/Parking_Vacancy_historical_Data.py"></mcfile>: ingest 15-min historical data (incremental)
- <mcfile name="predict_vacancy_probability.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/predict_vacancy_probability.py"></mcfile>: compute historical-based vacancy probabilities and write to DB
- <mcfile name="current_status_updater.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/current_status_updater.py"></mcfile>: periodic aggregation for “current status” table
- <mcfile name="test_parking_api.html" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/test_parking_api.html"></mcfile>, <mcfile name="test_login.html" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/test_login.html"></mcfile>: simple test pages (pointing to `http://127.0.0.1:5001/api`)
- <mcfile name="easyparking_data_mining.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/easyparking_data_mining.py"></mcfile>: data mining/exploratory analysis (optional deps)

---

## API

Base URL: `http://127.0.0.1:5001` (aliases available under `/api`)

1) Nearby
- Path: `/nearby` or `/api/nearby`
- Method: GET
- Params:
  - `lat`: latitude (required)
  - `lon`: longitude (required)
  - `radius`: meters (default 1000)
  - `limit`: number of results (optional)
- Example:
```bash
curl "http://127.0.0.1:5001/nearby?lat=22.302711&lon=114.177216&radius=1000&limit=10"
```

2) Search
- Path: `/search` or `/api/search`
- Method: GET
- Params:
  - `q`: keyword
- Example:
```bash
curl "http://127.0.0.1:5001/search?q=Central"
```

3) Forecast
- Path: `/forecast` or `/api/forecast`
- Method: GET
- Params:
  - `park_id`: unique car-park ID (required)
- Returns:
  - `now_slot`: current UTC time slot index (0–95, 15-min each)
  - `probabilities`: an array of 96 objects `{ slot, p }`
- Example:
```bash
curl "http://127.0.0.1:5001/forecast?park_id=tdc26p2"
```

---

## Architecture & Data Flow

- API layer (Flask): exposes REST APIs; unified DB config, parameterized queries, and CORS
- Data layer (MySQL): stores base info, real-time/historical detail, current status, and probability results
- Task layer (scripts):
  - Ingestion: fetch JSON from government open data (BOM handling, DNS check, network error handling)
  - Cleansing: validate required fields, normalize types, batch commit with rollback
  - Storage: UPSERT into respective tables
  - Prediction: compute `p_availability = mean(vacancy > 0)` by (park_id, slot) and write to probability table
- Frontend usage: call APIs directly to display nearby results, search outcomes, and probability curves

---

## Database (Overview)

Key tables:
- `car_park_basic_info`: base info (name, address, lat/lon, etc.)
- `car_park_vacancy_info`: near real-time details (with `vehicle_type/service_category`)
- `car_park_historical_info`: historical details (15-min granularity)
- `car_park_current_status`: aggregated “current status”
- `car_park_vacancy_probability`: prediction results (`park_id` × `slot(0–95)` × `p_availability`)

Notes:
- Define appropriate unique keys for detail tables (e.g., `park_id + lastupdate + vehicle_type + service_category + vacancy_type`) to support UPSERT
- Use consistent charset and collation: `utf8mb4 / utf8mb4_unicode_ci` (aligned with scripts and API config)

---

## Configuration

- API’s MySQL config is centralized in `DB_CONFIG` within <mcfile name="easyparkingAPI.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/easyparkingAPI.py"></mcfile>.
- Data scripts contain their own MySQL connection configs (keep consistent with `DB_CONFIG`).
- JWT: `SECRET_KEY` placeholder is in `easyparkingAPI.py`; use a secure key in production.

---

## Demo Walkthrough

1. Start API service (default 5001):
```bash
python3 easyparkingAPI.py
```

2. Ingest base and real-time data (run at least once):
```bash
python3 Parking_info.py
```

```bash
python3 Parking_Vacancy_Data.py
```

3. Prepare prediction data (requires historical samples):
```bash
python3 Parking_Vacancy_historical_Data.py
```

```bash
python3 predict_vacancy_probability.py
```

4. Call example endpoints:
```bash
curl "http://127.0.0.1:5001/nearby?lat=22.302711&lon=114.177216&radius=1000&limit=10"
```

```bash
curl "http://127.0.0.1:5001/search?q=Central"
```

```bash
curl "http://127.0.0.1:5001/forecast?park_id=tdc26p2"
```

5. Use local test pages (default to `/api` prefix):
- <mcfile name="test_parking_api.html" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/test_parking_api.html"></mcfile>
- <mcfile name="test_login.html" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/test_login.html"></mcfile>

---

## Optional Dependencies (Analysis/Visualization)

If you plan to use <mcfile name="easyparking_data_mining.py" path="/Users/fisher_m3/PycharmProjects/easyparking_callopendata/easyparking_data_mining.py"></mcfile>:
```bash
pip install scikit-learn prophet mlxtend matplotlib
```

---

## Troubleshooting

- Port already in use (5001):
```bash
lsof -ti:5001 | xargs kill -9
```

- Missing dependency (e.g., `ModuleNotFoundError: No module named 'pandas'`):
```bash
pip install pandas
```

- MySQL connection/charset issues (ensure consistency with configs):
  - host: `127.0.0.1`, database: `Eparking_opendata`, charset: `utf8mb4`, collation: `utf8mb4_unicode_ci`
  - username/password must match your local MySQL

- DNS resolution failure (open data host check fails):
  - Ensure network connectivity and DNS for `resource.data.one.gov.hk`

- JSON BOM decoding issues:
  - Ingestion scripts already handle BOM (`utf-8-sig`); if issues persist, verify response encoding

- Validation errors (missing required fields):
  - `Parking_Vacancy_Data.py` requires consistent field names: `vehicle_type` and `service_category`. If logs show “missing: ['vehicle_type']”, align record construction with the validator.

- NameError: `datetime` not defined (if seen in cache update):
```text
Ensure `from datetime import datetime` is imported at the top of Parking_Vacancy_Data.py
```

---

## Security & Production Notes

- Move `SECRET_KEY` and DB credentials to secure config (env vars/config files), avoid hardcoding
- Add rate limiting and audit logs for sensitive endpoints
- Consider connection pool monitoring, retry, and alerting (e.g., Prometheus/Grafana)
- Add indexes/partitioning based on data volume to optimize query performance

---

## License

This project is a prototype and is not intended for production use.
