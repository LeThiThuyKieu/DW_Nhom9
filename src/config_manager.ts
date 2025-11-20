import fs from "fs";
import xml2js from "xml2js";
import { getConnection } from "./config/configDb";

interface DatabaseConfig {
  host: string;
  port: number;
  database: string;
  username: string;
  password: string;
}

interface CityConfig {
  name: string;
  latitude: string;
  longitude: string;
}

interface WeatherAPIConfig {
  name: string;
  url: string;
  cities: CityConfig[];
  parameters: {
    hourly: string;
  };
}

interface ETLProcessConfig {
  enabled: boolean;
  schedule?: string;
  timeout?: number;
  batch_size?: number;
  truncate_before_load?: boolean;
}

interface DataWarehouseConfig {
  databases: {
    weatherdb: DatabaseConfig;
    controldb: DatabaseConfig;
  };
  staging: {
    directory: string;
    file_pattern: string;
    retention_days: number;
  };
  apis: {
    "weather-api": WeatherAPIConfig;
  };
  "etl-processes": {
    fetch: ETLProcessConfig;
    load: ETLProcessConfig;
    transform: ETLProcessConfig;
  };
  logging: {
    level: string;
    file: string;
    max_size: string;
    backup_count: number;
  };
}

export class ConfigManager {
  private config: DataWarehouseConfig | null = null;
  private environment: string = "DEV"; // Mặc định là DEV

  async loadConfig(configPath?: string): Promise<DataWarehouseConfig> {
    try {
      // Nếu không truyền configPath, lấy từ environment variable
      if (!configPath) {
        configPath = this.getConfigPathFromEnvironment();
      }

      console.log(
        `Loading config from: ${configPath} for environment: ${this.environment}`
      );

      const xmlContent = fs.readFileSync(configPath, "utf8");
      const parser = new xml2js.Parser({
        explicitArray: false,
        mergeAttrs: true, // Merge attributes vào object
      });
      const result = await parser.parseStringPromise(xmlContent);

      this.config = result["datawarehouse-config"] as DataWarehouseConfig;
      return this.config;
    } catch (error) {
      console.error("Error loading config:", error);
      throw error;
    }
  }

  // Lấy config path dựa trên environment variable
  private getConfigPathFromEnvironment(): string {
    const env = process.env.ENVIRONMENT || "DEV";
    this.environment = env.toUpperCase();

    switch (this.environment) {
      case "DEV":
        return "config-dev.xml";
      case "QA":
        return "config-qa.xml";
      case "PROD":
        return "config-prod.xml";
      default:
        console.warn(`Unknown environment: ${env}, using DEV config`);
        return "config-dev.xml";
    }
  }

  getEnvironment(): string {
    return this.environment;
  }

  getConfig(): DataWarehouseConfig {
    if (!this.config) {
      throw new Error("Config not loaded. Call loadConfig() first.");
    }
    return this.config;
  }

  getWeatherAPIConfig(): WeatherAPIConfig {
    return this.getConfig().apis["weather-api"];
  }

  getStagingConfig() {
    return this.getConfig().staging;
  }

  getETLConfig() {
    return this.getConfig()["etl-processes"];
  }

  getWeatherDbConfig() {
    return this.getConfig().databases.weatherdb;
  }

  getControlDbConfig() {
    return this.getConfig().databases.controldb;
  }
}

export class ControlDBManager {
  private configManager: ConfigManager;

  constructor(configManager: ConfigManager) {
    this.configManager = configManager;
  }

  async logConfigRun(configId: number, dRun: Date): Promise<number> {
    const dbConfig = this.configManager.getControlDbConfig();
    const conn = await getConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      database: dbConfig.database,
      username: dbConfig.username,
      password: dbConfig.password,
    });

    try {
      const [result]: any = await conn.execute(
        `INSERT INTO ${dbConfig.database}.config_log (config_id, d_run, status, start_time) 
         VALUES (?, ?, 'RUNNING', NOW())`,
        [configId, dRun]
      );

      return result.insertId;
    } finally {
      await conn.end();
    }
  }

  async updateConfigLogStatus(
    logId: number,
    status: "SUCCESS" | "FAILED" | "CANCELLED",
    recordsProcessed: number = 0,
    errorMessage?: string
  ) {
    const dbConfig = this.configManager.getControlDbConfig();
    const conn = await getConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      database: dbConfig.database,
      username: dbConfig.username,
      password: dbConfig.password,
    });

    try {
      await conn.execute(
        `UPDATE ${dbConfig.database}.config_log 
         SET status = ?, end_time = NOW(), records_processed = ?, error_message = ?
         WHERE id = ?`,
        [status, recordsProcessed, errorMessage || null, logId]
      );
    } finally {
      await conn.end();
    }
  }

  async logProcess(
    processName: string,
    processType: "FETCH" | "LOAD" | "TRANSFORM" | "SCHEDULED" | "LOAD_DW",
    configLogId?: number
  ): Promise<number> {
    const dbConfig = this.configManager.getControlDbConfig();
    const conn = await getConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      database: dbConfig.database,
      username: dbConfig.username,
      password: dbConfig.password,
    });

    try {
      const [result]: any = await conn.execute(
        `INSERT INTO ${dbConfig.database}.process_log (process_name, process_type, status, start_time, config_log_id) 
         VALUES (?, ?, 'RUNNING', NOW(), ?)`,
        [processName, processType, configLogId || null]
      );

      return result.insertId;
    } finally {
      await conn.end();
    }
  }

  async updateProcessLogStatus(
    logId: number,
    status: "SUCCESS" | "FAILED" | "CANCELLED" | "NO_DATA",
    recordsProcessed: number = 0,
    errorMessage?: string
  ) {
    const dbConfig = this.configManager.getControlDbConfig();
    const conn = await getConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      database: dbConfig.database,
      username: dbConfig.username,
      password: dbConfig.password,
    });

    try {
      await conn.execute(
        `UPDATE ${dbConfig.database}.process_log 
         SET status = ?, end_time = NOW(), records_processed = ?, error_message = ?
         WHERE id = ?`,
        [status, recordsProcessed, errorMessage || null, logId]
      );
    } finally {
      await conn.end();
    }
  }

  async getActiveConfigs(): Promise<any[]> {
    const dbConfig = this.configManager.getControlDbConfig();
    const conn = await getConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      database: dbConfig.database,
      username: dbConfig.username,
      password: dbConfig.password,
    });

    try {
      const [rows]: any = await conn.execute(
        `SELECT * FROM ${dbConfig.database}.config WHERE is_active = TRUE`
      );

      return rows;
    } finally {
      await conn.end();
    }
  }
}

// Export singleton instances
export const configManager = new ConfigManager();
export const controlDBManager = new ControlDBManager(configManager);
