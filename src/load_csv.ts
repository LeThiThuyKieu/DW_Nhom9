import fs from "fs";
import path from "path";
import { getConnection } from "./config/configDb";
import { configManager, controlDBManager } from "./config_manager";

export async function loadCSVToDatabase(csvFilePath: string): Promise<number> {
  let conn: any;

  try {
    // Load config first
    await configManager.loadConfig();

    // Get weather database config
    const weatherDbConfig = configManager.getWeatherDbConfig();
    conn = await getConnection(weatherDbConfig);
    // Đọc file CSV
    const csvContent = fs.readFileSync(csvFilePath, "utf8");
    const lines = csvContent.split("\n").filter((line) => line.trim());

    if (lines.length < 2) {
      throw new Error("CSV file must have at least header and one data row");
    }

    // Bỏ qua header (dòng đầu tiên)
    const dataLines = lines.slice(1);

    console.log(`Found ${dataLines.length} data rows in CSV file`);

    // Truncate bảng general_weather trước khi load dữ liệu mới (nếu được config)
    const etlConfig = configManager.getETLConfig();
    if (etlConfig.load.truncate_before_load) {
      console.log("Truncating general_weather table...");
      await conn.execute("TRUNCATE TABLE general_weather");
    }

    // Insert dữ liệu từ CSV
    let insertedCount = 0;

    for (const line of dataLines) {
      if (!line.trim()) continue;

      try {
        // Parse CSV line
        const values = line
          .split(",")
          .map((val) => val.replace(/"/g, "").trim());

        if (values.length !== 10) {
          console.warn(`Skipping invalid line: ${line}`);
          continue;
        }

        const [
          city,
          latitude,
          longitude,
          elevation,
          utc_offset_seconds,
          timezone,
          timezone_abbreviation,
          time,
          temperature_2m,
          humidity_2m,
        ] = values;

        await conn.execute(
          `INSERT INTO general_weather 
          (city, latitude, longitude, elevation, utc_offset_seconds, timezone, timezone_abbreviation, time, temperature_2m, humidity_2m, is_transformed)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, FALSE)`,
          [
            city,
            latitude,
            longitude,
            elevation,
            utc_offset_seconds,
            timezone,
            timezone_abbreviation,
            time,
            temperature_2m,
            humidity_2m,
          ]
        );

        insertedCount++;
      } catch (err) {
        console.error(`Error inserting line: ${line}`, err);
      }
    }

    console.log(
      `Successfully loaded ${insertedCount} rows into general_weather table`
    );

    return insertedCount;
  } catch (err) {
    console.error("Error loading CSV to database:", err);
    throw err;
  } finally {
    if (conn) {
      await conn.end();
    }
  }
}

export async function loadLatestCSVFile(configLogId?: number): Promise<void> {
  let processLogId: number | undefined;

  try {
    // Load config
    await configManager.loadConfig();

    // Log process start
    processLogId = await controlDBManager.logProcess(
      "CSV Load",
      "LOAD",
      configLogId
    );

    const stagingConfig = configManager.getStagingConfig();

    if (!fs.existsSync(stagingConfig.directory)) {
      throw new Error(
        `Staging directory ${stagingConfig.directory} does not exist`
      );
    }

    // Tìm file CSV mới nhất
    const files = fs
      .readdirSync(stagingConfig.directory)
      .filter((file) => file.startsWith("data_") && file.endsWith(".csv"))
      .sort()
      .reverse(); // Sắp xếp từ mới nhất đến cũ nhất

    if (files.length === 0) {
      throw new Error("No CSV files found in staging_data directory");
    }

    const latestFile = files[0];
    const filePath = path.join(stagingConfig.directory, latestFile);

    console.log(`Loading latest CSV file: ${latestFile}`);
    const insertedCount = await loadCSVToDatabase(filePath);

    // Update process log
    await controlDBManager.updateProcessLogStatus(
      processLogId,
      "SUCCESS",
      insertedCount
    );
  } catch (error) {
    console.error("Error in loadLatestCSVFile:", error);

    if (processLogId) {
      await controlDBManager.updateProcessLogStatus(
        processLogId,
        "FAILED",
        0,
        error instanceof Error ? error.message : String(error)
      );
    }

    throw error;
  }
}

if (require.main === module) {
  loadLatestCSVFile()
    .then(() => {
      console.log("Successfully loaded CSV data to database");
    })
    .catch((error) => {
      console.error("Error:", error);
      process.exit(1);
    });
}
