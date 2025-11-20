import { getConnection } from "./config/configDb";
import { configManager, controlDBManager } from "./config_manager";

export async function transformOnce(configLogId?: number) {
  let processLogId: number | undefined;
  let conn: any;

  try {
    // Load config
    await configManager.loadConfig();

    // Get weather database config
    const weatherDbConfig = configManager.getWeatherDbConfig();
    conn = await getConnection(weatherDbConfig);

    // Log process start
    processLogId = await controlDBManager.logProcess(
      "Data Transform",
      "TRANSFORM",
      configLogId
    );

    const etlConfig = configManager.getETLConfig();
    const batchSize = parseInt(String(etlConfig.transform.batch_size || 1000));

    // Check if truncate_before_load is enabled
    const shouldTruncate = etlConfig.load?.truncate_before_load || false;

    if (shouldTruncate) {
      console.log("Truncating transform_weather table...");
      await conn.query("TRUNCATE TABLE transform_weather");
      console.log("Truncated transform_weather table");
    }

    const [rows]: any = await conn.query(
      `SELECT * FROM general_weather WHERE is_transformed = FALSE LIMIT ?`,
      [batchSize]
    );

    if (rows.length === 0) {
      console.log("No rows to transform.");
      await controlDBManager.updateProcessLogStatus(processLogId, "SUCCESS", 0);
      return;
    }

    let transformedCount = 0;

    for (const row of rows) {
      try {
        const city = row.city;
        const latitude = parseFloat(row.latitude) || null;
        const longitude = parseFloat(row.longitude) || null;
        const elevation = parseFloat(row.elevation) || null;
        const utc_offset_seconds = parseInt(row.utc_offset_seconds) || null;
        const timezone = row.timezone;
        const timezone_abbreviation = row.timezone_abbreviation;
        const time = new Date(row.time);
        const temperature_2m = parseFloat(row.temperature_2m) || null;
        const humidity_2m = parseInt(row.humidity_2m) || null;

        await conn.execute(
          `INSERT INTO transform_weather
          (city, latitude, longitude, elevation, utc_offset_seconds, timezone, timezone_abbreviation, time, temperature_2m, humidity_2m)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
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

        // đánh dấu đã transform
        await conn.execute(
          `UPDATE general_weather SET is_transformed = TRUE WHERE id = ?`,
          [row.id]
        );

        transformedCount++;
      } catch (err) {
        console.error("Transform error for row", row.id, err);
      }
    }

    console.log(`Transformed ${transformedCount} rows.`);

    // Update process log
    await controlDBManager.updateProcessLogStatus(
      processLogId,
      "SUCCESS",
      transformedCount
    );
  } catch (err) {
    console.error("Error in transform:", err);

    if (processLogId) {
      await controlDBManager.updateProcessLogStatus(
        processLogId,
        "FAILED",
        0,
        err instanceof Error ? err.message : String(err)
      );
    }

    throw err;
  } finally {
    if (conn) {
      await conn.end();
    }
  }
}

if (require.main === module) {
  transformOnce().catch(console.error);
}