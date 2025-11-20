# 🗄️ WEATHER DATA WAREHOUSE - Final Structure

## 📊 **KIẾN TRÚC HOÀN CHỈNH**

### **Luồng ETL:**

```
API → CSV → general_weather (staging)
              ↓
      transform_weather (staging)
              ↓
   Data Warehouse (datawarehouse)
   - Dim_Location
   - Dim_Time
   - Fact_Weather
```

---

## 🏗️ **CẤU TRÚC DATABASE**

### **1. STAGING DATABASE (weatherdb_dev)**

Lưu trữ dữ liệu trung gian:

- **`general_weather`**: Raw data từ API (TEXT format)
- **`transform_weather`**: Data đã transform (đúng kiểu dữ liệu)

### **2. DATAWAREHOUSE (datawarehouse)**

Production database với Star Schema:

- **`Dim_Location`**: Dimension Địa điểm (PK: location_key)
- **`Dim_Time`**: Dimension Thời gian (PK: time_key)
- **`Fact_Weather`**: Fact Thời tiết (FK: time_key, location_key)

### **3. CONTROL DATABASE (controldb_dev)**

- **`config`**: Cấu hình nguồn dữ liệu
- **`config_log`**: Log các lần chạy ETL
- **`process_log`**: Log chi tiết từng bước

---

## 🔄 **LUỒNG ETL HOÀN CHỈNH**

### **BƯỚC 1: FETCH**

```bash
npm run run:fetch
```

- Fetch data từ Open-Meteo API
- 2 thành phố Việt Nam
- Lưu vào CSV file

### **BƯỚC 2: LOAD**

```bash
npm run run:load
```

- Load CSV vào `general_weather` (staging)

### **BƯỚC 3: TRANSFORM**

```bash
npm run run:transform
```

- Transform từ `general_weather` → `transform_weather`
- Convert kiểu dữ liệu

### **BƯỚC 4: LOAD TO DATA WAREHOUSE**

```bash
npm run run:load-dw
```

- Load từ `transform_weather` vào Data Warehouse
- Populate Dim_Time
- Populate Dim_Location
- Populate Fact_Weather

### **CHẠY TOÀN BỘ ETL:**

```bash
npm run run:etl
```

- Tự động chạy tất cả 4 bước

---

## 🚀 **CÁCH SỬ DỤNG**

### **1. Chạy migrations:**

```bash
# Tạo bảng staging
mysql -u root -p < migrations/create_tables_dev.sql

# Tạo datawarehouse
mysql -u root -p < migrations/create_datawarehouse.sql
```

### **2. Chạy ETL:**

```bash
npm run run:etl
```

### **3. Kiểm tra kết quả:**

```sql
-- Staging
SELECT COUNT(*) FROM weatherdb_dev.general_weather;
SELECT COUNT(*) FROM weatherdb_dev.transform_weather;

-- Datawarehouse
SELECT COUNT(*) FROM datawarehouse.Dim_Location;
SELECT COUNT(*) FROM datawarehouse.Dim_Time;
SELECT COUNT(*) FROM datawarehouse.Fact_Weather;
```

---

## 📋 **CẤU TRÚC BẢNG**

### **Dim_Location**

```
location_key (PK) | city | latitude | longitude | timezone |
timezone_abbreviation | utc_offset_seconds | elevation
```

### **Dim_Time**

```
time_key (PK) | datetime | date | year | month | day | hour |
day_of_week | quarter | season
```

### **Fact_Weather**

```
weather_id (PK) | time_key (FK) | location_key (FK) |
temperature_2m | humidity_2m | elevation | loaded_at
```

---

## ✅ **LỢI ÍCH**

✅ **Star Schema** dễ query và analyze  
✅ **Dimension tables** hỗ trợ drill-down  
✅ **Production-ready** data warehouse  
✅ **Scalable** cho dự án lớn

---

**Hệ thống sẵn sàng để demo! **
