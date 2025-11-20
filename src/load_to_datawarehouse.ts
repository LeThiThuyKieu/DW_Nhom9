import { getConnection } from "./config/configDb";
import { configManager, controlDBManager } from "./config_manager";

export async function loadToDataWarehouse(configLogId?: number) {
  let stagingConn: any;
  let dwConn: any;
  let processLogId: number | undefined;

  try {
    // Load config
    await configManager.loadConfig();

    // Log start of process
    processLogId = await controlDBManager.logProcess(
      "Load to Data Warehouse",
      "LOAD_DW",
      configLogId
    );

    // Get database configs
    const stagingDbConfig = configManager.getWeatherDbConfig();
    const dwDbConfig = {
      host: stagingDbConfig.host,
      port: stagingDbConfig.port,
      database: "datawarehouse",
      username: stagingDbConfig.username,
      password: stagingDbConfig.password,
    };

    // Connect to staging database
    stagingConn = await getConnection(stagingDbConfig);

    // Connect to datawarehouse
    dwConn = await getConnection(dwDbConfig);

    console.log("Starting datawarehouse load process...");

    // Lấy dữ liệu từ transform_weather
    console.log("Fetching data from transform_weather...");
    const [rows]: any[] = await stagingConn.execute(`
      SELECT 
        city, latitude, longitude, elevation, utc_offset_seconds, 
        timezone, timezone_abbreviation, time, temperature_2m, humidity_2m
      FROM transform_weather
    `);

    if (rows.length === 0) {
      console.log("No data in transform_weather to load.");
      return;
    }

    console.log(`Found ${rows.length} records to load into datawarehouse`);

    let insertedCount = 0;
    let skippedCount = 0;

    for (const row of rows) {
      //1. Lấy date_key từ dim_date (theo ngày của cột time trong transform)
      const [dateRes]: any[] = await dwConn.execute(
        `SELECT date_key FROM dim_date WHERE full_date = DATE(?) LIMIT 1`,
        [row.time]
      );
      if (dateRes.length === 0) {
        skippedCount++;
        continue;
      }
      const dateKey = dateRes[0].date_key;

      //2. Lấy location_key từ dim_location (theo city, latitude, longitude)
      const [locRes]: any[] = await dwConn.execute(
        `SELECT * FROM dim_location 
        WHERE city = ? AND latitude = ? AND longitude = ?`,
        [row.city, row.latitude, row.longitude]
      );

      if (locRes.length === 0) {
        // Không có location → INSERT mới
        const [insertLoc]: any = await dwConn.execute(
          `INSERT INTO dim_location 
            (city, latitude, longitude, utc_offset_seconds, timezone, timezone_abbreviation)
          VALUES (?, ?, ?, ?, ?, ?)`,
          [
            row.city,
            row.latitude,
            row.longitude,
            row.utc_offset_seconds,
            row.timezone,
            row.timezone_abbreviation,
          ]
        );

        row.location_key = insertLoc.insertId;
      } else {
        const existing = locRes[0];

        const isSame =
          existing.utc_offset_seconds === row.utc_offset_seconds &&
          existing.timezone === row.timezone &&
          existing.timezone_abbreviation === row.timezone_abbreviation;

        row.location_key = existing.location_key;

        if (!isSame) {
          // UPDATE lại
          await dwConn.execute(
            `UPDATE dim_location 
            SET 
              utc_offset_seconds = ?,
              timezone = ?,
              timezone_abbreviation = ?,
              updated_at = NOW()
            WHERE location_key = ?`,
            [
              row.utc_offset_seconds,
              row.timezone,
              row.timezone_abbreviation,
              existing.location_key,
            ]
          );
        }
      }

      //3. Insert dữ liệu vào fact_weather (nếu chưa tồn tại)
      try {
        await dwConn.execute(
          `INSERT INTO fact_weather
            (date_key, location_key, temperature_2m, humidity_2m, elevation)
           VALUES (?, ?, ?, ?, ?)`,
          [
            dateKey,
            row.location_key,
            row.temperature_2m,
            row.humidity_2m,
            row.elevation,
          ]
        );
        insertedCount++;
      } catch (err: any) {
        // Nếu bản ghi trùng (unique key), thì bỏ qua
        if (err.code === "ER_DUP_ENTRY") {
          skippedCount++;
          continue;
        } else {
          throw err;
        }
      }
    }

    console.log(`Đã load ${insertedCount} bản ghi mới vào fact_weather`);

    //Update process log success
    await controlDBManager.updateProcessLogStatus(
      processLogId,
      "SUCCESS",
      insertedCount
    );

    console.log("\n Datawarehouse load completed successfully!");
  } catch (err: any) {
    console.error("Error in loadToDataWarehouse:", err);
    throw err;
  } finally {
    if (stagingConn) {
      await stagingConn.end();
    }
    if (dwConn) {
      await dwConn.end();
    }
  }
}

// CLI để chạy bằng tay
if (require.main === module) {
  loadToDataWarehouse()
    .then(() => {
      console.log("Datawarehouse load completed successfully");
      process.exit(0);
    })
    .catch((error) => {
      console.error("Datawarehouse load failed:", error);
      process.exit(1);
    });
}
