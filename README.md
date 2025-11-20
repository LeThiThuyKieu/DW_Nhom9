# Weather ETL Data Warehouse Project

Dự án Data Warehouse cho việc thu thập và xử lý dữ liệu thời tiết từ API Open-Meteo.

## Cài đặt

1. Cài đặt dependencies:

```bash
npm install
```

2. Cấu hình database trong `src/config/configDb.ts`

3. Chạy migrations để tạo databases và tables:

```bash
mysql -u root -p < migrations/create_tables.sql
```

## Cấu hình

### Các file config.xml

File cấu hình chính chứa:

- Cấu hình databases (weatherdb, controldb)
- Cấu hình staging directory
- Cấu hình API endpoints
- Cấu hình ETL processes
- Cấu hình logging

### Control Database

Database `controldb` chứa các bảng:

- `config`: Cấu hình các nguồn dữ liệu
- `config_log`: Log việc chạy các config
- `process_log`: Log các quá trình ETL

## Sử dụng

### Chạy từng bước riêng lẻ:

1. **Fetch data từ API và lưu CSV:**

```bash
npm run run:fetch
```

2. **Load CSV vào database:**

```bash
npm run run:load
```

3. **Transform data:**

```bash
npm run run:transform
```

### Chạy toàn bộ ETL process:

```bash
npm run run:etl
```

### Chạy scheduler tự động:

```bash
npm run run:scheduler
```

## Quy trình ETL

1. **Extract (Fetch)**: Lấy dữ liệu từ Open-Meteo API cho các thành phố Việt Nam
2. **Staging**: Lưu dữ liệu vào CSV files trong folder `staging_data` với format `data_yyyymmdd_hhmm.csv`
3. **Load**: Load dữ liệu từ CSV vào bảng `general_weather` (truncate trước khi load)
4. **Transform**: Chuyển đổi dữ liệu từ `general_weather` sang `transform_weather` với đúng kiểu dữ liệu

## Schema Database

### weatherdb.general_weather

Bảng chứa dữ liệu gốc (tất cả cột là TEXT):

- id, city, latitude, longitude, elevation
- utc_offset_seconds, timezone, timezone_abbreviation
- time, temperature_2m, humidity_2m
- fetched_at, is_transformed

### weatherdb.transform_weather

Bảng chứa dữ liệu sau transform (đúng kiểu dữ liệu):

- id, city (VARCHAR), latitude (FLOAT), longitude (FLOAT)
- elevation (FLOAT), utc_offset_seconds (INT)
- timezone (VARCHAR), timezone_abbreviation (VARCHAR)
- time (DATETIME), temperature_2m (FLOAT), humidity_2m (INT)
- loaded_at

### controldb.config

Bảng cấu hình nguồn dữ liệu:

- id, name, url, api_key, description
- is_active, created_at, updated_at

### controldb.config_log

Bảng log việc chạy config:

- id, config_id, d_run, status
- start_time, end_time, records_processed, error_message

### controldb.process_log

Bảng log các quá trình ETL:

- id, process_name, process_type, status
- start_time, end_time, records_processed, error_message
- config_log_id

## Monitoring

Kiểm tra logs trong control database:

```sql
-- Xem log các config runs
SELECT * FROM controldb.config_log ORDER BY start_time DESC;

-- Xem log các processes
SELECT * FROM controldb.process_log ORDER BY start_time DESC;

-- Xem status tổng quan
SELECT
    cl.status as config_status,
    COUNT(pl.id) as process_count,
    SUM(pl.records_processed) as total_records
FROM controldb.config_log cl
LEFT JOIN controldb.process_log pl ON cl.id = pl.config_log_id
GROUP BY cl.status;
```

## Lưu ý

- Scheduler mặc định chạy mỗi 6 tiếng (có thể thay đổi trong .env)
- Dữ liệu CSV được lưu với format `data_yyyymmdd_hhmm.csv`
- Trước khi load dữ liệu mới, bảng `general_weather` sẽ được truncate
- Tất cả processes đều được log vào control database
- Config có thể được quản lý qua file `config.xml`
