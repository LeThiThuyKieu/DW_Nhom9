-- Tạo databases cho PROD environment
CREATE DATABASE IF NOT EXISTS weatherdb_prod;
CREATE DATABASE IF NOT EXISTS controldb_prod;

-- Sử dụng weatherdb_prod
USE weatherdb_prod;

-- Bảng chứa dữ liệu gốc (từ API, lưu dạng TEXT)
CREATE TABLE IF NOT EXISTS general_weather (
  id INT AUTO_INCREMENT PRIMARY KEY,
  city TEXT,
  latitude TEXT,
  longitude TEXT,
  elevation TEXT,
  utc_offset_seconds TEXT,
  timezone TEXT,
  timezone_abbreviation TEXT,
  time TEXT,
  temperature_2m TEXT,
  humidity_2m TEXT,
  fetched_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_transformed BOOLEAN DEFAULT FALSE
);

-- Bảng chứa dữ liệu sau khi transform (đúng kiểu dữ liệu)
CREATE TABLE IF NOT EXISTS transform_weather (
  id INT AUTO_INCREMENT PRIMARY KEY,
  city VARCHAR(255),
  latitude FLOAT,
  longitude FLOAT,
  elevation FLOAT,
  utc_offset_seconds INT,
  timezone VARCHAR(255),
  timezone_abbreviation VARCHAR(255),
  time DATETIME,
  temperature_2m FLOAT,
  humidity_2m INT,
  loaded_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Sử dụng controldb_prod
USE controldb_prod;

-- Bảng config để lưu cấu hình các nguồn dữ liệu
CREATE TABLE IF NOT EXISTS config (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  url VARCHAR(500) NOT NULL,
  api_key VARCHAR(255),
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng config_log để theo dõi việc chạy các config
CREATE TABLE IF NOT EXISTS config_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  config_id INT NOT NULL,
  d_run DATE NOT NULL,
  status ENUM('RUNNING', 'SUCCESS', 'FAILED', 'CANCELLED') DEFAULT 'RUNNING',
  start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  end_time DATETIME,
  records_processed INT DEFAULT 0,
  error_message TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (config_id) REFERENCES config(id) ON DELETE CASCADE
);

-- Bảng process_log để theo dõi các quá trình ETL
CREATE TABLE IF NOT EXISTS process_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  process_name VARCHAR(255) NOT NULL,
  process_type ENUM('FETCH', 'LOAD', 'TRANSFORM', 'SCHEDULED', 'LOAD_DW') NOT NULL,
  status ENUM('RUNNING', 'SUCCESS', 'FAILED', 'CANCELLED') DEFAULT 'RUNNING',
  start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  end_time DATETIME,
  records_processed INT DEFAULT 0,
  error_message TEXT,
  config_log_id INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (config_log_id) REFERENCES config_log(id) ON DELETE SET NULL
);

-- Insert default config cho weather API
INSERT IGNORE INTO config (name, url, description) VALUES 
('Open-Meteo Weather API', 'https://api.open-meteo.com/v1/forecast', 'Open source weather API for Vietnam cities');
