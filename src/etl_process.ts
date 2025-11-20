import { fetchAndSaveWeatherData } from "./fetch_weather";
import { loadLatestCSVFile } from "./load_csv";
import { transformOnce } from "./transform";
import { loadToDataWarehouse } from "./load_to_datawarehouse";
import { configManager, controlDBManager } from "./config_manager";

export async function runETLProcess(): Promise<void> {
  let configLogId: number | undefined;

  try {
    // Load config
    await configManager.loadConfig();

    // Get active configs
    const activeConfigs = await controlDBManager.getActiveConfigs();
    if (activeConfigs.length === 0) {
      throw new Error("No active configs found");
    }

    const config = activeConfigs[0]; // Sử dụng config đầu tiên
    const dRun = new Date();

    // Log config run start
    configLogId = await controlDBManager.logConfigRun(config.id, dRun);

    console.log("=== Starting ETL Process ===");
    console.log(`Config: ${config.name}`);
    console.log(`Run Date: ${dRun.toISOString()}`);

    // Step 1: Fetch data from API and save to CSV
    console.log("\n--- Step 1: Fetching data from API ---");
    const csvFilePath = await fetchAndSaveWeatherData(configLogId);
    console.log(`Data saved to: ${csvFilePath}`);

    // Step 2: Load CSV data to general_weather table
    console.log("\n--- Step 2: Loading CSV to database ---");
    await loadLatestCSVFile(configLogId);
    console.log("CSV data loaded to general_weather table");

    // Step 3: Transform data to transform_weather table
    console.log("\n--- Step 3: Transforming data ---");
    await transformOnce(configLogId);
    console.log("Data transformed to transform_weather table");

    // Step 4: Load to Data Warehouse
    console.log("\n--- Step 4: Loading to Data Warehouse ---");
    await loadToDataWarehouse(configLogId);
    console.log("Data loaded to Data Warehouse");

    // Update config log as successful
    await controlDBManager.updateConfigLogStatus(configLogId, "SUCCESS");

    console.log("\n=== ETL Process Completed Successfully ===");
  } catch (error) {
    console.error("\n=== ETL Process Failed ===");
    console.error("Error:", error);

    if (configLogId) {
      await controlDBManager.updateConfigLogStatus(
        configLogId,
        "FAILED",
        0,
        error instanceof Error ? error.message : String(error)
      );
    }

    throw error;
  }
}

export async function runScheduledETL(): Promise<void> {
  try {
    await configManager.loadConfig();
    const etlConfig = configManager.getETLConfig();

    if (!etlConfig.fetch.enabled) {
      console.log("Fetch process is disabled in config");
      return;
    }

    console.log("Running scheduled ETL process...");
    await runETLProcess();
  } catch (error) {
    console.error("Scheduled ETL failed:", error);
    throw error;
  }
}

//CLI để chạy bằng tay ETL process
if (require.main === module) {
  runETLProcess()
    .then(() => {
      console.log("ETL process completed successfully");
      process.exit(0);
    })
    .catch((error) => {
      console.error("ETL process failed:", error);
      process.exit(1);
    });
}
