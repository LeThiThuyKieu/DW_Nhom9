import cron from "node-cron";
import { runScheduledETL } from "./etl_process";
import { configManager } from "./config_manager";

async function startScheduler() {
  // Load config để lấy schedule
  let schedule = "0 7 * * *"; //7h sáng mỗi ngày

  try {
    await configManager.loadConfig();
    const etlConfig = configManager.getETLConfig();
    if (etlConfig.fetch.schedule) {
      schedule = etlConfig.fetch.schedule;
    }
  } catch (error) {
    console.warn("Không thể load config, sử dụng schedule mặc định:", error);
  }

  console.log("=".repeat(50));
  console.log("Scheduler đã được khởi động!");
  console.log(`Cron schedule: ${schedule}`);
  console.log("Scheduler đang chạy và chờ đến lúc trigger...");
  console.log("Nhấn Ctrl+C để dừng scheduler");
  console.log("=".repeat(50));

  cron.schedule(schedule, async () => {
    console.log(
      `\n[${new Date().toLocaleString("vi-VN")}] Bắt đầu chạy scheduled ETL...`
    );
    try {
      await runScheduledETL();
      console.log(
        `[${new Date().toLocaleString(
          "vi-VN"
        )}] Scheduled ETL hoàn thành thành công!\n`
      );
    } catch (err) {
      console.error(
        `[${new Date().toLocaleString("vi-VN")}] Scheduled ETL job error:`,
        err
      );
    }
  });
}

// Khởi động scheduler
startScheduler().catch((error) => {
  console.error("Lỗi khi khởi động scheduler:", error);
  process.exit(1);
});
