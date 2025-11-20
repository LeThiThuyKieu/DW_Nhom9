# Environment Configuration Guide

Dự án hỗ trợ 3 môi trường: **DEV**, **QA**, và **PROD**.

## 📁 Files cấu hình

- `config-dev.xml` - Development (local)
- `config-qa.xml` - Quality Assurance (testing)
- `config-prod.xml` - Production (live)

ENVIRONMENT=DEV → dùng config-dev.xml  
ENVIRONMENT=QA → dùng config-qa.xml  
ENVIRONMENT=PROD → dùng config-prod.xml

## 🔧 Cách sử dụng

### 1. **Development (DEV) - Mặc định**

```bash
# Không cần set gì, mặc định sẽ dùng DEV
npm run run:etl
```

Hoặc set environment variable:

```bash
# Windows
set ENVIRONMENT=DEV
npm run run:etl

# Linux/Mac
export ENVIRONMENT=DEV
npm run run:etl
```

### 2. **Quality Assurance (QA)**

```bash
# Windows
set ENVIRONMENT=QA
npm run run:etl

# Linux/Mac
export ENVIRONMENT=QA
npm run run:etl
```

### 3. **Production (PROD)**

```bash
# Windows
set ENVIRONMENT=PROD
npm run run:etl

# Linux/Mac
export ENVIRONMENT=PROD
npm run run:etl
```

## 🎯 Sự khác biệt giữa các môi trường

### DEV (Development)

- **Database**: `weatherdb_dev`, `controldb_dev`
- **Staging**: `staging_data_dev`
- **Cities**: 2 cities (HCM, Hanoi)
- **Schedule**: Mỗi 1 tiếng (`0 * * * *`)
- **Batch size**: 100 records
- **Logging**: DEBUG level
- **Retention**: 7 ngày

### QA (Quality Assurance)

- **Database**: `weatherdb_qa`, `controldb_qa`
- **Staging**: `staging_data_qa`
- **Cities**: 3 cities (HCM, Hanoi, Da Nang)
- **Schedule**: Mỗi 4 tiếng (`0 */4 * * *`)
- **Batch size**: 500 records
- **Logging**: INFO level
- **Retention**: 14 ngày
- **Host**: QA server

### PROD (Production)

- **Database**: `weatherdb`, `controldb`
- **Staging**: `staging_data`
- **Cities**: 5 cities (all cities)
- **Schedule**: Mỗi 6 tiếng (`0 */6 * * *`)
- **Batch size**: 1000 records
- **Logging**: INFO level
- **Retention**: 30 ngày
- **Host**: Production server
- **Security**: Secure passwords

## 📝 Ví dụ

### Chạy test trên QA environment:

```bash
set ENVIRONMENT=QA
npm run run:etl
```

Console output:

```
Loading config from: config-qa.xml for environment: QA
=== Starting ETL Process ===
Config: Open-Meteo Weather API
Connecting to database: qa-db-server.company.com:3306/weatherdb_qa
...
```

### Chạy production:

```bash
set ENVIRONMENT=PROD
npm run run:etl
```

Console output:

```
Loading config from: config-prod.xml for environment: PROD
=== Starting ETL Process ===
Config: Open-Meteo Weather API
Connecting to database: prod-db-server.company.com:3306/weatherdb
...
```

## ⚙️ Advanced: Sử dụng custom config path

Nếu bạn muốn load một config file khác:

```typescript
import { configManager } from "./config_manager";

await configManager.loadConfig("config-custom.xml");
```

## 🔒 Security Note

⚠️ **QUAN TRỌNG**: File `config-prod.xml` chứa production passwords!

- **KHÔNG** commit passwords thật vào git
- Sử dụng environment variables hoặc secret management trong production
- File ví dụ này chỉ là template

## 📊 Kiểm tra environment hiện tại

Sau khi load config, bạn có thể kiểm tra:

```typescript
import { configManager } from "./config_manager";

await configManager.loadConfig();
console.log("Current environment:", configManager.getEnvironment());
```







